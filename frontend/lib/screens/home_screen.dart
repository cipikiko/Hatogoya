import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/neon.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/news_item.dart';
import '../services/news_service.dart';
import '../services/lang_service.dart';
import '../lang/strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // paging
  bool _seeAll = false;
  int _visibleCount = 2;

  static const String _topStoryUrl = 'https://www.arboretumbaexem.com/#education';

  // refresh trigger (keď klikneš Retry)
  int _reloadTick = 0;

  Future<void> _openUrl(String url) async {
    final tr = context.tr;
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.homeCouldNotOpen)),
      );
    }
  }

  void _retry() {
    setState(() {
      _reloadTick++; // donúti FutureBuilder spraviť nový future
    });
  }

  void _onSeeAllPressed(int total) {
    setState(() {
      _seeAll = true;
      _visibleCount = total >= 5 ? 5 : total;
    });
  }

  void _loadMore(int total) {
    setState(() {
      final next = _visibleCount + 5;
      _visibleCount = next > total ? total : next;
    });
  }

  @override
  Widget build(BuildContext context) {
    // keď sa zmení LangService.locale, rebuildne sa aj FutureBuilder
    return ValueListenableBuilder<Locale>(
      valueListenable: LangService.locale,
      builder: (context, _, __) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppTheme.mode,
          builder: (context, _, __) {
            final tr = context.tr;
            final double topPad = MediaQuery.of(context).padding.top;

            final Future<List<NewsItem>> future = NewsService.fetchLatest();

            return SingleChildScrollView(
              padding: EdgeInsets.only(top: topPad, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========= Header =========
                  PulseGlow(
                    color: AppTokens.green400,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppTokens.tealGradient,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
                      child: Row(
                        children: const [
                          _HeaderIcon(),
                          SizedBox(width: 12),
                          _HeaderText(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ========= Body =========
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FutureBuilder<List<NewsItem>>(
                      key: ValueKey('${LangService.code}-$_reloadTick'),
                      future: future,
                      builder: (context, snap) {
                        final isLoading =
                            snap.connectionState == ConnectionState.waiting ||
                                snap.connectionState == ConnectionState.active;

                        final errorMessage = snap.hasError ? tr.homeFailedLoad : null;

                        final items = snap.data ?? const <NewsItem>[];

                        return _buildBody(
                          context,
                          isLoading: isLoading,
                          errorMessage: errorMessage,
                          latestItems: items,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, {
        required bool isLoading,
        required String? errorMessage,
        required List<NewsItem> latestItems,
      }) {
    final tr = context.tr;

    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(tr.homeTopStory),
          const SizedBox(height: 10),
          const _SkeletonCard(height: 110),
          const SizedBox(height: 16),

          // ✅ aj pri loadingu ukážeme skeleton pre otváracie hodiny
          const _SkeletonCard(height: 92),
          const SizedBox(height: 16),

          _SectionTitle(tr.homeLatest),
          const SizedBox(height: 10),
          const _SkeletonCard(height: 72),
          const SizedBox(height: 12),
          const _SkeletonCard(height: 72),
        ],
      );
    }

    if (errorMessage != null) {
      return NeonCard(
        color: AppTokens.cardSurface,
        shadows: AppTokens.tileShadow,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppTokens.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(errorMessage, style: TextStyle(color: AppTokens.textSecondary)),
            ),
            TextButton(
              onPressed: _retry,
              child: Text(tr.homeRetry, style: TextStyle(color: AppTokens.emerald500)),
            ),
          ],
        ),
      );
    }

    final total = latestItems.length;
    final bool showSeeAll = !_seeAll && total > 2;

    final int shown = _seeAll
        ? (_visibleCount > total ? total : _visibleCount)
        : (total >= 2 ? 2 : total);

    final visibleItems = latestItems.take(shown).toList();
    final bool canLoadMore = _seeAll && shown < total;

    final topStory = NewsItem(
      title: tr.homeTopEduTitle,
      subtitle: tr.homeTopEduSubtitle,
      tag: tr.homeTagFeatured,
      url: _topStoryUrl,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(tr.homeTopStory),
        const SizedBox(height: 10),
        _TopStoryCard(
          item: topStory,
          onTap: () => _openUrl(topStory.url),
        ),
        const SizedBox(height: 16),

        // ✅ NOVÉ: Otváracie hodiny (medzi Top príbeh a Najnovšie)
        const _OpeningHoursCard(),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _SectionTitle(tr.homeLatest)),
            if (showSeeAll)
              TextButton(
                onPressed: () => _onSeeAllPressed(total),
                child: Text(tr.homeSeeAll, style: TextStyle(color: AppTokens.emerald500)),
              )
            else if (_seeAll)
              TextButton(
                onPressed: () {
                  setState(() {
                    _seeAll = false;
                    _visibleCount = 2;
                  });
                },
                child: Text(tr.homeShowLess, style: TextStyle(color: AppTokens.emerald500)),
              )
          ],
        ),
        const SizedBox(height: 6),

        if (total == 0)
          NeonCard(
            color: AppTokens.cardSurface,
            shadows: AppTokens.tileShadow,
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, color: AppTokens.textSecondary, size: 34),
                const SizedBox(height: 10),
                Text(
                  tr.homeEmptyTitle,
                  style: TextStyle(
                    color: AppTokens.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tr.homeEmptySubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTokens.textSecondary),
                ),
              ],
            ),
          )
        else
          ...visibleItems.map(
                (n) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _NewsRowCard(
                item: n,
                onTap: () => _openUrl(n.url),
              ),
            ),
          ),

        if (canLoadMore) ...[
          const SizedBox(height: 4),
          NeonCard(
            color: AppTokens.cardSurface,
            shadows: AppTokens.tileShadow,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tr.homeShowingOf(shown, total),
                    style: TextStyle(color: AppTokens.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => _loadMore(total),
                  child: Text(tr.homeLoadMore, style: TextStyle(color: AppTokens.emerald500)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/* ================== Header ================== */

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: const Center(
          child: BounceGentle(
            child: Image(
              image: AssetImage('lib/utils/images/pine.png'),
              width: 28,
              height: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.homeHeaderTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          tr.homeHeaderSubtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppTokens.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    );
  }
}

/* ================== Otváracie hodiny ================== */

/* ================== Otváracie hodiny ================== */

class _OpeningHoursCard extends StatelessWidget {
  const _OpeningHoursCard();

  static const int _openHour = 9;
  static const int _closeHour = 18;

  DateTime _now() {
    // ak máš timezone initnuté, použije sa tz.local; inak fallback na DateTime.now()
    try {
      return tz.TZDateTime.now(tz.local);
    } catch (_) {
      return DateTime.now();
    }
  }

  bool _isOpenNow(DateTime now) {
    // Nedeľa = zatvorené
    if (now.weekday == DateTime.sunday) return false;

    final start = DateTime(now.year, now.month, now.day, _openHour, 0);
    final end = DateTime(now.year, now.month, now.day, _closeHour, 0);

    // otvorené v intervale <09:00, 18:00)
    return !now.isBefore(start) && now.isBefore(end);
  }

  Widget _row({
    required String day,
    required String hours,
    required bool highlight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              day,
              style: TextStyle(
                color: highlight ? AppTokens.textPrimary : AppTokens.textSecondary,
                fontWeight: highlight ? FontWeight.w900 : FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hours,
              style: TextStyle(
                color: highlight ? AppTokens.textPrimary : AppTokens.textSecondary,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    final now = _now();
    final openNow = _isOpenNow(now);
    bool isToday(int weekday) => now.weekday == weekday;

    const hoursOpen = '09:00 – 18:00';

    final title = tr.openingHoursTitle;
    final statusText = openNow ? tr.openingHoursNowOpen : tr.openingHoursNowClosed;
    final note = tr.openingHoursNote;

    return NeonCard(
      color: AppTokens.cardSurface,
      shadows: AppTokens.tileShadow,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTokens.tealGradient,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  boxShadow: AppTokens.glow(AppTokens.emerald500, blur: 10, alpha: .12),
                ),
                child: const Icon(Icons.schedule_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTokens.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: openNow ? AppTokens.emerald500 : Colors.red,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppTokens.divider),
          const SizedBox(height: 6),

          _row(day: tr.weekdayMon, hours: hoursOpen, highlight: isToday(DateTime.monday)),
          _row(day: tr.weekdayTue, hours: hoursOpen, highlight: isToday(DateTime.tuesday)),
          _row(day: tr.weekdayWed, hours: hoursOpen, highlight: isToday(DateTime.wednesday)),
          _row(day: tr.weekdayThu, hours: hoursOpen, highlight: isToday(DateTime.thursday)),
          _row(day: tr.weekdayFri, hours: hoursOpen, highlight: isToday(DateTime.friday)),
          _row(day: tr.weekdaySat, hours: hoursOpen, highlight: isToday(DateTime.saturday)),
          _row(
            day: tr.weekdaySun,
            hours: tr.openingHoursClosed,
            highlight: isToday(DateTime.sunday),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTokens.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              border: Border.all(color: AppTokens.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppTokens.emerald500, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      color: AppTokens.textSecondary,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================== UI Cards ================== */

class _TopStoryCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;

  const _TopStoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardSurface,
      shadows: AppTokens.tileShadow,
      padding: const EdgeInsets.all(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppTokens.statGreen(),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                boxShadow: AppTokens.glow(AppTokens.emerald500, blur: 10),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TagPill(item.tag),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: AppTokens.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(item.subtitle, style: TextStyle(color: AppTokens.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Icon(Icons.chevron_right, color: AppTokens.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _NewsRowCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;

  const _NewsRowCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardSurface,
      shadows: AppTokens.tileShadow,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTokens.textPrimary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                border: Border.all(color: AppTokens.cardBorder),
              ),
              child: Icon(Icons.article_outlined, color: AppTokens.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTokens.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTokens.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTokens.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  const _TagPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTokens.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTokens.cardBorder),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

/* ================== Skeleton ================== */

class _SkeletonCard extends StatelessWidget {
  final double height;
  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardSurface,
      shadows: AppTokens.tileShadow,
      padding: const EdgeInsets.all(0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppTokens.textPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: AppTokens.cardBorder),
        ),
      ),
    );
  }
}
