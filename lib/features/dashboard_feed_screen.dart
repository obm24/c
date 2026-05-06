import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/c_ui_theme.dart';
import '../core/c_core_utils.dart';
import '../core/c_state.dart';
import '../core/c_visual_effects.dart';

// =============================================================================
// TAB 2 — HOME FEED PAGE
// Stories row → posts feed with photo, video, poll, article post types.
// Double-tap heart, follow button, suggested trainer card between posts.
// =============================================================================
class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => HomeFeedPageState();
}

class HomeFeedPageState extends State<HomeFeedPage> {
  static final List<Map<String, dynamic>> _stories = [
    {'name': 'Your Story', 'hue': 0, 'seen': false, 'isSelf': true},
    {'name': 'Ahmed D.', 'hue': 220, 'seen': false, 'isSelf': false},
    {'name': 'Sara M.', 'hue': 300, 'seen': false, 'isSelf': false},
    {'name': 'Mike T.', 'hue': 140, 'seen': true, 'isSelf': false},
    {'name': 'Nadia R.', 'hue': 60, 'seen': false, 'isSelf': false},
    {'name': 'Lena S.', 'hue': 180, 'seen': true, 'isSelf': false},
    {'name': 'Coach Ali', 'hue': 10, 'seen': false, 'isSelf': false},
  ];

  final List<Map<String, dynamic>> _posts = [
    {
      'id': 1,
      'author': 'Ahmed al-Demerdash',
      'handle': '@ahmed1',
      'authorHue': 220,
      'time': '2m ago',
      'type': 'photo',
      'content':
          'Chest day complete. The pump is real. Consistency beats intensity every single time. 💪🔥',
      'likes': 1204,
      'liked': false,
      'comments': 48,
      'saved': false,
      'imgHue': 220,
      'isFollowing': false,
    },
    {
      'id': 2,
      'author': 'Sara M.',
      'handle': '@sara_fit',
      'authorHue': 300,
      'time': '18m ago',
      'type': 'poll',
      'content': 'What\'s your go-to post-workout meal?',
      'options': [
        {'label': 'Chicken & rice 🍗', 'pct': 54, 'selected': false},
        {'label': 'Protein shake 🥤', 'pct': 30, 'selected': false},
        {'label': 'Greek yogurt 🥣', 'pct': 16, 'selected': false},
      ],
      'voted': false,
      'totalVotes': 3812,
      'likes': 872,
      'liked': false,
      'comments': 94,
      'saved': false,
      'isFollowing': true,
    },
    {
      'id': 3,
      'author': 'Nadia R.',
      'handle': '@nadia_eats',
      'authorHue': 60,
      'time': '1h ago',
      'type': 'video',
      'content':
          '10-min full body HIIT — no equipment needed! Drop and give me 3 rounds 🔥',
      'views': '8.4K',
      'duration': '10:00',
      'likes': 3401,
      'liked': false,
      'comments': 217,
      'saved': false,
      'imgHue': 60,
      'isFollowing': false,
    },
    {
      'id': 4,
      'author': 'Dr. Hassan',
      'handle': '@dr_recovery',
      'authorHue': 200,
      'time': '3h ago',
      'type': 'article',
      'title': 'Why 7–9 Hours of Sleep Is Your Best Performance Drug',
      'snippet':
          'New research shows sleep deprivation reduces testosterone by up to 15% and cortisol spikes by 37%. Here\'s what you can do tonight.',
      'readTime': '5 min read',
      'likes': 5203,
      'liked': false,
      'comments': 183,
      'saved': false,
      'isFollowing': true,
    },
    {
      'id': 5,
      'author': 'Mike T.',
      'handle': '@miket_lifts',
      'authorHue': 140,
      'time': '5h ago',
      'type': 'photo',
      'content':
          '6-month progress check-in. Hard work pays off. Trust the process. 📈',
      'likes': 7891,
      'liked': false,
      'comments': 331,
      'saved': false,
      'imgHue': 300,
      'isFollowing': false,
    },
  ];

