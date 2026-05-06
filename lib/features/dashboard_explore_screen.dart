import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/c_ui_theme.dart';
import '../core/c_core_utils.dart';
import '../core/c_state.dart';
import '../core/c_visual_effects.dart';
import 'trainee_public_profile_screen.dart' as trainee_public;
import 'trainer_public_profile_screen.dart' as trainer_public;

// =============================================================================
// GLOBAL SEARCH BAR — with initials avatars in results
// =============================================================================
class GlobalSearchBar extends StatefulWidget {
  const GlobalSearchBar({super.key});

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  String _query = '';
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, dynamic>> _mockUsers = [
    {
      'name': 'Ahmed al-Demerdash',
      'username': 'ahmed1',
      'type': 'Trainer',
      'object': appState.trainerAhmed,
    },
    {
      'name': 'Omar Magdy',
      'username': 'obm24',
      'type': 'Trainee',
      'object': appState.traineeOmar,
    },
  ];

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isEmpty
        ? <Map<String, dynamic>>[]
        : _mockUsers
            .where((u) =>
                u['name']
                    .toString()
                    .toLowerCase()
                    .contains(_query.toLowerCase()) ||
                u['username']
                    .toString()
                    .toLowerCase()
                    .contains(_query.toLowerCase()))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: _query.isNotEmpty ? 10 : 20),
          child: TextField(
            focusNode: _focusNode,
            onTapOutside: (event) => _focusNode.unfocus(),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              decoration: TextDecoration.none,
            ),
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search trainers, workouts, tips…',
              hintStyle: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14),
              prefixIcon: const Icon(CupertinoIcons.search,
                  color: AppTheme.textSecondary, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? GestureDetector(
                      onTap: () => setState(() => _query = ''),
                      child: const Icon(CupertinoIcons.xmark_circle_fill,
                          color: AppTheme.textSecondary, size: 16),
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (_query.isNotEmpty)
          TnTPremiumCard(
            margin: const EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.zero,
            radius: 16,
            child: results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      context.l10n.noResultsFound,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  )
                : Column(
                    children: results.asMap().entries.expand((entry) {
                      final res = entry.value;
                      return [
                        if (entry.key > 0)
                          const Divider(color: AppTheme.divider, height: 1),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.bg,
                            child: Text(
                              (res['name'] as String)
                                  .split(' ')
                                  .take(2)
                                  .map((w) => w.isNotEmpty ? w[0] : '')
                                  .join()
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.brand,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          title: Text(
                            res['name'],
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            '@${res['username']} · ${res['type']}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _focusNode.unfocus();
                            if (res['object'] != null) {
                              if (res['type'] == 'Trainer') {
                                Navigator.push(
                                  context,
                                  AppRoutes.noTransitionRoute(
                                    trainer_public.TrainerPublicProfileScreen(
                                        trainer: res['object']),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  AppRoutes.noTransitionRoute(
                                    trainee_public.TraineePublicProfileScreen(
                                        trainee: res['object']),
                                  ),
                                );
                              }
                            } else {
                              AppUtils.showToast(
                                  context, context.l10n.mockUserNoProfile);
                            }
                          },
                        ),
                      ];
                    }).toList(),
                  ),
          ),
      ],
    );
  }
}

