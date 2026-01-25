import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../lang/strings.dart';
import 'assets/assets.dart';
import 'plant_dialog.dart';
import 'virtual_place_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const double _panExtra = 180.0;
  final TransformationController _tc = TransformationController();
  StreamSubscription<Position>? _posSub;

  /* static const bool useMockLocation = true; // TESTOVANIE
  Offset? _mockMePx;*/

  LatLng? _meGps;
  bool _following = true;

  double _minScale = 0.2;
  final double _maxScale = 8.0;

  // ROUTE UI
  bool _pickMode = false;
  bool _routeRunning = false;
  final List<int> _selectedPlants = [];

  // MULTI-SEGMENT ROUTE (ja->1, 1->2, ...)
  List<List<Offset>> _routeSegmentsPx = [];

  // ========= ROUTER MASKS =========
  static const int _gridStep = 4;
  Uint8List? _orangeMask; // len oranžová
  Uint8List? _comboMask; // oranžová + programové výnimky
  int _gw = 0, _gh = 0;
  bool _maskLoading = false;

  // ŠPECIÁLNE BODY (0-based indexy):
  // 26,13,14,8,9,10 -> (25,12,13,7,8,9)
  static const Set<int> _specialPlants = {25, 12, 13, 7, 8, 9};

  // ✅ Virtuálna poloha (panáčik)
  Offset? _virtualMePx;
  bool _placeMode = false;

  // ✅ OFFSITE logika
  // Stred lokality: použijeme bod 16 (index 15) ako referenčný "stred" botanickej.
  static const LatLng _siteCenterGps = LatLng(51.226732, 5.876960); // bod 16
  static const double _siteRadiusMeters = 5000; // 1–5 km -> dáme 5 km

  bool _isOffsite = false;
  bool _offsiteDialogShowing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final size = MediaQuery.of(context).size;
      _minScale = _fitScale(size.width, size.height);

      _setTransformCenteredOn(
        targetPx: const Offset(mapWidthPx / 2, mapHeightPx / 2),
        scale: _minScale,
      );

      _ensureMasks();
      await _initLocation();
    });
  }

  // ===========================
  // OFFSITE DIALOG
  // ===========================
  Future<void> _showOffsiteDialogOnce() async {
    if (!mounted) return;
    if (_offsiteDialogShowing) return;

    _offsiteDialogShowing = true;

    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr.mapOffsiteTitle),
        content: Text(ctx.tr.mapOffsiteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
            child: Text(ctx.tr.ok),
          ),
        ],
      ),
    );

    _offsiteDialogShowing = false;
  }

  bool _isWithinSiteRadius(Position p) {
    final d = Geolocator.distanceBetween(
      p.latitude,
      p.longitude,
      _siteCenterGps.latitude,
      _siteCenterGps.longitude,
    );
    return d <= _siteRadiusMeters;
  }

  // ===========================
  // TRANSFORM
  // ===========================
  Offset _gpsToPixel(LatLng gps) => gpsToPx.gpsToPixel(gps);

  bool _insideMap(Offset px) =>
      px.dx >= 0 && px.dy >= 0 && px.dx <= mapWidthPx && px.dy <= mapHeightPx;

  Offset _clampToMap(Offset px) => Offset(
    px.dx.clamp(0.0, mapWidthPx.toDouble()).toDouble(),
    px.dy.clamp(0.0, mapHeightPx.toDouble()).toDouble(),
  );

  List<Offset> _computePlantPx() {
    return List<Offset>.generate(plantPoints.length, (i) {
      final base = _gpsToPixel(plantPoints[i]);
      return base + markerOffsetsPx[i];
    });
  }

  Offset? _mePxRaw() {
    // ✅ priorita: virtuálna poloha (panáčik)
    if (_virtualMePx != null) return _virtualMePx;

    // ✅ ak sme offsite, reálnu polohu vôbec nekresli
    if (_isOffsite) return null;

    // reálna GPS
    return (_meGps == null) ? null : _gpsToPixel(_meGps!);
  }

  /* Offset? _mePxRaw() { TESTOVANIE
    // ✅ priorita: virtuálna poloha (panáčik)
    if (_virtualMePx != null) return _virtualMePx;

    // ✅ DEV mock poloha (testovanie)
    if (useMockLocation && _mockMePx != null) return _mockMePx;

    // ✅ ak sme offsite, reálnu polohu vôbec nekresli
    if (_isOffsite) return null;

    // reálna GPS
    return (_meGps == null) ? null : _gpsToPixel(_meGps!);
  }*/


  Offset? _mePxClamped() {
    final raw = _mePxRaw();
    if (raw == null) return null;
    return _clampToMap(raw);
  }

  bool get _isOffMap {
    final raw = _mePxRaw();
    if (raw == null) return true;
    return !_insideMap(raw);
  }

  // ===========================
  // VIEW / ZOOM
  // ===========================
  double _fitScale(double viewW, double viewH) {
    const pad = 12.0;
    final sx = (viewW - pad * 2) / mapWidthPx;
    final sy = (viewH - pad * 2) / mapHeightPx;
    return math.min(sx, sy).clamp(0.05, _maxScale).toDouble();
  }

  double _currentScale() => _tc.value.getMaxScaleOnAxis();

  Offset _clampTranslate({
    required double dx,
    required double dy,
    required double scale,
    required Size view,
  }) {
    final mapW = mapWidthPx * scale;
    final mapH = mapHeightPx * scale;

    final double baseMinDx = (mapW <= view.width) ? 0.0 : (view.width - mapW);
    final double baseMaxDx = (mapW <= view.width) ? (view.width - mapW) : 0.0;

    final double baseMinDy = (mapH <= view.height) ? 0.0 : (view.height - mapH);
    final double baseMaxDy = (mapH <= view.height) ? (view.height - mapH) : 0.0;

    final double minDx = baseMinDx - _panExtra;
    final double maxDx = baseMaxDx + _panExtra;
    final double minDy = baseMinDy - _panExtra;
    final double maxDy = baseMaxDy + _panExtra;

    return Offset(
      dx.clamp(minDx, maxDx).toDouble(),
      dy.clamp(minDy, maxDy).toDouble(),
    );
  }

  void _setTransformCenteredOn({
    required Offset targetPx,
    required double scale,
  }) {
    final size = MediaQuery.of(context).size;

    var dx = (size.width / 2) - targetPx.dx * scale;
    var dy = (size.height / 2) - targetPx.dy * scale;

    final clamped = _clampTranslate(dx: dx, dy: dy, scale: scale, view: size);

    _tc.value = Matrix4.identity()
      ..translate(clamped.dx, clamped.dy)
      ..scale(scale);
  }

  void _centerOnMe({bool initial = false}) {
    final targetPx =
        _mePxClamped() ?? const Offset(mapWidthPx / 2, mapHeightPx / 2);

    final scale = initial
        ? _minScale
        : _currentScale().clamp(_minScale, _maxScale).toDouble();

    _setTransformCenteredOn(targetPx: targetPx, scale: scale);
  }

  void _zoom(double factor) {
    final s = _currentScale();
    final ns = (s * factor).clamp(_minScale, _maxScale).toDouble();

    final size = MediaQuery.of(context).size;
    final cx = size.width / 2;
    final cy = size.height / 2;

    final dx = _tc.value.storage[12];
    final dy = _tc.value.storage[13];

    final newDx = cx - (cx - dx) * (ns / s);
    final newDy = cy - (cy - dy) * (ns / s);

    final clamped = _clampTranslate(dx: newDx, dy: newDy, scale: ns, view: size);

    _tc.value = Matrix4.identity()
      ..translate(clamped.dx, clamped.dy)
      ..scale(ns);
  }

  // ===========================
  // LOCATION
  // ===========================
  Future<void> _initLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;
    // ✅ DEV mock poloha hneď na začiatku _initLocation()
    /* if (useMockLocation) { TESTOVANIE
      // bod 16 (marker 16) = index 15 (0-based)
      const int idx = 15;

      final gps = plantPoints[idx];
      final px = _gpsToPixel(gps) + markerOffsetsPx[idx]; // presne na marker

      setState(() {
        _isOffsite = false;     // aby sa poloha nekryla offsite logikou
        _meGps = gps;
        _mockMePx = px;         // ✅ kreslenie bodky presne na bod 16
        _virtualMePx = null;    // vypni panáčika
        _placeMode = false;
      });

      _centerOnMe(initial: true);
      return;
    }*/

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) return;

    // prvý fixný bod
    final last = await Geolocator.getLastKnownPosition();
    if (last != null && mounted) {
      final within = _isWithinSiteRadius(last);

      if (!within) {
        setState(() {
          _isOffsite = true;
          _meGps = null; // ✅ nevykresľuj reálnu polohu
        });
        await _showOffsiteDialogOnce();
      } else {
        setState(() {
          _isOffsite = false;
          _meGps = LatLng(last.latitude, last.longitude);
        });
        _centerOnMe(initial: true);
      }
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
    );

    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) async {
      if (!mounted) return;

      final within = _isWithinSiteRadius(pos);

      if (!within) {
        // ✅ mimo lokality: nevykresľuj polohu, iba panáčik
        final wasOffsite = _isOffsite;
        setState(() {
          _isOffsite = true;
          _meGps = null;
        });

        // dialóg len pri prechode do offsite (aby neotravoval pri každom ticku)
        if (!wasOffsite) {
          await _showOffsiteDialogOnce();
        }
        return;
      }

      // ✅ v lokalite: ak nepoužívaš panáčika, zobrazuj reálnu polohu
      setState(() {
        _isOffsite = false;
        _meGps = LatLng(pos.latitude, pos.longitude);
      });

      if (_following && _virtualMePx == null) _centerOnMe();
    });
  }

  Future<void> _openPlant(int index) async {
    if (index < 0 || index >= plants.length) return;
    await showPlantDialog(context, plants[index]);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1100)),
    );
  }

  // ===========================
  // VIRTUAL "PANÁČIK" MODE
  // ===========================
  void _clearVirtualPosition() {
    setState(() {
      _virtualMePx = null;
      _placeMode = false;
    });

    // voliteľné: vypni trasu, aby to neostalo naviazané na starý štart
    setState(() {
      _routeRunning = false;
      _routeSegmentsPx = [];
    });

    _toast(context.tr.mapVirtualRemoved);

  }

  Future<void> _togglePlaceMode() async {
    // dovolíme placeMode keď:
    // - si off-map / offsite (t.j. nemáš platnú polohu na mape)
    // - alebo už máš virtuálnu polohu (chceš ju presunúť)
    if (!_isOffMap && _virtualMePx == null) return;

    await _ensureMasks();
    if (_orangeMask == null || _gw == 0 || _gh == 0) {
      _toast(context.tr.mapCannotLoadMap);
      return;
    }

    setState(() {
      _placeMode = !_placeMode;
      _pickMode = false;
    });

    if (_placeMode) {
      _setTransformCenteredOn(
        targetPx: const Offset(mapWidthPx / 2, mapHeightPx / 2),
        scale: _currentScale().clamp(_minScale, _maxScale).toDouble(),
      );
      _toast(context.tr.mapPlaceModeToast);

    }
  }

  void _setVirtualPosition(Offset px) {
    setState(() {
      _virtualMePx = px;
      _placeMode = false;
      _following = true;
    });
    _centerOnMe();
    _toast(context.tr.mapVirtualSet);

  }

  void _handleTapForPlaceMode(Offset viewportLocalPos) {
    if (!_placeMode) return;
    if (_orangeMask == null) return;

    final scenePx = _tc.toScene(viewportLocalPos);
    if (!_insideMap(scenePx)) {
      _toast(context.tr.mapTapOnlyInsideMap);
      return;
    }

    // 1) marker hit
    final plantPx = _computePlantPx();
    const double markerHitRadius = 24.0;

    int? hitIndex;
    double bestD = double.infinity;
    for (int i = 0; i < plantPx.length; i++) {
      final d = (plantPx[i] - scenePx).distance;
      if (d < markerHitRadius && d < bestD) {
        bestD = d;
        hitIndex = i;
      }
    }

    if (hitIndex != null) {
      _setVirtualPosition(plantPx[hitIndex!]);
      return;
    }

    // 2) inak len oranžový chodník (snap)
    final router = _OrangePathRouter(
      mask: _orangeMask!,
      gw: _gw,
      gh: _gh,
      step: _gridStep,
    );

    final snapped = router.snapPx(scenePx);
    if (snapped == null) {
      _toast(context.tr.mapPlaceOnlyOrangeOrMarker);

      return;
    }

    if ((snapped - scenePx).distance > 40) {
      _toast(context.tr.mapPlaceOnlyOrangeOrMarker);

      return;
    }

    _setVirtualPosition(snapped);
  }

  // ===========================
  // ROUTE
  // ===========================
  void _togglePickMode() {
    if (_placeMode) return;
    setState(() => _pickMode = !_pickMode);
  }

  void _toggleSelectPlant(int i) {
    if (_placeMode) return;
    setState(() {
      if (_selectedPlants.contains(i)) {
        _selectedPlants.remove(i);
      } else {
        _selectedPlants.add(i);
      }
    });
  }

  Offset _snapMeToPathOrSelf(Offset mePx) {
    if (_comboMask == null || _gw == 0 || _gh == 0) return mePx;

    final router = _OrangePathRouter(
      mask: _comboMask!,
      gw: _gw,
      gh: _gh,
      step: _gridStep,
    );

    return router.snapPx(mePx) ?? mePx;
  }

  bool _isSpecialIndex(int? plantIndex) =>
      plantIndex != null && _specialPlants.contains(plantIndex);

  Future<void> _startOrStopRoute(List<Offset> plantPx) async {
    if (_placeMode) return;

    if (_routeRunning) {
      setState(() {
        _routeRunning = false;
        _routeSegmentsPx = [];
        _selectedPlants.clear();
        _pickMode = false;
      });
      return;
    }

    var mePx = _mePxClamped();
    if (mePx == null) {
      _toast(context.tr.mapNoLocationUseAvatar);
      return;
    }
    if (_selectedPlants.isEmpty) {
      _toast(context.tr.mapSelectPointsFirst);

      return;
    }

    await _ensureMasks();
    if (_orangeMask == null || _comboMask == null) {
      _toast(context.tr.mapCannotLoadMap);

      return;
    }

    mePx = _snapMeToPathOrSelf(mePx);

    final routerOrange = _OrangePathRouter(
      mask: _orangeMask!,
      gw: _gw,
      gh: _gh,
      step: _gridStep,
    );

    final routerCombo = _OrangePathRouter(
      mask: _comboMask!,
      gw: _gw,
      gh: _gh,
      step: _gridStep,
    );

    final remaining = _selectedPlants.toSet();
    final segments = <List<Offset>>[];

    int? lastVisitedIndex;

    while (remaining.isNotEmpty) {
      final startPx = segments.isEmpty ? mePx : segments.last.last;
      final startIsSpecial = _isSpecialIndex(lastVisitedIndex);

      int? bestTarget;
      double bestCost = double.infinity;

      for (final t in remaining) {
        final useCombo = startIsSpecial || _specialPlants.contains(t);
        final router = useCombo ? routerCombo : routerOrange;

        final cost = router.routeCost(startPx, plantPx[t]);
        if (cost < bestCost) {
          bestCost = cost;
          bestTarget = t;
        }
      }

      if (bestTarget == null || bestCost.isInfinite) {
        _toast(context.tr.mapNoRouteMissingConnection);

        return;
      }

      final useCombo = startIsSpecial || _specialPlants.contains(bestTarget);
      final router = useCombo ? routerCombo : routerOrange;

      final seg = router.routePx(startPx, plantPx[bestTarget]);
      if (seg.isEmpty) {
        _toast(context.tr.mapNoRouteSegment);

        return;
      }

      segments.add(seg);
      remaining.remove(bestTarget);
      lastVisitedIndex = bestTarget;
    }

    setState(() {
      _pickMode = false;
      _routeRunning = true;
      _routeSegmentsPx = segments;
    });
  }

  // ===========================
  // MASK BUILD
  // ===========================
  Future<void> _ensureMasks() async {
    if ((_orangeMask != null && _comboMask != null) || _maskLoading) return;
    _maskLoading = true;

    try {
      final data = await rootBundle.load(mapImageAsset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final img = frame.image;

      final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        _orangeMask = null;
        _comboMask = null;
        return;
      }

      final w = img.width;
      final rgba = byteData.buffer.asUint8List();

      _gw = (w / _gridStep).floor();
      _gh = (img.height / _gridStep).floor();

      final base = Uint8List(_gw * _gh);

      bool isOrange(int r, int g, int b) {
        if (r < 170) return false;
        if (g < 60 || g > 230) return false;
        if (b > 140) return false;
        if (r < g + 15) return false;
        if (g < b) return false;
        return true;
      }

      for (int gy = 0; gy < _gh; gy++) {
        final sy = gy * _gridStep + (_gridStep >> 1);
        for (int gx = 0; gx < _gw; gx++) {
          final sx = gx * _gridStep + (_gridStep >> 1);
          final idxPx = (sy * w + sx) * 4;

          final r = rgba[idxPx];
          final g = rgba[idxPx + 1];
          final b = rgba[idxPx + 2];

          if (isOrange(r, g, b)) {
            base[gy * _gw + gx] = 1;
          }
        }
      }

      final orange = _dilate(base, _gw, _gh);
      final combo = Uint8List.fromList(orange);

      _addProgrammaticExceptions(combo);

      _orangeMask = orange;
      _comboMask = _dilate(combo, _gw, _gh);
    } catch (_) {
      _orangeMask = null;
      _comboMask = null;
    } finally {
      _maskLoading = false;
    }
  }

  Uint8List _dilate(Uint8List m, int w, int h) {
    final out = Uint8List(m.length);
    int idx(int x, int y) => y * w + x;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int v = 0;
        for (int dy = -1; dy <= 1; dy++) {
          final yy = y + dy;
          if (yy < 0 || yy >= h) continue;
          for (int dx = -1; dx <= 1; dx++) {
            final xx = x + dx;
            if (xx < 0 || xx >= w) continue;
            if (m[idx(xx, yy)] == 1) {
              v = 1;
              break;
            }
          }
          if (v == 1) break;
        }
        out[idx(x, y)] = v;
      }
    }
    return out;
  }

  // ==========================================================
  // PROGRAMOVÉ VÝNIMKY (ako si mal)
  // ==========================================================
  void _addProgrammaticExceptions(Uint8List mask) {
    Offset plantAt(int i) {
      final base = _gpsToPixel(plantPoints[i]);
      return base + markerOffsetsPx[i];
    }

    Offset snapToMask(Offset approxPx, {int maxR = 160}) {
      final gx0 = (approxPx.dx / _gridStep).round();
      final gy0 = (approxPx.dy / _gridStep).round();

      bool walk(int gx, int gy) {
        if (gx < 0 || gy < 0 || gx >= _gw || gy >= _gh) return false;
        return mask[gy * _gw + gx] == 1;
      }

      if (walk(gx0, gy0)) {
        return Offset((gx0 + 0.5) * _gridStep, (gy0 + 0.5) * _gridStep);
      }

      for (int r = 1; r <= maxR; r++) {
        for (int dy = -r; dy <= r; dy++) {
          final y = gy0 + dy;
          final x1 = gx0 - r;
          final x2 = gx0 + r;
          if (walk(x1, y)) {
            return Offset((x1 + 0.5) * _gridStep, (y + 0.5) * _gridStep);
          }
          if (walk(x2, y)) {
            return Offset((x2 + 0.5) * _gridStep, (y + 0.5) * _gridStep);
          }
        }
        for (int dx = -r; dx <= r; dx++) {
          final x = gx0 + dx;
          final y1 = gy0 - r;
          final y2 = gy0 + r;
          if (walk(x, y1)) {
            return Offset((x + 0.5) * _gridStep, (y1 + 0.5) * _gridStep);
          }
          if (walk(x, y2)) {
            return Offset((x + 0.5) * _gridStep, (y2 + 0.5) * _gridStep);
          }
        }
      }
      return approxPx;
    }

    void drawPolyline(List<Offset> pts, {double thicknessPx = 12}) {
      if (pts.length < 2) return;

      final radCells = (thicknessPx / _gridStep).ceil().clamp(1, 16);

      void markCell(int gx, int gy) {
        if (gx < 0 || gy < 0 || gx >= _gw || gy >= _gh) return;
        mask[gy * _gw + gx] = 1;
      }

      void markThickAt(Offset p) {
        final gx = (p.dx / _gridStep).round();
        final gy = (p.dy / _gridStep).round();
        for (int dy = -radCells; dy <= radCells; dy++) {
          for (int dx = -radCells; dx <= radCells; dx++) {
            final dd = dx * dx + dy * dy;
            if (dd > radCells * radCells) continue;
            markCell(gx + dx, gy + dy);
          }
        }
      }

      for (int i = 0; i < pts.length - 1; i++) {
        final a = pts[i];
        final b = pts[i + 1];
        final dx = b.dx - a.dx;
        final dy = b.dy - a.dy;
        final dist = math.sqrt(dx * dx + dy * dy);

        final stepPx = (_gridStep / 2).toDouble();
        final n = math.max(1, (dist / stepPx).ceil());

        for (int k = 0; k <= n; k++) {
          final t = k / n;
          final p = Offset(a.dx + dx * t, a.dy + dy * t);
          markThickAt(p);
        }
      }
    }

    final p26 = plantAt(25);
    final p13 = plantAt(12);
    final p14 = plantAt(13);
    final p8 = plantAt(7);
    final p9 = plantAt(8);
    final p10 = plantAt(9);

    // 13 + 14
    final jLeft = snapToMask(const Offset(175, 760));
    const mid13_14 = Offset(300, 745);
    drawPolyline([jLeft, mid13_14, p13], thicknessPx: 12);
    drawPolyline([jLeft, mid13_14, p14], thicknessPx: 12);

    // 26: spodný vstup + zvislá + vetvy
    final j26Bottom = snapToMask(const Offset(640, 1045));
    final j26Top = snapToMask(const Offset(740, 645));

    final v1 = Offset(j26Bottom.dx + 8, j26Bottom.dy - 140);
    final v2 = Offset(j26Bottom.dx + 14, j26Bottom.dy - 300);
    final v3 = Offset(j26Bottom.dx + 20, j26Bottom.dy - 460);
    final v4 = Offset(j26Top.dx - 30, j26Top.dy + 70);
    drawPolyline([j26Bottom, v1, v2, v3, v4, j26Top], thicknessPx: 12);

    final b26a = Offset(j26Bottom.dx + 28, j26Bottom.dy - 110);
    final b26b = Offset(j26Bottom.dx + 52, j26Bottom.dy - 220);
    drawPolyline([j26Bottom, b26a, b26b, p26], thicknessPx: 12);

    final t26a = Offset(j26Top.dx - 80, j26Top.dy + 70);
    drawPolyline([j26Top, t26a, p26], thicknessPx: 12);

    // FIX: 10 -> spodný vstup
    final p10a = Offset(p10.dx + 35, p10.dy + 30);
    final p10b = Offset(p10.dx + 75, p10.dy + 70);
    final p10c = Offset(j26Bottom.dx - 40, j26Bottom.dy - 20);
    drawPolyline([p10, p10a, p10b, p10c, j26Bottom], thicknessPx: 12);

    // 10: aj alternatívne napojenia
    final j10Left = snapToMask(const Offset(485, 945));
    final j10Right = snapToMask(const Offset(585, 900));
    drawPolyline([j10Left, Offset(j10Left.dx + 30, j10Left.dy - 5), p10],
        thicknessPx: 12);
    drawPolyline([j10Right, Offset(j10Right.dx - 20, j10Right.dy + 25), p10],
        thicknessPx: 12);

    // 8 + 9
    final jBottomLeft = snapToMask(const Offset(575, 1315));
    final jBottomRight = snapToMask(const Offset(705, 1315));

    drawPolyline([jBottomLeft, const Offset(605, 1270), p8], thicknessPx: 12);
    drawPolyline([jBottomRight, const Offset(660, 1255), p8], thicknessPx: 12);

    drawPolyline([jBottomLeft, const Offset(630, 1250), p9], thicknessPx: 12);
    drawPolyline([jBottomRight, const Offset(690, 1235), p9], thicknessPx: 12);
  }

  Color _markerColor(int i) {
    if (_pickMode) {
      if (_selectedPlants.contains(i)) return Colors.orange.withOpacity(0.95);
      return Colors.red.withOpacity(0.95);
    }
    return Colors.black.withOpacity(0.90);
  }

  // ===========================
  // BUILD
  // ===========================
  @override
  Widget build(BuildContext context) {
    final plantPx = _computePlantPx();

    final meRaw = _mePxRaw();
    final meClamp = _mePxClamped();
    final meInside = (meRaw != null) ? _insideMap(meRaw) : false;

    const double markerSize = 42;
    const double markerHalf = markerSize / 2;

    // ✅ tlačidlo panáčika:
    // - zobraz ak si mimo mapy alebo offsite (raw null => offmap true)
    // - alebo ak už je virtuálna poloha nastavená (aby sa dala zmazať)
    final showAvatarBtn = _isOffMap || _virtualMePx != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (d) => _handleTapForPlaceMode(d.localPosition),
              child: InteractiveViewer(
                transformationController: _tc,
                boundaryMargin: const EdgeInsets.all(_panExtra),
                minScale: _minScale,
                maxScale: _maxScale,
                constrained: false,
                clipBehavior: Clip.hardEdge,
                onInteractionStart: (_) => _following = false,
                onInteractionEnd: (_) {
                  final size = MediaQuery.of(context).size;
                  final s =
                  _currentScale().clamp(_minScale, _maxScale).toDouble();

                  final dx = _tc.value.storage[12];
                  final dy = _tc.value.storage[13];

                  final clamped =
                  _clampTranslate(dx: dx, dy: dy, scale: s, view: size);

                  _tc.value = Matrix4.identity()
                    ..translate(clamped.dx, clamped.dy)
                    ..scale(s);
                },
                child: SizedBox(
                  width: mapWidthPx,
                  height: mapHeightPx,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          mapImageAsset,
                          fit: BoxFit.fill,
                          errorBuilder: (ctx, __, ___) => Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: Text(
                              ctx.tr.mapAssetError,
                              textAlign: TextAlign.center,
                            ),
                          ),

                        ),
                      ),

                      // ✅ zvýraznenie oranžovej časti pri placeMode
                      if (_placeMode &&
                          _orangeMask != null &&
                          _gw > 0 &&
                          _gh > 0)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: OrangeMaskOverlayPainter(
                                mask: _orangeMask!,
                                gw: _gw,
                                gh: _gh,
                                step: _gridStep,
                              ),
                            ),
                          ),
                        ),

                      // TRASA
                      if (_routeRunning && _routeSegmentsPx.isNotEmpty)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _MultiRoutePainter(_routeSegmentsPx),
                            ),
                          ),
                        ),

                      // Markery
                      for (int i = 0; i < plantPx.length; i++)
                        if (_insideMap(plantPx[i]))
                          Positioned(
                            left: plantPx[i].dx - markerHalf,
                            top: plantPx[i].dy - markerHalf,
                            width: markerSize,
                            height: markerSize,
                            child: GestureDetector(
                              onTap: () {
                                if (_placeMode) {
                                  _setVirtualPosition(plantPx[i]);
                                  return;
                                }
                                if (_pickMode) {
                                  _toggleSelectPlant(i);
                                } else {
                                  _openPlant(i);
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _markerColor(i),
                                  border:
                                  Border.all(color: Colors.white30, width: 2),
                                  boxShadow: _placeMode
                                      ? const [
                                    BoxShadow(
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                      color: Color(0x8800BCD4),
                                    ),
                                  ]
                                      : null,
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),

                      // TY (bodka) — zobraz iba ak máme platný meRaw (t.j. nie offsite bez panáčika)
                      if (meRaw != null)
                        Positioned(
                          left: (meInside ? meRaw.dx : (meClamp?.dx ?? 0)) - 12,
                          top: (meInside ? meRaw.dy : (meClamp?.dy ?? 0)) - 12,
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // malý hint banner
          if (_placeMode)
            Positioned(
              left: 12,
              right: 12,
              top: 44,
              child: IgnorePointer(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1B22).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x5500BCD4)),
                  ),child: Text(
                  context.tr.mapPlaceModeHintBanner,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                ),
              ),
            ),

          // Buttons
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'loc',
                  onPressed: () {
                    _following = true;
                    _centerOnMe();
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 12),

                // PANÁČIK – iba ak si mimo mapy/offsite alebo už máš virtuálnu polohu
                if (showAvatarBtn) ...[
                  FloatingActionButton(
                    heroTag: 'avatar',
                    onPressed: () {
                      if (_virtualMePx != null && !_placeMode) {
                        _clearVirtualPosition();
                        return;
                      }
                      _togglePlaceMode();
                    },
                    child: Icon(
                      _placeMode
                          ? Icons.close
                          : (_virtualMePx != null
                          ? Icons.person_off
                          : Icons.person_pin_circle),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                FloatingActionButton(
                  heroTag: 'pick',
                  onPressed: _togglePickMode,
                  child: Icon(_pickMode ? Icons.flag : Icons.flag_outlined),
                ),
                const SizedBox(height: 12),

                FloatingActionButton(
                  heroTag: 'startStop',
                  onPressed: () => _startOrStopRoute(plantPx),
                  child:
                  Icon(_routeRunning ? Icons.stop_circle : Icons.play_arrow),
                ),
                const SizedBox(height: 12),

                FloatingActionButton(
                  heroTag: 'plus',
                  onPressed: () => _zoom(1.25),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 12),

                FloatingActionButton(
                  heroTag: 'minus',
                  onPressed: () => _zoom(0.8),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _tc.dispose();
    super.dispose();
  }
}

// ======================================================
// ROUTER: A* po walk mask (0/1)
// ======================================================
class _OrangePathRouter {
  final Uint8List mask;
  final int gw, gh;
  final int step;

  _OrangePathRouter({
    required this.mask,
    required this.gw,
    required this.gh,
    required this.step,
  });

  int _idx(int x, int y) => y * gw + x;

  bool _walk(int x, int y) {
    if (x < 0 || y < 0 || x >= gw || y >= gh) return false;
    return mask[_idx(x, y)] == 1;
  }

  (int, int)? _snap(Offset px) {
    final gx0 = (px.dx / step).round();
    final gy0 = (px.dy / step).round();

    if (_walk(gx0, gy0)) return (gx0, gy0);

    const int maxR = 80;
    for (int r = 1; r <= maxR; r++) {
      for (int dy = -r; dy <= r; dy++) {
        final y = gy0 + dy;
        final x1 = gx0 - r;
        final x2 = gx0 + r;
        if (_walk(x1, y)) return (x1, y);
        if (_walk(x2, y)) return (x2, y);
      }
      for (int dx = -r; dx <= r; dx++) {
        final x = gx0 + dx;
        final y1 = gy0 - r;
        final y2 = gy0 + r;
        if (_walk(x, y1)) return (x, y1);
        if (_walk(x, y2)) return (x, y2);
      }
    }
    return null;
  }

  Offset? snapPx(Offset px) {
    final s = _snap(px);
    if (s == null) return null;
    final (sx, sy) = s;
    return Offset((sx + 0.5) * step, (sy + 0.5) * step);
  }

  double routeCost(Offset startPx, Offset endPx) {
    final s = _snap(startPx);
    final t = _snap(endPx);
    if (s == null || t == null) return double.infinity;

    final (sx, sy) = s;
    final (tx, ty) = t;

    final n = gw * gh;
    final gScore = List<double>.filled(n, double.infinity);
    final closed = Uint8List(n);

    final sId = _idx(sx, sy);
    final tId = _idx(tx, ty);

    double h(int x, int y) {
      final dx = (x - tx).toDouble();
      final dy = (y - ty).toDouble();
      return math.sqrt(dx * dx + dy * dy);
    }

    final open = _MinHeap();
    gScore[sId] = 0;
    open.push(_HeapItem(sId, h(sx, sy)));

    int idToX(int id) => id % gw;
    int idToY(int id) => id ~/ gw;

    const dirs = <(int, int, double)>[
      (-1, 0, 1),
      (1, 0, 1),
      (0, -1, 1),
      (0, 1, 1),
      (-1, -1, 1.41421356237),
      (1, -1, 1.41421356237),
      (-1, 1, 1.41421356237),
      (1, 1, 1.41421356237),
    ];

    while (open.isNotEmpty) {
      final cur = open.pop();
      final u = cur.node;

      if (closed[u] == 1) continue;
      closed[u] = 1;

      if (u == tId) return gScore[u];

      final ux = idToX(u);
      final uy = idToY(u);

      for (final (dx, dy, w) in dirs) {
        final vx = ux + dx;
        final vy = uy + dy;
        if (!_walk(vx, vy)) continue;

        final v = _idx(vx, vy);
        if (closed[v] == 1) continue;

        final tentative = gScore[u] + w;
        if (tentative < gScore[v]) {
          gScore[v] = tentative;
          final f = tentative + h(vx, vy);
          open.push(_HeapItem(v, f));
        }
      }
    }

    return double.infinity;
  }

  List<Offset> routePx(Offset startPx, Offset endPx) {
    final s = _snap(startPx);
    final t = _snap(endPx);
    if (s == null || t == null) return const [];

    final (sx, sy) = s;
    final (tx, ty) = t;

    final n = gw * gh;
    final gScore = List<double>.filled(n, double.infinity);
    final cameFrom = List<int>.filled(n, -1);
    final closed = Uint8List(n);

    final sId = _idx(sx, sy);
    final tId = _idx(tx, ty);

    double h(int x, int y) {
      final dx = (x - tx).toDouble();
      final dy = (y - ty).toDouble();
      return math.sqrt(dx * dx + dy * dy);
    }

    final open = _MinHeap();
    gScore[sId] = 0;
    open.push(_HeapItem(sId, h(sx, sy)));

    int idToX(int id) => id % gw;
    int idToY(int id) => id ~/ gw;

    const dirs = <(int, int, double)>[
      (-1, 0, 1),
      (1, 0, 1),
      (0, -1, 1),
      (0, 1, 1),
      (-1, -1, 1.41421356237),
      (1, -1, 1.41421356237),
      (-1, 1, 1.41421356237),
      (1, 1, 1.41421356237),
    ];

    while (open.isNotEmpty) {
      final cur = open.pop();
      final u = cur.node;

      if (closed[u] == 1) continue;
      closed[u] = 1;

      if (u == tId) break;

      final ux = idToX(u);
      final uy = idToY(u);

      for (final (dx, dy, w) in dirs) {
        final vx = ux + dx;
        final vy = uy + dy;
        if (!_walk(vx, vy)) continue;

        final v = _idx(vx, vy);
        if (closed[v] == 1) continue;

        final tentative = gScore[u] + w;
        if (tentative < gScore[v]) {
          gScore[v] = tentative;
          cameFrom[v] = u;
          final f = tentative + h(vx, vy);
          open.push(_HeapItem(v, f));
        }
      }
    }

    if (tId != sId && cameFrom[tId] == -1) return const [];

    final rev = <int>[];
    int cur = tId;
    rev.add(cur);
    while (cur != sId) {
      final p = cameFrom[cur];
      if (p == -1) break;
      cur = p;
      rev.add(cur);
    }

    final pathIds = rev.reversed.toList();

    final out = <Offset>[];
    for (final id in pathIds) {
      final x = idToX(id);
      final y = idToY(id);
      out.add(Offset((x + 0.5) * step, (y + 0.5) * step));
    }
    return out;
  }
}

// ======================================================
// MULTI COLOR ROUTE PAINTER
// ======================================================
class _MultiRoutePainter extends CustomPainter {
  final List<List<Offset>> segments;
  _MultiRoutePainter(this.segments);

  static final List<Color> _cycle = [
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int si = 0; si < segments.length; si++) {
      final seg = segments[si];
      if (seg.length < 2) continue;

      final paint = Paint()
        ..color = _cycle[si % _cycle.length].withOpacity(0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = ui.Path()..moveTo(seg[0].dx, seg[0].dy);
      for (int i = 1; i < seg.length; i++) {
        path.lineTo(seg[i].dx, seg[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MultiRoutePainter oldDelegate) =>
      oldDelegate.segments != segments;
}

// ======================================================
// MIN HEAP
// ======================================================
class _HeapItem {
  final int node;
  final double prio;
  const _HeapItem(this.node, this.prio);
}

class _MinHeap {
  final List<_HeapItem> _a = [];
  bool get isNotEmpty => _a.isNotEmpty;

  void push(_HeapItem x) {
    _a.add(x);
    _siftUp(_a.length - 1);
  }

  _HeapItem pop() {
    final res = _a.first;
    final last = _a.removeLast();
    if (_a.isNotEmpty) {
      _a[0] = last;
      _siftDown(0);
    }
    return res;
  }

  void _siftUp(int i) {
    while (i > 0) {
      final p = (i - 1) >> 1;
      if (_a[p].prio <= _a[i].prio) break;
      final tmp = _a[p];
      _a[p] = _a[i];
      _a[i] = tmp;
      i = p;
    }
  }

  void _siftDown(int i) {
    final n = _a.length;
    while (true) {
      final l = i * 2 + 1;
      final r = l + 1;
      int m = i;

      if (l < n && _a[l].prio < _a[m].prio) m = l;
      if (r < n && _a[r].prio < _a[m].prio) m = r;

      if (m == i) break;
      final tmp = _a[m];
      _a[m] = _a[i];
      _a[i] = tmp;
      i = m;
    }
  }
}