  static const int _suggestedAfterIndex = 2;

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() {});
  }

  void _toggleLike(int id) {
    setState(() {
      final p = _posts.firstWhere((p) => p['id'] == id);
      p['liked'] = !(p['liked'] as bool);
      p['likes'] = (p['likes'] as int) + (p['liked'] ? 1 : -1);
    });
    HapticFeedback.selectionClick();
  }

  void _toggleSave(int id) {
    setState(() {
      final p = _posts.firstWhere((p) => p['id'] == id);
      p['saved'] = !(p['saved'] as bool);
    });
    HapticFeedback.selectionClick();
  }

  void _toggleFollow(int id) {
    setState(() {
      final p = _posts.firstWhere((p) => p['id'] == id);
      p['isFollowing'] = !(p['isFollowing'] as bool);
    });
    HapticFeedback.selectionClick();
  }

  void _vote(int postId, int optIdx) {
    setState(() {
      final p = _posts.firstWhere((p) => p['id'] == postId);
      if (p['voted'] == true) return;
      p['voted'] = true;
      (p['options'] as List).asMap().forEach((i, o) => o['selected'] = i == optIdx);
      p['totalVotes'] = (p['totalVotes'] as int) + 1;
    });
    HapticFeedback.selectionClick();
  }

  void _markStorySeen(int i) => setState(() => _stories[i]['seen'] = true);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.brand,
      backgroundColor: AppTheme.surface,
      onRefresh: _onRefresh,
      child: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        children: [
          // ── Stories row ──────────────────────────────────────────────
          SizedBox(
            height: 106,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              itemCount: _stories.length,
              itemBuilder: (_, i) {
                final s = _stories[i];
                if (s['isSelf'] == true) {
                  return _AddStoryBubble(
                    firstName: appState.profileFirstName,
                    lastName: appState.profileLastName,
                    onTap: () =>
                        AppUtils.showToast(context, 'Story creation coming soon'),
                  );
                }
                return _StoryBubble(
                  story: s,
                  onTap: () {
                    _markStorySeen(i);
                    AppUtils.showToast(context, '${s['name']}\'s story');
                  },
                );
              },
            ),
          ),
          const Divider(color: AppTheme.divider, height: 1),

          // ── Posts ────────────────────────────────────────────────────
          for (int i = 0; i < _posts.length; i++) ...[
            TnTAppear(
              delay: Duration(milliseconds: i * 25),
              child: _FeedPost(
                post: _posts[i],
                onLike: () => _toggleLike(_posts[i]['id']),
                onSave: () => _toggleSave(_posts[i]['id']),
                onVote: (idx) => _vote(_posts[i]['id'], idx),
                onComment: () => AppUtils.showToast(
                    context, context.l10n.commentsComingSoon),
                onShare: () =>
                    AppUtils.showToast(context, context.l10n.shareComingSoon),
                onDoubleTap: () => _toggleLike(_posts[i]['id']),
                onFollow: () => _toggleFollow(_posts[i]['id']),
              ),
            ),
            if (i == _suggestedAfterIndex) _SuggestedTrainerInline(),
          ],
          const SizedBox(height: 108),
        ],
      ),
    );
  }
}

// =============================================================================
// SUGGESTED TRAINER INLINE CARD
// =============================================================================
class _SuggestedTrainerInline extends StatefulWidget {
  @override
  State<_SuggestedTrainerInline> createState() =>
      _SuggestedTrainerInlineState();
}

class _SuggestedTrainerInlineState extends State<_SuggestedTrainerInline> {
  bool _dismissed = false;
  bool _followed = false;