// =============================================================================
// TAB 1 — EXPLORE PAGE
// =============================================================================
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  String _selectedCategory = 'All';

  static const List<_ExploreCategory> _categories = [
    _ExploreCategory('All', '✦'),
    _ExploreCategory('Trainers', '🏋️'),
    _ExploreCategory('Workouts', '💪'),
    _ExploreCategory('Nutrition', '🥗'),
    _ExploreCategory('Transformation', '🔥'),
    _ExploreCategory('Tips', '💡'),
  ];

  static final List<Map<String, dynamic>> _trendingTrainers = [
    {
      'name': 'Ahmed D.',
      'specialty': 'Strength & Hypertrophy',
      'rating': '4.9',
      'followers': '12.4K',
      'hue': 220,
      'verified': true,
      'object': appState.trainerAhmed,
    },
    {
      'name': 'Sara M.',
      'specialty': 'Weight Loss',
      'rating': '4.8',
      'followers': '8.1K',
      'hue': 300,
      'verified': false,
      'object': null,
    },
    {
      'name': 'Coach Ali',
      'specialty': 'Sports Performance',
      'rating': '4.7',
      'followers': '5.6K',
      'hue': 10,
      'verified': true,
      'object': null,
    },
    {
      'name': 'Lena S.',
      'specialty': 'Mobility & Yoga',
      'rating': '4.9',
      'followers': '9.3K',
      'hue': 180,
      'verified': false,
      'object': null,
    },
  ];

  static final List<Map<String, dynamic>> _mockItems = [
    {
      'type': 'video',
      'title': '5-Min Ab Burner',
      'author': 'Ahmed D.',
      'authorHue': 220,
      'likes': '4.2K',
      'imgHue': 220,
      'category': 'Workouts',
      'isReel': true,
      'featured': true,
      'span': 2,
    },
    {
      'type': 'photo',
      'title': '90-Day Transformation',
      'author': 'Sara M.',
      'authorHue': 300,
      'likes': '11.8K',
      'imgHue': 140,
      'category': 'Transformation',
      'isReel': false,
      'featured': true,
      'span': 1,
    },
    {
      'type': 'article',
      'title': 'Protein Timing Myths',
      'author': 'Dr. K.',
      'authorHue': 30,
      'likes': '3.1K',
      'imgHue': 30,
      'category': 'Nutrition',
      'isReel': false,
      'featured': false,
      'span': 1,
      'readTime': '4 min',
    },
    {
      'type': 'video',
      'title': 'Perfect Squat Form',
      'author': 'Mike T.',
      'authorHue': 150,
      'likes': '6.7K',
      'imgHue': 300,
      'category': 'Workouts',
      'isReel': true,
      'featured': false,
      'span': 1,
    },
    {
      'type': 'photo',
      'title': 'Meal Prep Sunday',
      'author': 'Nadia R.',
      'authorHue': 60,
      'likes': '2.4K',
      'imgHue': 60,
      'category': 'Nutrition',
      'isReel': false,
      'featured': false,
      'span': 2,
    },
    {
      'type': 'video',
      'title': 'Morning Mobility Routine',
      'author': 'Lena S.',
      'authorHue': 180,
      'likes': '8.9K',
      'imgHue': 180,
      'category': 'Tips',
      'isReel': true,
      'featured': false,
      'span': 1,
    },
    {
      'type': 'photo',
      'title': 'Elite Trainer — Cairo',
      'author': 'Coach Ali',
      'authorHue': 10,
      'likes': '1.5K',
      'imgHue': 270,
      'category': 'Trainers',
      'isReel': false,
      'featured': false,
      'span': 1,
    },
    {
      'type': 'article',
      'title': 'Sleep & Recovery Science',
      'author': 'Dr. Hassan',
      'authorHue': 200,
      'likes': '5.3K',
      'imgHue': 10,
      'category': 'Tips',
      'isReel': false,
      'featured': false,
      'span': 1,
      'readTime': '6 min',
    },
    {
      'type': 'photo',
      'title': '12-Week Bulk Result',
      'author': 'Omar K.',
      'authorHue': 100,
      'likes': '9.1K',
      'imgHue': 100,
      'category': 'Transformation',
      'isReel': false,
      'featured': false,
      'span': 1,
    },
    {
      'type': 'video',
      'title': 'Deadlift Masterclass',
      'author': 'Ahmed D.',
      'authorHue': 220,
      'likes': '14.2K',
      'imgHue': 240,
      'category': 'Workouts',
      'isReel': true,
      'featured': false,
      'span': 1,
    },
  ];

  List<Map<String, dynamic>> get _filtered => _mockItems.where((i) {
        return _selectedCategory == 'All' ||
            i['category'] == _selectedCategory;
      }).toList();

  List<Map<String, dynamic>> get _featured =>
      _mockItems.where((i) => i['featured'] == true).toList();

  bool get _showDefault => _selectedCategory == 'All';

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Search bar ─────────────────────────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: GlobalSearchBar(),
          ),
        ),

        // ── Category chips ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat.label;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat.label);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.brand
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.brand
                            : AppTheme.divider,
                      ),
                    ),
                    child: Text(
                      '${cat.emoji}  ${cat.label}',
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.bg
                            : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ── Trending Trainers ──────────────────────────────────────────
        if (_showDefault) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending Trainers',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _trendingTrainers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) =>
                    _TrendingTrainerCard(trainer: _trendingTrainers[i]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
        ],

        // ── Featured banner carousel ───────────────────────────────────
        if (_showDefault && _featured.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                'Featured',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _featured.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _FeaturedCard(item: _featured[i]),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Text(
                'For You',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],

        // ── Content grid ───────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 108),
          sliver: _filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: TnTEmptyState(
                    icon: CupertinoIcons.search,
                    title: context.l10n.nothingFound,
                    message: 'Try a different keyword or category.',
                  ),
                )
              : SliverToBoxAdapter(
                  child: _ExploreGrid(items: _filtered),
                ),
        ),
      ],
    );
  }
}

class _ExploreCategory {
  final String label;
  final String emoji;
  const _ExploreCategory(this.label, this.emoji);
}

// =============================================================================
// TRENDING TRAINER CARD
// =============================================================================
class _TrendingTrainerCard extends StatelessWidget {
  final Map<String, dynamic> trainer;
  const _TrendingTrainerCard({required this.trainer});

