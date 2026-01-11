import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'assets/assets.dart';
import 'plant_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const double _panExtra = 180.0;
  final TransformationController _tc = TransformationController();
  StreamSubscription<Position>? _posSub;
  static const bool useMockLocation = true;
  static const LatLng mockMeGps = LatLng(51.226732, 5.876960); // sem dáš vlastnú
  LatLng? _meGps;
  bool _following = true;

  double _minScale = 0.2;
  final double _maxScale = 8.0;

  // ROUTE UI
  bool _pickMode = false; // vlajka režim
  bool _routeRunning = false;

  final List<int> _selectedPlants = [];
  List<Offset> _routePolylinePx = [];

  // ========= ORANGE-PATH ROUTER (automaticky z map.png) =========
  static const int _gridStep = 4; // 4 presnejšie, 5 rýchlejšie
  Uint8List? _walkMask; // 0/1 mriežka (len oranžová)
  int _gw = 0, _gh = 0;
  bool _maskLoading = false;

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

      // prednačítaj masku (neblokuj UI)
      _ensureWalkMask();

      await _initLocation();
    });
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

  Offset? _mePxRaw() => (_meGps == null) ? null : _gpsToPixel(_meGps!);

  Offset? _mePxClamped() {
    final raw = _mePxRaw();
    if (raw == null) return null;
    return _clampToMap(raw);
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
    if (useMockLocation) {
      setState(() {
        _meGps = mockMeGps;
      });
      _centerOnMe(initial: true);
      return;
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) return;

    final last = await Geolocator.getLastKnownPosition();
    if (last != null && mounted) {
      setState(() {
        _meGps = LatLng(last.latitude, last.longitude);
      });
      _centerOnMe(initial: true);
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
    );

    _posSub?.cancel();
    _posSub =
        Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
          if (!mounted) return;

          setState(() {
            _meGps = LatLng(pos.latitude, pos.longitude);
          });

          if (_following) _centerOnMe();
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
  // ROUTE (pick + start/stop)
  // ===========================
  void _togglePickMode() {
    setState(() => _pickMode = !_pickMode);
  }

  void _toggleSelectPlant(int i) {
    setState(() {
      if (_selectedPlants.contains(i)) {
        _selectedPlants.remove(i);
      } else {
        _selectedPlants.add(i);
      }
    });
  }

  /// Snap tvojej polohy na najbližší oranžový chodník (ak sa dá).
  Offset _snapMeToOrangeOrSelf(Offset mePx) {
    if (_walkMask == null || _gw == 0 || _gh == 0) return mePx;

    final router = _OrangePathRouter(
      mask: _walkMask!,
      gw: _gw,
      gh: _gh,
      step: _gridStep,
    );

    return router.snapPx(mePx) ?? mePx;
  }

  Future<void> _startOrStopRoute(List<Offset> plantPx) async {
    // STOP => vypni trasu + reset výberu
    if (_routeRunning) {
      setState(() {
        _routeRunning = false;
        _routePolylinePx = [];
        _selectedPlants.clear(); // reset výberu
        _pickMode = false;
      });
      return;
    }

    // START
    var mePx = _mePxClamped();
    if (mePx == null) {
      _toast('Nemám polohu (GPS).');
      return;
    }
    if (_selectedPlants.isEmpty) {
      _toast('Najprv vyber body.');
      return;
    }

    await _ensureWalkMask();
    if (_walkMask == null) {
      _toast('Neviem načítať mapu.');
      return;
    }

    // ✅ prilep štart na chodník
    mePx = _snapMeToOrangeOrSelf(mePx);

    final router = _OrangePathRouter(
      mask: _walkMask!,
      gw: _gw,
      gh: _gh,
      step: _gridStep,
    );

    // poradie podľa NAJKRATŠEJ CESTY PO ORANŽOVEJ (A* cost)
    final remaining = _selectedPlants.toSet();
    final full = <Offset>[];

    while (remaining.isNotEmpty) {
      final startPx = full.isEmpty ? mePx : full.last;

      int? bestTarget;
      double bestCost = double.infinity;

      for (final t in remaining) {
        final cost = router.routeCost(startPx, plantPx[t]);
        if (cost < bestCost) {
          bestCost = cost;
          bestTarget = t;
        }
      }

      if (bestTarget == null || bestCost.isInfinite) {
        _toast('Nenašiel som cestu po oranžovej (chýba spojenie).');
        return;
      }

      final seg = router.routePx(startPx, plantPx[bestTarget]);
      if (seg.isEmpty) {
        _toast('Nenašiel som cestu po oranžovej (segment).');
        return;
      }

      if (full.isEmpty) {
        full.addAll(seg);
      } else {
        full.addAll(seg.skip(1));
      }

      remaining.remove(bestTarget);
    }

    setState(() {
      _pickMode = false;
      _routeRunning = true;
      _routePolylinePx = full; // bez simplifikácie => nikdy nerezať mimo oranžovej
    });
  }

  // ===========================
  // ORANGE MASK BUILD (z map.png)
  // ===========================
  Future<void> _ensureWalkMask() async {
    if (_walkMask != null || _maskLoading) return;
    _maskLoading = true;

    try {
      final data = await rootBundle.load(mapImageAsset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final img = frame.image;

      final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        _walkMask = null;
        return;
      }

      final w = img.width;
      final h = img.height;
      final rgba = byteData.buffer.asUint8List();

      _gw = (w / _gridStep).floor();
      _gh = (h / _gridStep).floor();

      final mask = Uint8List(_gw * _gh);

      bool isOrange(int r, int g, int b) {
        // tolerantné: oranžová chodníková farba
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
            mask[gy * _gw + gx] = 1;
          }
        }
      }

      // dilatácia 1x (zhrubni chodník)
      _walkMask = _dilate(mask, _gw, _gh);
    } catch (_) {
      _walkMask = null;
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
    final plantPx = List<Offset>.generate(plantPoints.length, (i) {
      final base = _gpsToPixel(plantPoints[i]);
      return base + markerOffsetsPx[i];
    });

    final meRaw = _mePxRaw();
    final meClamp = _mePxClamped();
    final meInside = (meRaw != null) ? _insideMap(meRaw) : false;

    const double markerSize = 42;
    const double markerHalf = markerSize / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
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
                final s = _currentScale().clamp(_minScale, _maxScale).toDouble();

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
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: const Text(
                            'MAP ASSET ERROR\n(skús pubspec.yaml assets)',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    // TRASA: ZELENÁ a iba po oranžovej
                    if (_routeRunning && _routePolylinePx.length >= 2)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _RoutePainter(_routePolylinePx),
                          ),
                        ),
                      ),

                    // Rastliny
                    for (int i = 0; i < plantPx.length; i++)
                      if (_insideMap(plantPx[i]))
                        Positioned(
                          left: plantPx[i].dx - markerHalf,
                          top: plantPx[i].dy - markerHalf,
                          width: markerSize,
                          height: markerSize,
                          child: GestureDetector(
                            onTap: () {
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
                                border: Border.all(
                                    color: Colors.white30, width: 2),
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

                    // TY (bodka)
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

                FloatingActionButton(
                  heroTag: 'pick',
                  onPressed: _togglePickMode,
                  child: Icon(_pickMode ? Icons.flag : Icons.flag_outlined),
                ),
                const SizedBox(height: 12),

                FloatingActionButton(
                  heroTag: 'startStop',
                  onPressed: () => _startOrStopRoute(plantPx),
                  child: Icon(
                      _routeRunning ? Icons.stop_circle : Icons.play_arrow),
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
// ROUTER: A* len po oranžových pixeloch (walk mask)
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

  // snap px -> najbližší walkable grid bod
  (int, int)? _snap(Offset px) {
    final gx0 = (px.dx / step).round();
    final gy0 = (px.dy / step).round();

    if (_walk(gx0, gy0)) return (gx0, gy0);

    const int maxR = 40;
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

  /// Verejný snap: vráti pixel pozíciu na najbližšom oranžovom bode (alebo null).
  Offset? snapPx(Offset px) {
    final s = _snap(px);
    if (s == null) return null;
    final (sx, sy) = s;
    return Offset((sx + 0.5) * step, (sy + 0.5) * step);
  }

  // len zistí dĺžku najkratšej cesty po oranžovej (bez rekonštrukcie)
  double routeCost(Offset startPx, Offset endPx) {
    final s = _snap(startPx);
    final t = _snap(endPx);
    if (s == null || t == null) return double.infinity;

    final (sx, sy) = s;
    final (tx, ty) = t;

    final n = gw * gh;
    final gScore = List<double>.filled(n, double.infinity);
    final closed = Uint8List(n);

    int sId = _idx(sx, sy);
    int tId = _idx(tx, ty);

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

  // vráti konkrétnu cestu (polyline bodov po oranžovej)
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

    int sId = _idx(sx, sy);
    int tId = _idx(tx, ty);

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

    // rekonštrukcia
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

    // grid -> px
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
// GREEN ROUTE PAINTER
// ======================================================
class _RoutePainter extends CustomPainter {
  final List<Offset> poly;
  _RoutePainter(this.poly);

  @override
  void paint(Canvas canvas, Size size) {
    if (poly.length < 2) return;

    final paint = Paint()
      ..color = Colors.green.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = ui.Path()..moveTo(poly[0].dx, poly[0].dy);
    for (int i = 1; i < poly.length; i++) {
      path.lineTo(poly[i].dx, poly[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => oldDelegate.poly != poly;
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