  static const Map<String, dynamic> _suggested = {
    'name': 'Ahmed al-Demerdash',
    'handle': '@ahmed1',
    'specialty': 'NASM-CPT · Strength & Hypertrophy',
    'followers': '12.4K followers',
    'hue': 220,
  };

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final hue = (_suggested['hue'] as int).toDouble();
    final accentColor = HSLColor.fromAHSL(1, hue, 0.65, 0.55).toColor();
    final bgColor = HSLColor.fromAHSL(1, hue, 0.25, 0.12).toColor();
    final initials = (_suggested['name'] as String)
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return TnTPremiumCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(16),
      backgroundColor: bgColor,
      accentColor: accentColor,
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Suggested for you',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _dismissed = true),
                child: const Icon(Icons.close,
                    color: AppTheme.textSecondary, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: accentColor.withValues(alpha: 0.2),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _suggested['name'],
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded,
                            color: accentColor, size: 14),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _suggested['specialty'],
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _suggested['followers'],
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TnTPressable(
                onTap: () => setState(() => _followed = !_followed),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _followed ? Colors.transparent : AppTheme.brand,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _followed ? AppTheme.divider : AppTheme.brand),
                  ),
                  child: Text(
                    _followed ? 'Following' : 'Follow',
                    style: TextStyle(
                      color: _followed ? AppTheme.textSecondary : AppTheme.bg,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      decoration: TextDecoration.none,
                    ),
                  ),
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
// ADD STORY BUBBLE
// =============================================================================
class _AddStoryBubble extends StatelessWidget {
  final String firstName, lastName;
  final VoidCallback onTap;

