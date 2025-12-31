import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/neon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // TODO: neskôr toto nahradíš dátami z API
  static const List<_NewsItem> _mockNews = [
    _NewsItem(
      title: 'New plants added to the discovery map',
      subtitle: 'Explore fresh species and unlock new zones.',
      tag: 'Update',
    ),
    _NewsItem(
      title: 'Daily challenges are getting a refresh',
      subtitle: 'More variety, better rewards, and streak boosts.',
      tag: 'Announcement',
    ),
    _NewsItem(
      title: 'Tip: Scan leaves in natural light',
      subtitle: 'You’ll get more accurate matches and faster results.',
      tag: 'Tip',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ Donúti HomeScreen rebuildnúť sa pri prepnutí ThemeMode,
    // aj keď máš v MainScreen vnorený Navigator.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.mode,
      builder: (context, _, __) {
        final double topPad = MediaQuery.of(context).padding.top;

        // Tieto booleany si neskôr nahradíš reálnym stavom (FutureBuilder/provider/bloc)
        final bool isLoading = false;
        final String? errorMessage = null;
        final List<_NewsItem> items = _mockNews;

        return SingleChildScrollView(
          padding: EdgeInsets.only(top: topPad, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========= Header pre novinky =========
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
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                          ),
                          child: const Center(
                            child: BounceGentle(
                              child: Icon(Icons.newspaper_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const _HeaderText(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ========= Obsah noviniek =========
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildBody(
                  context,
                  isLoading: isLoading,
                  errorMessage: errorMessage,
                  items: items,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, {
        required bool isLoading,
        required String? errorMessage,
        required List<_NewsItem> items,
      }) {
    // Loading state
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle('Top story'),
          SizedBox(height: 10),
          _SkeletonCard(height: 110),
          SizedBox(height: 16),
          _SectionTitle('Latest'),
          SizedBox(height: 10),
          _SkeletonCard(height: 72),
          SizedBox(height: 12),
          _SkeletonCard(height: 72),
          SizedBox(height: 12),
          _SkeletonCard(height: 72),
        ],
      );
    }

    // Error state
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
              child: Text(
                errorMessage,
                style: TextStyle(color: AppTokens.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: retry fetch
              },
              child: Text(
                'Retry',
                style: TextStyle(color: AppTokens.emerald500),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (items.isEmpty) {
      return NeonCard(
        color: AppTokens.cardSurface,
        shadows: AppTokens.tileShadow,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: AppTokens.textSecondary, size: 34),
            const SizedBox(height: 10),
            Text(
              'No news yet',
              style: TextStyle(
                color: AppTokens.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check back soon — new updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTokens.textSecondary),
            ),
          ],
        ),
      );
    }

    // Content
    final _NewsItem top = items.first;
    final List<_NewsItem> rest = items.length > 1 ? items.sublist(1) : const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Top story'),
        const SizedBox(height: 10),
        _TopStoryCard(
          item: top,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Open top story')),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: _SectionTitle('Latest')),
            TextButton(
              onPressed: () {
                // TODO: refresh / open full list
              },
              child: Text(
                'See all',
                style: TextStyle(color: AppTokens.emerald500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...rest.map(
              (n) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _NewsRowCard(
              item: n,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Open: ${n.title}')),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/* ================== Header ================== */

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    // Header je na gradient pozadí → biela sedí aj v light aj dark.
    // Ak chceš, aby to bolo adaptívne, vieš použiť AppTokens.textPrimary atď.,
    // ale na gradient to často vyzerá horšie.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latest News',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          'Updates, tips, and announcements',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 13, fontWeight: FontWeight.w500),
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

/* ================== Model ================== */

class _NewsItem {
  final String title;
  final String subtitle;
  final String tag;
  const _NewsItem({required this.title, required this.subtitle, required this.tag});
}

/* ================== UI Cards ================== */

class _TopStoryCard extends StatelessWidget {
  final _NewsItem item;
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
              child: const Icon(Icons.campaign_rounded, color: Colors.white),
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
                  Text(
                    item.subtitle,
                    style: TextStyle(color: AppTokens.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: AppTokens.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _NewsRowCard extends StatelessWidget {
  final _NewsItem item;
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
    // Jemný pill ktorý sa adaptuje (žiadne natvrdo white bordery)
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