  @override
  Widget build(BuildContext context) {
    final hue = (trainer['hue'] as int).toDouble();
    final accentColor = HSLColor.fromAHSL(1, hue, 0.65, 0.55).toColor();
    final bgColor = HSLColor.fromAHSL(1, hue, 0.35, 0.15).toColor();
    final initials = (trainer['name'] as String)
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return TnTPremiumCard(
      width: 130,
      padding: const EdgeInsets.all(14),
      radius: 20,
      backgroundColor: bgColor,
      accentColor: accentColor,
      onTap: () {
        if (trainer['object'] != null) {
          Navigator.push(
            context,
            AppRoutes.noTransitionRoute(
              trainer_public.TrainerPublicProfileScreen(
                  trainer: trainer['object']),
            ),
          );
        } else {
          AppUtils.showToast(
              context, '${trainer['name']}\'s profile coming soon');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accentColor.withValues(alpha: 0.25),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const Spacer(),
              if (trainer['verified'] == true)
                Icon(Icons.verified_rounded, color: accentColor, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            trainer['name'],
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              decoration: TextDecoration.none,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            trainer['specialty'],
            style: TextStyle(color: accentColor, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(CupertinoIcons.star_fill,
                  color: Color(0xFFFFD700), size: 11),
              const SizedBox(width: 3),
              Text(
                trainer['rating'],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  decoration: TextDecoration.none,
                ),
              ),
              const Spacer(),
              Text(
                trainer['followers'],
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FEATURED CARD
// =============================================================================
class _FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _FeaturedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color =
        HSLColor.fromAHSL(1, (item['imgHue'] as int).toDouble(), 0.55, 0.28)
            .toColor();
    return TnTPressable(
      onTap: () {
        AppUtils.showToast(
            context, '${item['title']} — ${context.l10n.detailComingSoon}');
      },
      haptic: TnTHaptic.light,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 250,
          color: color,
          child: Stack(
            children: [
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'by ${item['author']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const Spacer(),
                          const Icon(CupertinoIcons.heart_fill,
                              color: Colors.white60, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            item['likes'],
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Play icon
              if (item['isReel'] == true)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: Icon(CupertinoIcons.play_circle_fill,
                      color: Colors.white, size: 24),
                ),
              // Featured badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.star_fill,
                          color: Color(0xFFFFD700), size: 10),
                      SizedBox(width: 4),
                      Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EXPLORE GRID — mixed-span layout
// =============================================================================
class _ExploreGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _ExploreGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    const double gap = 2.0;
    final rows = <Widget>[];
    int i = 0;
    while (i < items.length) {
      final item = items[i];
      final span = item['span'] as int? ?? 1;
      if (span == 2 && i + 1 < items.length) {
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: _ExploreCell(item: item, aspectRatio: 0.85)),
            const SizedBox(width: gap),
            Expanded(
                flex: 1,
                child: _ExploreCell(item: items[i + 1], aspectRatio: 0.85)),
          ],
        ));
        rows.add(const SizedBox(height: gap));
        i += 2;
      } else {
        final a = items[i];
        final b = i + 1 < items.length ? items[i + 1] : null;
        final c = i + 2 < items.length ? items[i + 2] : null;
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _ExploreCell(item: a, aspectRatio: 0.75)),
            if (b != null) ...[
              const SizedBox(width: gap),
              Expanded(child: _ExploreCell(item: b, aspectRatio: 0.75)),
            ] else
              const Expanded(child: SizedBox()),
            if (c != null) ...[
              const SizedBox(width: gap),
              Expanded(child: _ExploreCell(item: c, aspectRatio: 0.75)),
            ] else
              const Expanded(child: SizedBox()),
          ],
        ));
        rows.add(const SizedBox(height: gap));
        i += 3;
      }
    }
    return Column(children: rows);
  }
}

class _ExploreCell extends StatelessWidget {
  final Map<String, dynamic> item;
  final double aspectRatio;
  const _ExploreCell({required this.item, this.aspectRatio = 0.75});

  @override
  Widget build(BuildContext context) {
    final color =
        HSLColor.fromAHSL(1, (item['imgHue'] as int).toDouble(), 0.55, 0.25)
            .toColor();
    final authorColor = HSLColor.fromAHSL(
      1,
      (item['authorHue'] as int? ?? item['imgHue'] as int).toDouble(),
      0.65,
      0.60,
    ).toColor();

    return TnTPressable(
      onTap: () {
        AppUtils.showToast(
            context, '${item['title']} — ${context.l10n.detailComingSoon}');
      },
      haptic: TnTHaptic.light,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          color: color,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.80),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.heart_fill,
                              color: Colors.white70, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            item['likes'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                                color: authorColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              item['author'],
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 9,
                                decoration: TextDecoration.none,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Reel indicator
              if (item['isReel'] == true)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(CupertinoIcons.play_circle_fill,
                      color: Colors.white, size: 16),
                ),

              // Article badge
              if (item['type'] == 'article')
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['readTime'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}