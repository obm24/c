// =============================================================================
// MESSAGES BLOC
// Handles conversation list, individual chat state, and trainer-relationship
// changes. In production swap the mock repository with your real data layer
// (Firestore, Supabase, your own WS server, etc.).
// =============================================================================

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/message_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────────────────────────────────────

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();
  @override
  List<Object?> get props => [];
}

/// Boot-up: load all conversations for the signed-in user.
class LoadConversations extends MessagesEvent {
  const LoadConversations();
}

/// User opened a specific chat room.
class OpenConversation extends MessagesEvent {
  final String conversationId;
  const OpenConversation(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

/// User typed and tapped "send".
class SendMessage extends MessagesEvent {
  final String conversationId;
  final String text;
  const SendMessage({required this.conversationId, required this.text});
  @override
  List<Object?> get props => [conversationId, text];
}

/// Simulates an incoming real-time message from the other participant.
class IncomingMessage extends MessagesEvent {
  final MessageModel message;
  const IncomingMessage(this.message);
  @override
  List<Object?> get props => [message];
}

/// All messages in a conversation have been read — clear unread badge.
class MarkConversationRead extends MessagesEvent {
  final String conversationId;
  const MarkConversationRead(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

/// The local user's "current trainer" relationship changed.
/// Pass [newTrainerId] as null to clear it (trainer stopped working with user).
class TrainerRelationshipChanged extends MessagesEvent {
  final String? newTrainerId;
  const TrainerRelationshipChanged(this.newTrainerId);
  @override
  List<Object?> get props => [newTrainerId];
}

/// Search / filter the conversation list.
class SearchConversations extends MessagesEvent {
  final String query;
  const SearchConversations(this.query);
  @override
  List<Object?> get props => [query];
}

/// Pin / unpin a conversation.
class TogglePinConversation extends MessagesEvent {
  final String conversationId;
  const TogglePinConversation(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

abstract class MessagesState extends Equatable {
  const MessagesState();
  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {
  const MessagesInitial();
}

class MessagesLoading extends MessagesState {
  const MessagesLoading();
}

class MessagesLoaded extends MessagesState {
  final ChatUserModel currentUser;

  /// All conversations sorted: pinned first, then by most-recent message.
  final List<ConversationModel> conversations;

  /// Filtered subset when the user is searching.
  final List<ConversationModel> filteredConversations;

  /// Messages for the *currently open* conversation (null if none open).
  final String? activeConversationId;
  final List<MessageModel> activeMessages;

  /// Total unread count for the AppBar badge.
  final int totalUnread;
  final String searchQuery;

  const MessagesLoaded({
    required this.currentUser,
    required this.conversations,
    this.filteredConversations = const [],
    this.activeConversationId,
    this.activeMessages = const [],
    this.totalUnread = 0,
    this.searchQuery = '',
  });

  bool get isSearching => searchQuery.isNotEmpty;

  List<ConversationModel> get displayedConversations =>
      isSearching ? filteredConversations : conversations;

  @override
  List<Object?> get props => [
        currentUser,
        conversations,
        filteredConversations,
        activeConversationId,
        activeMessages,
        totalUnread,
        searchQuery,
      ];

  MessagesLoaded copyWith({
    ChatUserModel? currentUser,
    List<ConversationModel>? conversations,
    List<ConversationModel>? filteredConversations,
    String? activeConversationId,
    List<MessageModel>? activeMessages,
    int? totalUnread,
    String? searchQuery,
  }) =>
      MessagesLoaded(
        currentUser: currentUser ?? this.currentUser,
        conversations: conversations ?? this.conversations,
        filteredConversations:
            filteredConversations ?? this.filteredConversations,
        activeConversationId: activeConversationId ?? this.activeConversationId,
        activeMessages: activeMessages ?? this.activeMessages,
        totalUnread: totalUnread ?? this.totalUnread,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

class MessagesError extends MessagesState {
  final String message;
  const MessagesError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────────────────────────────

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(const MessagesInitial()) {
    on<LoadConversations>(_onLoad);
    on<OpenConversation>(_onOpen);
    on<SendMessage>(_onSend);
    on<IncomingMessage>(_onIncoming);
    on<MarkConversationRead>(_onMarkRead);
    on<TrainerRelationshipChanged>(_onTrainerChanged);
    on<SearchConversations>(_onSearch);
    on<TogglePinConversation>(_onTogglePin);
  }

  // ── In-memory message store (replace with Firestore / WebSocket) ──────────
  final Map<String, List<MessageModel>> _messageStore = {};

  // ── SEED DATA (mirrors appState mock users) ────────────────────────────────
  static final ChatUserModel _currentUser = ChatUserModel(
    id: 'me',
    firstName: 'Omar',
    lastName: 'bin al-Majd',
    role: UserRole.trainee,
    currentTrainerId: 'ahmed1', // actively training with Ahmed
  );

  static final _ahmed = ChatUserModel(
    id: 'ahmed1',
    firstName: 'Ahmed',
    lastName: 'al-Demerdash',
    role: UserRole.trainer,
  );

  static final _sara = ChatUserModel(
    id: 'sara_fit',
    firstName: 'Sara',
    lastName: 'M.',
    role: UserRole.trainer,
  );

  static final _coachAli = ChatUserModel(
    id: 'coach_ali',
    firstName: 'Ali',
    lastName: 'Hassan',
    role: UserRole.trainer,
  );

  static final _mikeT = ChatUserModel(
    id: 'miket_lifts',
    firstName: 'Mike',
    lastName: 'T.',
    role: UserRole.trainee,
  );

  static final _nadiaR = ChatUserModel(
    id: 'nadia_eats',
    firstName: 'Nadia',
    lastName: 'R.',
    role: UserRole.trainee,
  );

  List<ConversationModel> _buildSeedConversations() {
    final now = DateTime.now();

    _messageStore['conv_ahmed'] = [
      _msg(
          'conv_ahmed',
          'ahmed1',
          'Good morning! Are you ready for today\'s session?',
          now.subtract(const Duration(hours: 2, minutes: 30))),
      _msg('conv_ahmed', 'me', 'Absolutely! Let\'s crush it 💪',
          now.subtract(const Duration(hours: 2, minutes: 25))),
      _msg(
          'conv_ahmed',
          'ahmed1',
          'Perfect. I updated your programme — check the new deadlift progression.',
          now.subtract(const Duration(minutes: 8))),
    ];

    _messageStore['conv_sara'] = [
      _msg('conv_sara', 'sara_fit', 'How was the HIIT session yesterday?',
          now.subtract(const Duration(hours: 5))),
      _msg('conv_sara', 'me', 'Brutal but great 😅',
          now.subtract(const Duration(hours: 4, minutes: 50))),
    ];

    _messageStore['conv_ali'] = [
      _msg('conv_ali', 'coach_ali', 'Don\'t forget your stretching before bed.',
          now.subtract(const Duration(hours: 3))),
    ];

    _messageStore['conv_mike'] = [
      _msg('conv_mike', 'miket_lifts', 'Bro, what\'s your bench PR?',
          now.subtract(const Duration(days: 1))),
      _msg('conv_mike', 'me', '120kg — aiming for 130 by end of month!',
          now.subtract(const Duration(days: 1))),
    ];

    _messageStore['conv_nadia'] = [
      _msg('conv_nadia', 'nadia_eats', 'Great job on the meal prep! 🥗',
          now.subtract(const Duration(days: 2))),
    ];

    return [
      ConversationModel(
        id: 'conv_ahmed',
        participant: _ahmed,
        lastMessage: _messageStore['conv_ahmed']!.last,
        unreadCount: 1,
        updatedAt: _messageStore['conv_ahmed']!.last.timestamp,
      ),
      ConversationModel(
        id: 'conv_sara',
        participant: _sara,
        lastMessage: _messageStore['conv_sara']!.last,
        unreadCount: 0,
        updatedAt: _messageStore['conv_sara']!.last.timestamp,
      ),
      ConversationModel(
        id: 'conv_ali',
        participant: _coachAli,
        lastMessage: _messageStore['conv_ali']!.last,
        unreadCount: 1,
        updatedAt: _messageStore['conv_ali']!.last.timestamp,
      ),
      ConversationModel(
        id: 'conv_mike',
        participant: _mikeT,
        lastMessage: _messageStore['conv_mike']!.last,
        unreadCount: 0,
        updatedAt: _messageStore['conv_mike']!.last.timestamp,
      ),
      ConversationModel(
        id: 'conv_nadia',
        participant: _nadiaR,
        lastMessage: _messageStore['conv_nadia']!.last,
        unreadCount: 0,
        updatedAt: _messageStore['conv_nadia']!.last.timestamp,
      ),
    ];
  }

  MessageModel _msg(String convId, String senderId, String text, DateTime ts) =>
      MessageModel(
        id: '${convId}_${ts.millisecondsSinceEpoch}',
        conversationId: convId,
        senderId: senderId,
        text: text,
        timestamp: ts,
        status: senderId == 'me' ? MessageStatus.read : MessageStatus.delivered,
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<ConversationModel> _sorted(List<ConversationModel> list) {
    final copy = List<ConversationModel>.from(list);
    copy.sort((a, b) {
      // Pinned first
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      // Then by most recent
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return copy;
  }

  int _totalUnread(List<ConversationModel> list) =>
      list.fold(0, (sum, c) => sum + c.unreadCount);

  // ── EVENT HANDLERS ────────────────────────────────────────────────────────

  Future<void> _onLoad(
      LoadConversations event, Emitter<MessagesState> emit) async {
    emit(const MessagesLoading());
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 600));
    final convs = _sorted(_buildSeedConversations());
    emit(MessagesLoaded(
      currentUser: _currentUser,
      conversations: convs,
      totalUnread: _totalUnread(convs),
    ));
  }

  Future<void> _onOpen(
      OpenConversation event, Emitter<MessagesState> emit) async {
    final s = state as MessagesLoaded;
    final messages = _messageStore[event.conversationId] ?? [];
    emit(s.copyWith(
      activeConversationId: event.conversationId,
      activeMessages: List.from(messages),
    ));
    // Auto-mark as read
    add(MarkConversationRead(event.conversationId));
  }

  Future<void> _onSend(SendMessage event, Emitter<MessagesState> emit) async {
    final s = state as MessagesLoaded;
    final msg = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: event.conversationId,
      senderId: 'me',
      text: event.text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    // Optimistic update
    final updatedMessages = [...(s.activeMessages), msg];
    _messageStore[event.conversationId] = updatedMessages;

    final updatedConvs = s.conversations.map((c) {
      if (c.id == event.conversationId) {
        return c.copyWith(
          lastMessage: msg,
          updatedAt: msg.timestamp,
        );
      }
      return c;
    }).toList();

    emit(s.copyWith(
      activeMessages: updatedMessages,
      conversations: _sorted(updatedConvs),
    ));

    // Simulate delivery confirmation after a short delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (state is MessagesLoaded) {
      final s2 = state as MessagesLoaded;
      final delivered = s2.activeMessages.map((m) {
        if (m.id == msg.id) return m.copyWith(status: MessageStatus.delivered);
        return m;
      }).toList();
      _messageStore[event.conversationId] = delivered;
      emit(s2.copyWith(activeMessages: delivered));
    }
  }

  Future<void> _onIncoming(
      IncomingMessage event, Emitter<MessagesState> emit) async {
    if (state is! MessagesLoaded) return;
    final s = state as MessagesLoaded;
    final convId = event.message.conversationId;

    // Append to message store
    _messageStore[convId] = [...(_messageStore[convId] ?? []), event.message];

    // Update conversation list
    final updatedConvs = s.conversations.map((c) {
      if (c.id == convId) {
        final isActive = s.activeConversationId == convId;
        return c.copyWith(
          lastMessage: event.message,
          unreadCount: isActive ? 0 : c.unreadCount + 1,
          updatedAt: event.message.timestamp,
        );
      }
      return c;
    }).toList();

    // Update active messages if this conv is open
    final updatedActive = s.activeConversationId == convId
        ? [...s.activeMessages, event.message]
        : s.activeMessages;

    emit(s.copyWith(
      conversations: _sorted(updatedConvs),
      activeMessages: updatedActive,
      totalUnread: _totalUnread(updatedConvs),
    ));
  }

  Future<void> _onMarkRead(
      MarkConversationRead event, Emitter<MessagesState> emit) async {
    if (state is! MessagesLoaded) return;
    final s = state as MessagesLoaded;
    final updatedConvs = s.conversations.map((c) {
      if (c.id == event.conversationId) return c.copyWith(unreadCount: 0);
      return c;
    }).toList();
    emit(s.copyWith(
      conversations: updatedConvs,
      totalUnread: _totalUnread(updatedConvs),
    ));
  }

  Future<void> _onTrainerChanged(
      TrainerRelationshipChanged event, Emitter<MessagesState> emit) async {
    if (state is! MessagesLoaded) return;
    final s = state as MessagesLoaded;
    final updatedUser = s.currentUser.copyWith(
      currentTrainerId: event.newTrainerId,
      clearCurrentTrainer: event.newTrainerId == null,
    );
    // Re-emit so badges throughout the UI rebuild automatically.
    emit(s.copyWith(currentUser: updatedUser));
  }

  Future<void> _onSearch(
      SearchConversations event, Emitter<MessagesState> emit) async {
    if (state is! MessagesLoaded) return;
    final s = state as MessagesLoaded;
    final q = event.query.toLowerCase().trim();
    final filtered = q.isEmpty
        ? <ConversationModel>[]
        : s.conversations
            .where((c) =>
                c.participant.fullName.toLowerCase().contains(q) ||
                (c.lastMessage?.text?.toLowerCase().contains(q) ?? false))
            .toList();
    emit(s.copyWith(searchQuery: event.query, filteredConversations: filtered));
  }

  Future<void> _onTogglePin(
      TogglePinConversation event, Emitter<MessagesState> emit) async {
    if (state is! MessagesLoaded) return;
    final s = state as MessagesLoaded;
    final updatedConvs = s.conversations.map((c) {
      if (c.id == event.conversationId) {
        return c.copyWith(isPinned: !c.isPinned);
      }
      return c;
    }).toList();
    emit(s.copyWith(conversations: _sorted(updatedConvs)));
  }
}
