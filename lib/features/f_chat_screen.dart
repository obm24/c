// =============================================================================
// CHAT SCREEN
// Individual conversation view with message bubbles, input bar, role header,
// and simulated reply from the other participant.
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../core/c_ui_theme.dart';
import '../core/c_core_utils.dart';
import '../models/message_models.dart';
import '../bloc/bloc_messages.dart';

// =============================================================================
// CHAT SCREEN
// =============================================================================

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;
  final ChatUserModel currentUser;

  const ChatScreen({
    super.key,
    required this.conversation,
    required this.currentUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  // Simulated "typing..." indicator
  Timer? _typingTimer;
  bool _participantIsTyping = false;

  // Whether the input field currently has text
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _inputCtrl.addListener(() {
      setState(() => _canSend = _inputCtrl.text.trim().isNotEmpty);
    });
    // Auto-scroll to bottom on first load
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _inputFocus.dispose();
    _scrollCtrl.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    if (animated) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    }
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    context.read<MessagesBloc>().add(
          SendMessage(
            conversationId: widget.conversation.id,
            text: text,
          ),
        );
    _inputCtrl.clear();
    setState(() => _canSend = false);
    _inputFocus.requestFocus();

    // Simulate the other participant typing back after a delay
    _simulateReply();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  /// Simulates a realistic typing-then-reply flow from the participant.
  void _simulateReply() {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _participantIsTyping = true);
      _scrollToBottom();

      _typingTimer = Timer(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        setState(() => _participantIsTyping = false);
        final replies = [
          'Got it! 💪',
          'Perfect, keep it up!',
          'Great work today.',
          'I\'ll update your programme tonight.',
          'Remember to hydrate 🥤',
          'That\'s exactly the right approach.',
        ];
        final text = replies[DateTime.now().second % replies.length];
        context.read<MessagesBloc>().add(
              IncomingMessage(
                MessageModel(
                  id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
                  conversationId: widget.conversation.id,
                  senderId: widget.conversation.participant.id,
                  text: text,
                  timestamp: DateTime.now(),
                  status: MessageStatus.delivered,
                ),
              ),
            );
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.conversation.participant;
    final rel = resolveRelationship(
      currentUser: widget.currentUser,
      participant: participant,
    );
    final theme = RoleTheme.of(rel);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _ChatAppBar(
        participant: participant,
        relationship: rel,
        roleTheme: theme,
      ),
      body: Column(
        children: [
          // ── Messages list ─────────────────────────────────────────────
          Expanded(
            child: BlocConsumer<MessagesBloc, MessagesState>(
              listenWhen: (prev, curr) {
                if (curr is MessagesLoaded) {
                  return (curr.activeMessages.length >
                      (prev is MessagesLoaded
                          ? prev.activeMessages.length
                          : 0));
                }
                return false;
              },
              listener: (_, __) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
              },
              builder: (ctx, state) {
                if (state is! MessagesLoaded) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.brand, strokeWidth: 2),
                  );
                }

                final messages = state.activeMessages;

                if (messages.isEmpty) {
                  return _EmptyChatState(
                    participant: participant,
                    roleTheme: theme,
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length + (_participantIsTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    // Typing indicator as last item
                    if (_participantIsTyping && i == messages.length) {
                      return _TypingIndicator(
                        participant: participant,
                        color: theme.color,
                      );
                    }

                    final msg = messages[i];
                    final isMe = msg.senderId == 'me';
                    final showDateDivider = i == 0 ||
                        !_sameDay(messages[i - 1].timestamp, msg.timestamp);

                    return Column(
                      children: [
                        if (showDateDivider)
                          _DateDivider(timestamp: msg.timestamp),
                        MessageBubble(
                          message: msg,
                          isMe: isMe,
                          participantColor: theme.color,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // ── Input bar ─────────────────────────────────────────────────
          _InputBar(
            controller: _inputCtrl,
            focusNode: _inputFocus,
            canSend: _canSend,
            onSend: _send,
            onAttach: () =>
                AppUtils.showToast(context, 'Attachments coming soon'),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// =============================================================================
// CHAT APP BAR
// =============================================================================

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatUserModel participant;
  final ParticipantRelationship relationship;
  final RoleTheme roleTheme;

  const _ChatAppBar({
    required this.participant,
    required this.relationship,
    required this.roleTheme,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isCurrentTrainer =
        relationship == ParticipantRelationship.currentTrainer;

    return AppBar(
      backgroundColor: AppTheme.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          // Mini avatar
          Container(
            padding: isCurrentTrainer ? const EdgeInsets.all(1.5) : null,
            decoration: isCurrentTrainer
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        roleTheme.color,
                        roleTheme.color.withValues(alpha: 0.4),
                      ],
                    ),
                  )
                : null,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: roleTheme.color.withValues(alpha: 0.18),
              child: Text(
                participant.initials,
                style: TextStyle(
                  color: roleTheme.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(roleTheme.icon, size: 12, color: roleTheme.color),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        participant.fullName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  roleTheme.label,
                  style: TextStyle(
                    color: roleTheme.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon:
              const Icon(CupertinoIcons.ellipsis, color: AppTheme.textPrimary),
          onPressed: () =>
              AppUtils.showToast(context, 'Chat options coming soon'),
        ),
      ],
    );
  }
}

// =============================================================================
// MESSAGE BUBBLE
// =============================================================================

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Color participantColor;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.participantColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 4),

          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.brand : AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Message text
                  Text(
                    message.text ?? '',
                    style: TextStyle(
                      color: isMe ? AppTheme.bg : AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Time + status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(message.timestamp),
                        style: TextStyle(
                          color: isMe
                              ? AppTheme.bg.withValues(alpha: 0.65)
                              : AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _StatusIcon(status: message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// =============================================================================
// MESSAGE STATUS ICON  (sending → sent → delivered → read)
// =============================================================================

class _StatusIcon extends StatelessWidget {
  final MessageStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.white54,
          ),
        );
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.white54);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 12, color: Colors.white70);
      case MessageStatus.read:
        return const Icon(Icons.done_all,
            size: 12, color: Colors.lightBlueAccent);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline,
            size: 12, color: Colors.redAccent);
    }
  }
}

// =============================================================================
// DATE DIVIDER  (e.g. "Today", "Yesterday", "Mon 21 Apr")
// =============================================================================

class _DateDivider extends StatelessWidget {
  final DateTime timestamp;
  const _DateDivider({required this.timestamp});

  String _label() {
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(timestamp.year, timestamp.month, timestamp.day))
        .inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEE, d MMM').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(children: [
        const Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Text(
              _label(),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
      ]),
    );
  }
}

// =============================================================================
// TYPING INDICATOR  (animated dots)
// =============================================================================

class _TypingIndicator extends StatefulWidget {
  final ChatUserModel participant;
  final Color color;

  const _TypingIndicator({
    required this.participant,
    required this.color,
  });

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _dots;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _dots = List.generate(
      3,
      (i) => Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeInOut),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _dots[i],
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: _dots[i].value),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// INPUT BAR
// =============================================================================

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attach button
          GestureDetector(
            onTap: onAttach,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.paperclip,
                color: AppTheme.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                onTapOutside: (_) => focusNode.unfocus(),
                style:
                    const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Message…',
                  hintStyle:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send / mic button — animated between the two states
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: canSend
                ? GestureDetector(
                    key: const ValueKey('send'),
                    onTap: onSend,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.brand,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: AppTheme.bg,
                        size: 18,
                      ),
                    ),
                  )
                : Container(
                    key: const ValueKey('mic'),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.mic,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EMPTY CHAT STATE  (first-time opening a conversation)
// =============================================================================

class _EmptyChatState extends StatelessWidget {
  final ChatUserModel participant;
  final RoleTheme roleTheme;

  const _EmptyChatState({
    required this.participant,
    required this.roleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: roleTheme.color.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Text(
                  participant.initials,
                  style: TextStyle(
                    color: roleTheme.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              participant.fullName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: roleTheme.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(roleTheme.icon, size: 12, color: roleTheme.color),
                  const SizedBox(width: 5),
                  Text(
                    roleTheme.label,
                    style: TextStyle(
                        color: roleTheme.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Say hello! This is the start of\nyour conversation.',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
