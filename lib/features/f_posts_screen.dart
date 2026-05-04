import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/c_ui_theme.dart';
import '../core/c_core_utils.dart';

// =============================================================================
// POST TYPE
// =============================================================================
enum PostType { photo, video, poll, article }

// =============================================================================
// POSTS SCREEN
// =============================================================================
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final List<Map<String, dynamic>> _posts = [
    {
      'id': 1,
      'type': PostType.video,
      'title': 'Perfecting the Squat Form 🏋️‍♂️',
      'time': '2 hours ago',
      'views': '2.4K Views',
      'likes': 182,
      'liked': false,
      'comments': 24,
    },
    {
      'id': 2,
      'type': PostType.poll,
      'title': 'What split are you currently running?',
      'time': '5 hours ago',
      'options': [
        {'label': 'Push/Pull/Legs', 'percentage': 65, 'selected': false},
        {'label': 'Upper/Lower', 'percentage': 20, 'selected': false},
        {'label': 'Bro Split', 'percentage': 15, 'selected': false},
      ],
      'totalVotes': 4102,
      'voted': false,
      'likes': 210,
      'liked': false,
      'comments': 48,
    },
    {
      'id': 3,
      'type': PostType.photo,
      'title':
          'Morning check-in. The cut is going incredibly well! Down 4 lbs this week.',
      'time': '1 day ago',
      'likes': 543,
      'liked': false,
      'comments': 61,
    },
    {
      'id': 4,
      'type': PostType.article,
      'title': 'The Truth About Protein Timing',
      'snippet':
          'Does the anabolic window actually exist? We dive into the latest literature to find out if you really need to chug a shake immediately after your last set.',
      'time': '3 days ago',
      'likes': 320,
      'liked': false,
      'comments': 37,
    },
  ];

  String _filter = 'All';
  static const List<String> _filters = [
    'All',
    'Video',
    'Photo',
    'Poll',
    'Article'
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return _posts;
    final typeMap = {
      'Video': PostType.video,
      'Photo': PostType.photo,
      'Poll': PostType.poll,
      'Article': PostType.article,
    };
    return _posts.where((p) => p['type'] == typeMap[_filter]).toList();
  }

  void _toggleLike(int id) {
    setState(() {
      final p = _posts.firstWhere((p) => p['id'] == id);
      p['liked'] = !(p['liked'] as bool);
      p['likes'] = (p['likes'] as int) + (p['liked'] ? 1 : -1);
    });
    HapticFeedback.selectionClick();
  }

  void _votePoll(int postId, int optionIndex) {
    setState(() {
      final p = _posts.firstWhere((p) => p['id'] == postId);
      if (p['voted'] == true) return;
      p['voted'] = true;
      final options = p['options'] as List;
      // Set selected option
      for (int i = 0; i < options.length; i++) {
        options[i]['selected'] = i == optionIndex;
      }
      p['totalVotes'] = (p['totalVotes'] as int) + 1;
    });
    HapticFeedback.selectionClick();
  }

  void _showPostOptions(int id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(10)))),
        ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppTheme.brand),
            title: Text(context.l10n.editPost,
                style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(ctx);
              AppUtils.showToast(context, context.l10n.postEditorComingSoon);
            }),
        ListTile(
            leading:
                const Icon(Icons.share_outlined, color: AppTheme.textSecondary),
            title: Text(context.l10n.share,
                style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(ctx);
              AppUtils.showToast(context, context.l10n.shareLinkCopied);
            }),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: AppTheme.error),
          title: Text(context.l10n.deletePost,
              style: TextStyle(color: AppTheme.error)),
          onTap: () {
            Navigator.pop(ctx);
            setState(() => _posts.removeWhere((p) => p['id'] == id));
            AppUtils.showToast(context, context.l10n.postDeleted);
          },
        ),
        const SizedBox(height: 12),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text(context.l10n.posts,
            style: const TextStyle(color: AppTheme.brand)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter chips ──
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final sel = f == _filter;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _filter = f);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.brand : AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? AppTheme.brand : AppTheme.divider),
                    ),
                    child: Text(f,
                        style: TextStyle(
                            color: sel ? AppTheme.bg : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                );
              },
            ),
          ),

          // ── Posts list ──
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.photo_library_outlined,
                            color: AppTheme.textSecondary, size: 56),
                        const SizedBox(height: 16),
                        Text(context.l10n.noPostsInCategory,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14)),
                      ]),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final post = _filtered[index];
                      return _PostCard(
                        post: post,
                        onLike: () => _toggleLike(post['id']),
                        onVote: (optIndex) => _votePoll(post['id'], optIndex),
                        onMore: () => _showPostOptions(post['id']),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.brand,
        child: const Icon(Icons.add, color: AppTheme.bg),
        onPressed: () {
          HapticFeedback.selectionClick();
          AppUtils.showToast(context, context.l10n.postComposerComingSoon);
        },
      ),
    );
  }
}