  const _AddStoryBubble({
    required this.firstName,
    required this.lastName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials =
        '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
            .toUpperCase();
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.surface,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppTheme.brand,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.brand,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.bg, width: 2),
                    ),
                    child: const Icon(Icons.add, color: AppTheme.bg, size: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              'Your Story',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// STORY BUBBLE
// =============================================================================
class _StoryBubble extends StatelessWidget {
  final Map<String, dynamic> story;
  final VoidCallback onTap;

  const _StoryBubble({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final seen = story['seen'] as bool;
    final hue = (story['hue'] as int).toDouble();
    final color = HSLColor.fromAHSL(1, hue, 0.7, 0.5).toColor();
    final nameParts = (story['name'] as String).split(' ');
    final initials = nameParts
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: seen
                    ? null
                    : LinearGradient(
                        colors: [color, color.withValues(alpha: 0.4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: seen
                    ? Border.all(color: AppTheme.divider, width: 2)
                    : null,
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.2),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              story['name'].toString().split(' ')[0],
              style: TextStyle(
                color: seen ? AppTheme.textSecondary : AppTheme.textPrimary,
                fontSize: 11,
                decoration: TextDecoration.none,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FEED POST
// =============================================================================
class _FeedPost extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike, onSave, onComment, onShare, onDoubleTap, onFollow;
  final ValueChanged<int> onVote;

  const _FeedPost({
    required this.post,
    required this.onLike,
    required this.onSave,
    required this.onVote,
    required this.onComment,
    required this.onShare,
    required this.onDoubleTap,
    required this.onFollow,
  });

  @override
  State<_FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<_FeedPost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _heartScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.3, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
    ]).animate(_heartCtrl);
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    widget.onDoubleTap();
    setState(() => _showHeart = true);
    _heartCtrl.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  Map<String, dynamic> get post => widget.post;

  @override
  Widget build(BuildContext context) {
    final hue = (post['authorHue'] as int? ?? 0).toDouble();
    final authorColor = HSLColor.fromAHSL(1, hue, 0.6, 0.55).toColor();
    final authorInitials = (post['author'] as String)
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();
    final isFollowing = post['isFollowing'] as bool? ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Post header ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: authorColor.withValues(alpha: 0.2),
                child: Text(
                  authorInitials,
                  style: TextStyle(
                    color: authorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['author'],
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      '${post['handle']} · ${post['time']}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isFollowing)
                GestureDetector(
                  onTap: widget.onFollow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.brand),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                        color: AppTheme.brand,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: widget.onFollow,
                  child: const Text(
                    'Following',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () =>
                    AppUtils.showToast(context, 'More options coming soon'),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.more_horiz,
                      color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),

        // ── Post content ────────────────────────────────────────────────
        GestureDetector(
          onDoubleTap:
              (post['type'] == 'photo' || post['type'] == 'video')
                  ? _handleDoubleTap
                  : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildContent(context),
              if (_showHeart)
                ScaleTransition(
                  scale: _heartScale,
                  child: const Icon(CupertinoIcons.heart_fill,
                      color: Colors.white, size: 90),
                ),
            ],
          ),
        ),

        // ── Action row ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              _actionBtn(
                post['liked'] == true
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                post['liked'] == true
                    ? AppTheme.error
                    : AppTheme.textSecondary,
                widget.onLike,
              ),
              const SizedBox(width: 5),
              Text(
                _fmtNum(post['likes']),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 18),
              _actionBtn(CupertinoIcons.chat_bubble,
                  AppTheme.textSecondary, widget.onComment),
              const SizedBox(width: 5),
              Text(
                '${post['comments']}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 18),
              _actionBtn(CupertinoIcons.arrowshape_turn_up_right,
                  AppTheme.textSecondary, widget.onShare),
              const Spacer(),
              _actionBtn(
                post['saved'] == true
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
                post['saved'] == true
                    ? AppTheme.brand
                    : AppTheme.textSecondary,
                widget.onSave,
              ),
            ],
          ),
        ),
        const Divider(color: AppTheme.divider, height: 1, thickness: 1),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (post['type'] as String) {
      case 'photo':
        final color =
            HSLColor.fromAHSL(1, (post['imgHue'] as int).toDouble(), 0.45, 0.22)
                .toColor();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                post['content'],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.45,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Container(
              height: 300,
              width: double.infinity,
              color: color,
              child: const Center(
                child: Icon(Icons.image_outlined,
                    color: Colors.white24, size: 64),
              ),
            ),
          ],
        );

      case 'video':
        final color =
            HSLColor.fromAHSL(1, (post['imgHue'] as int).toDouble(), 0.45, 0.22)
                .toColor();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                post['content'],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.45,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(height: 270, width: double.infinity, color: color),
                const Icon(Icons.play_circle_fill,
                    color: Colors.white70, size: 64),
                Positioned(
                    bottom: 10,
                    left: 12,
                    child: _badge('${post['views']} views')),
                Positioned(
                    bottom: 10,
                    right: 12,
                    child: _badge(post['duration'])),
              ],
            ),
          ],
        );

      case 'poll':
        final options = post['options'] as List;
        final voted = post['voted'] == true;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                post['content'],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 14),
              ...options.asMap().entries.map((e) {
                final i = e.key;
                final opt = e.value as Map;
                final sel = opt['selected'] == true;
                final pct = opt['pct'] as int;
                return TnTPressable(
                  onTap: voted ? null : () => widget.onVote(i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 46,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: sel ? AppTheme.brand : AppTheme.divider),
                          ),
                        ),
                        if (voted)
                          FractionallySizedBox(
                            widthFactor: pct / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppTheme.brand.withValues(alpha: 0.15)
                                    : AppTheme.divider.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (sel && voted)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(Icons.check_circle_rounded,
                                          color: AppTheme.brand, size: 15),
                                    ),
                                  Text(
                                    opt['label'],
                                    style: TextStyle(
                                      color: sel && voted
                                          ? AppTheme.brand
                                          : AppTheme.textPrimary,
                                      fontWeight: sel
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                              if (voted)
                                Text(
                                  '$pct%',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(CupertinoIcons.person_2,
                      color: AppTheme.textSecondary, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    voted
                        ? '${post['totalVotes']} votes'
                        : '${post['totalVotes']} votes · Tap to vote',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );

      case 'article':
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: TnTPremiumCard(
            padding: EdgeInsets.zero,
            radius: 14,
            accentColor: AppTheme.cardIndigo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Container(
                    height: 110,
                    decoration:
                        const BoxDecoration(color: AppTheme.cardIndigo),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.article_rounded,
                              color: Colors.white54, size: 44),
                        ),
                        if (post['readTime'] != null)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(CupertinoIcons.time,
                                      color: Colors.white, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    post['readTime'],
                                    style: const TextStyle(
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
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'],
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post['snippet'],
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 38,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.divider),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            context.l10n.readArticle,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _badge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      );

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) =>
      TnTPressable(
        onTap: onTap,
        haptic: TnTHaptic.selection,
        pressedScale: 0.9,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: color, size: 22),
        ),
      );

  String _fmtNum(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';
}