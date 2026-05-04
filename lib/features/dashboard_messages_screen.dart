// =============================================================================
// MESSAGES DASHBOARD SCREEN
// Entry-point for the messaging hub: conversation list with role badges,
// search, empty states, and navigation to the individual chat screen.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/animations/anim_motion.dart';
import '../core/c_visual_effects.dart';
import '../models/m_messages.dart';
import '../bloc/b_messages.dart';
import 'f_chat_screen.dart';

// =============================================================================
// MESSAGES DASHBOARD SCREEN
// =============================================================================

class MessagesDashboardScreen extends StatefulWidget {
  const MessagesDashboardScreen({super.key});

  @override
  State<MessagesDashboardScreen> createState() =>
      _MessagesDashboardScreenState();
}

class _MessagesDashboardScreenState extends State<MessagesDashboardScreen> {
  late final MessagesBloc _bloc;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _bloc = MessagesBloc()..add(const LoadConversations());
    _searchCtrl.addListener(() {
      _bloc.add(SearchConversations(_searchCtrl.text));
    });
  }

  @override
  void dispose() {
    _bloc.close();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openChat(
      BuildContext ctx, ConversationModel conv, ChatUserModel currentUser) {
    HapticFeedback.selectionClick();
    _bloc.add(OpenConversation(conv.id));
    Navigator.push(
      ctx,
      AppRoutes.noTransitionRoute(
        BlocProvider.value(
          value: _bloc,
          child: ChatScreen(
            conversation: conv,
            currentUser: currentUser,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.bg,
          automaticallyImplyLeading: false,
          title: const Text(
            'Messages',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // Compose new message button
            BlocBuilder<MessagesBloc, MessagesState>(
              builder: (ctx, state) => IconButton(
                icon: const Icon(CupertinoIcons.pencil_outline,
                    color: AppTheme.brand),
                onPressed: () =>
                    AppUtils.showToast(ctx, 'New message — coming soon'),
              ),
            ),
          ],
        ),
        body: BlocBuilder<MessagesBloc, MessagesState>(
          builder: (ctx, state) {
            if (state is MessagesLoading) {
              return const AppAnimatedSwitcher(
                child: _LoadingShimmer(key: ValueKey('messages-loading')),
              );
            }
            if (state is MessagesError) {
              return AppAnimatedSwitcher(
                child: Center(
                  key: const ValueKey('messages-error'),
                  child: Text(state.message,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                ),
              );
            }
            if (state is! MessagesLoaded) return const SizedBox.shrink();

            return AppAnimatedSwitcher(
              child: Column(
                key: const ValueKey('messages-loaded'),
                children: [
                  // ── Search bar ──────────────────────────────────────────
                  _SearchBar(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                  ),

                  // ── Role-legend chips ───────────────────────────────────
                  _RoleLegendRow(),

                  // ── Conversation list ───────────────────────────────────
                  Expanded(
                    child: state.displayedConversations.isEmpty
                        ? _EmptyState(isSearching: state.isSearching)
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: state.displayedConversations.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final conv = state.displayedConversations[i];
                              final tile = ChatListTile(
                                conversation: conv,
                                currentUser: state.currentUser,
                                onTap: () =>
                                    _openChat(ctx, conv, state.currentUser),
                                onLongPress: () => _showConvOptions(ctx, conv),
                              );
                              if (i >= 12) return tile;
                              return AppFadeSlideTransition(
                                delay: Duration(milliseconds: i * 18),
                                duration: AppDurations.standard,
                                child: tile,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showConvOptions(BuildContext ctx, ConversationModel conv) {
    HapticFeedback.mediumImpact();
    AppMotion.showPremiumBottomSheet(
      context: ctx,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                conv.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
                color: AppTheme.brand,
              ),
              title: Text(
                conv.isPinned ? 'Unpin Conversation' : 'Pin Conversation',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _bloc.add(TogglePinConversation(conv.id));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.error),
              title: const Text('Delete Conversation',
                  style: TextStyle(color: AppTheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                AppUtils.showToast(ctx, 'Delete — coming soon');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CHAT LIST TILE  (the star reusable widget)
// =============================================================================

class ChatListTile extends StatelessWidget {
  final ConversationModel conversation;
  final ChatUserModel currentUser;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatListTile({
    super.key,
    required this.conversation,
    required this.currentUser,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final participant = conversation.participant;
    final rel = resolveRelationship(
      currentUser: currentUser,
      participant: participant,
    );
    final theme = RoleTheme.of(rel);
    final hasUnread = conversation.unreadCount > 0;
    final isCurrentTrainer = rel == ParticipantRelationship.currentTrainer;

    return TnTPremiumCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      radius: 18,
      elevated: hasUnread || isCurrentTrainer,
      accentColor: isCurrentTrainer ? theme.color : null,
      backgroundColor: isCurrentTrainer
          ? theme.color.withValues(alpha: 0.07)
          : AppTheme.surfaceLow,
      child: Row(
        children: [
          // ── Avatar with role border ───────────────────────────────
          _ParticipantAvatar(
            participant: participant,
            relationship: rel,
            theme: theme,
          ),
          const SizedBox(width: 14),

          // ── Name, snippet, meta ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Role icon
                    Icon(theme.icon, size: 14, color: theme.color),
                    const SizedBox(width: 5),
                    // Name
                    Expanded(
                      child: Text(
                        participant.fullName,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight:
                              hasUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // "My Coach" label for current trainer
                    if (isCurrentTrainer) ...[
                      const SizedBox(width: 6),
                      _CoachLabel(color: theme.color),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Last message snippet
                Text(
                  _snippetText(conversation),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasUnread
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Timestamp + unread badge ─────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTimestamp(conversation.updatedAt),
                style: TextStyle(
                  color: hasUnread ? theme.color : AppTheme.textSecondary,
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              if (conversation.isPinned && !hasUnread)
                const Icon(Icons.push_pin_rounded,
                    size: 13, color: AppTheme.textSecondary)
              else if (hasUnread)
                _UnreadBadge(
                    count: conversation.unreadCount, color: theme.color)
              else
                const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  String _snippetText(ConversationModel conv) {
    final msg = conv.lastMessage;
    if (msg == null) return 'No messages yet';
    final prefix = msg.senderId == 'me' ? 'You: ' : '';
    switch (msg.type) {
      case MessageType.image:
        // ignore: unnecessary_brace_in_string_interps
        return '${prefix}📷 Photo';
      case MessageType.voiceNote:
        // ignore: unnecessary_brace_in_string_interps
        return '${prefix}🎤 Voice note';
      case MessageType.file:
        // ignore: unnecessary_brace_in_string_interps
        return '${prefix}📎 ${msg.mediaName ?? 'File'}';
      default:
        return '$prefix${msg.text ?? ''}';
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return DateFormat('h:mm a').format(dt);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('d MMM').format(dt);
  }
}

// =============================================================================
// PARTICIPANT AVATAR — bordered for current trainer, plain for others
// =============================================================================

class _ParticipantAvatar extends StatelessWidget {
  final ChatUserModel participant;
  final ParticipantRelationship relationship;
  final RoleTheme theme;

  const _ParticipantAvatar({
    required this.participant,
    required this.relationship,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentTrainer =
        relationship == ParticipantRelationship.currentTrainer;

    Widget avatar = CircleAvatar(
      radius: 24,
      backgroundColor: theme.color.withValues(alpha: 0.18),
      child: Text(
        participant.initials,
        style: TextStyle(
          color: theme.color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );

    if (isCurrentTrainer) {
      // Glowing ring for the current trainer
      return Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              theme.color,
              theme.color.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.color.withValues(alpha: 0.45),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}

// =============================================================================
// "MY COACH" LABEL CHIP
// =============================================================================

class _CoachLabel extends StatelessWidget {
  final Color color;
  const _CoachLabel({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 9, color: color),
          const SizedBox(width: 3),
          Text(
            'My Coach',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// UNREAD BADGE
// =============================================================================

class _UnreadBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _UnreadBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: AppTheme.bg,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ROLE LEGEND ROW  (small instructional chips at top of list)
// =============================================================================

class _RoleLegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const relationships = [
      ParticipantRelationship.currentTrainer,
      ParticipantRelationship.trainer,
      ParticipantRelationship.trainee,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: relationships.map((rel) {
          final t = RoleTheme.of(rel);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TnTChip(
              label: t.label,
              icon: t.icon,
              color: t.color,
              compact: true,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// =============================================================================
// SEARCH BAR
// =============================================================================

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _SearchBar({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onTapOutside: (_) => focusNode.unfocus(),
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search conversations',
          hintStyle:
              const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          prefixIcon: const Icon(CupertinoIcons.search,
              color: AppTheme.textSecondary, size: 18),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, v, __) => v.text.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () => controller.clear(),
                    child: const Icon(CupertinoIcons.xmark_circle_fill,
                        color: AppTheme.textSecondary, size: 16),
                  ),
          ),
          filled: true,
          fillColor: AppTheme.surfaceRaised,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            borderSide: const BorderSide(color: AppTheme.outlineSoft),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            borderSide: const BorderSide(color: AppTheme.outlineStrong),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState extends StatelessWidget {
  final bool isSearching;
  const _EmptyState({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return TnTEmptyState(
      icon: isSearching ? CupertinoIcons.search : CupertinoIcons.chat_bubble_2,
      title: isSearching
          ? 'No conversations match your search'
          : 'No messages yet',
      message: isSearching
          ? 'Try a different name or keyword.'
          : 'Start a conversation with your coach\nor fellow athletes.',
    );
  }
}

// =============================================================================
// LOADING SHIMMER  (skeleton placeholders while conversations load)
// =============================================================================

class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer({super.key});
  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppDurations.slowReveal * 2,
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduceMotion(context)) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: 6,
        separatorBuilder: (_, __) =>
            const Divider(color: AppTheme.divider, height: 1, indent: 62),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              // Avatar placeholder
              TnTSkeletonBlock(
                width: 48,
                height: 48,
                opacity: _anim.value,
                shape: const CircleBorder(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TnTSkeletonBlock(
                      height: 13,
                      width: 140,
                      radius: 6,
                      opacity: _anim.value,
                    ),
                    const SizedBox(height: 8),
                    TnTSkeletonBlock(
                      height: 11,
                      width: 200,
                      radius: 6,
                      opacity: _anim.value,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TnTSkeletonBlock(
                    height: 10,
                    width: 36,
                    radius: 6,
                    opacity: _anim.value,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