// =============================================================================
// POST CARD
// =============================================================================
class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;
  final ValueChanged<int> onVote;
  final VoidCallback onMore;

  const _PostCard(
      {required this.post,
      required this.onLike,
      required this.onVote,
      required this.onMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Post header ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.bg,
                    child: Icon(Icons.person, color: AppTheme.brand, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ahmed al-Demerdash',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        Text(post['time'],
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11)),
                      ]),
                ),
                GestureDetector(
                    onTap: onMore,
                    child: const Icon(Icons.more_vert,
                        color: AppTheme.textSecondary, size: 20)),
              ],
            ),
          ),

          // ── Content payload ──
          _buildPayload(context),

          // ── Footer: like / comment / share ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onLike,
                  child: Row(children: [
                    Icon(
                      post['liked'] == true
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: post['liked'] == true
                          ? AppTheme.error
                          : AppTheme.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 5),
                    Text('${post['likes']}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ]),
                ),
                const SizedBox(width: 18),
                Row(children: [
                  const Icon(CupertinoIcons.chat_bubble,
                      color: AppTheme.textSecondary, size: 22),
                  const SizedBox(width: 5),
                  Text('${post['comments']}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ]),
                const SizedBox(width: 18),
                const Icon(CupertinoIcons.share,
                    color: AppTheme.textSecondary, size: 22),
                const Spacer(),
                const Icon(CupertinoIcons.bookmark,
                    color: AppTheme.textSecondary, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayload(BuildContext context) {
    switch (post['type'] as PostType) {
      case PostType.video:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16)
                  .copyWith(bottom: 12),
              child: Text(post['title'],
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14))),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(alignment: Alignment.center, children: [
                const Icon(Icons.play_circle_fill,
                    color: Colors.white70, size: 60),
                Positioned(bottom: 8, left: 8, child: _badge(post['views'])),
                Positioned(bottom: 8, right: 8, child: _badge('10:24')),
              ]),
            ),
          ),
        ]);

      case PostType.photo:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16)
                  .copyWith(bottom: 12),
              child: Text(post['title'],
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14))),
          AspectRatio(
              aspectRatio: 1,
              child: Container(
                  color: AppTheme.bg,
                  child: const Center(
                      child: Icon(Icons.image_outlined,
                          color: AppTheme.textSecondary, size: 80)))),
        ]);

      case PostType.poll:
        final options = post['options'] as List;
        final voted = post['voted'] == true;
        final totalVotes = post['totalVotes'] as int;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post['title'],
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...options.asMap().entries.map((e) {
              final i = e.key;
              final opt = e.value as Map;
              final isSelected = opt['selected'] == true;
              final pct = opt['percentage'] as int;
              return GestureDetector(
                onTap: voted ? null : () => onVote(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  height: 44,
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color:
                                isSelected ? AppTheme.brand : AppTheme.divider),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: voted ? pct / 100 : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.brand.withValues(alpha: 0.2)
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              if (isSelected && voted)
                                const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(Icons.check_circle,
                                        color: AppTheme.brand, size: 16)),
                              Text(opt['label'],
                                  style: TextStyle(
                                      color: isSelected && voted
                                          ? AppTheme.brand
                                          : AppTheme.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13)),
                            ]),
                            if (voted)
                              Text('$pct%',
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                          ]),
                    ),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 4),
            Text(
              voted ? '$totalVotes Votes' : 'Tap to vote',
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ]),
        );

      case PostType.article:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 110,
                    decoration: const BoxDecoration(
                        color: AppTheme.cardIndigo,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12))),
                    child: const Center(
                        child: Icon(Icons.article,
                            color: Colors.white54, size: 48)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post['title'],
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(post['snippet'],
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  height: 1.4),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppTheme.textSecondary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              child: Text(context.l10n.readArticle,
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ]),
                  ),
                ]),
          ),
        );
    }
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.black54, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
