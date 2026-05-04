// =============================================================================
// MESSAGE MODELS
// All data classes for the real-time messaging system.
// =============================================================================

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// ENUMS
// ---------------------------------------------------------------------------

/// The platform role of a user. Drives badge logic throughout the chat UI.
enum UserRole { trainee, trainer }

/// Delivery state of a single message bubble.
enum MessageStatus { sending, sent, delivered, read, failed }

/// Supported content types for a message.
enum MessageType { text, image, file, voiceNote, system }

// ---------------------------------------------------------------------------
// USER MODEL
// ---------------------------------------------------------------------------

/// Lightweight profile used inside conversation and message models.
/// The [currentTrainerId] on the *local* user establishes the active
/// training relationship; once it is cleared the prominent UI highlight
/// in the chat list downgrades automatically.
class ChatUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final UserRole role;

  /// Only relevant on the currently authenticated user's object.
  /// Points to the trainer they are *actively* working with right now.
  final String? currentTrainerId;

  /// Optional avatar URL; null falls back to initials avatar.
  final String? avatarUrl;

  const ChatUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.currentTrainerId,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  factory ChatUserModel.fromJson(Map<String, dynamic> j) => ChatUserModel(
        id: j['id'] as String,
        firstName: j['firstName'] as String,
        lastName: j['lastName'] as String,
        role: UserRole.values.firstWhere((e) => e.name == j['role']),
        currentTrainerId: j['currentTrainerId'] as String?,
        avatarUrl: j['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'role': role.name,
        if (currentTrainerId != null) 'currentTrainerId': currentTrainerId,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };

  ChatUserModel copyWith({
    String? currentTrainerId,
    bool clearCurrentTrainer = false,
  }) =>
      ChatUserModel(
        id: id,
        firstName: firstName,
        lastName: lastName,
        role: role,
        currentTrainerId: clearCurrentTrainer
            ? null
            : (currentTrainerId ?? this.currentTrainerId),
        avatarUrl: avatarUrl,
      );
}

// ---------------------------------------------------------------------------
// MESSAGE MODEL
// ---------------------------------------------------------------------------

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? text;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;

  /// For image / file / voice-note messages.
  final String? mediaUrl;
  final String? mediaName;
  final int? mediaDurationSeconds; // voice notes

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.timestamp,
    this.text,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.mediaUrl,
    this.mediaName,
    this.mediaDurationSeconds,
  });

  bool get isFromMe => false; // resolved at widget level via currentUserId

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
        id: j['id'] as String,
        conversationId: j['conversationId'] as String,
        senderId: j['senderId'] as String,
        text: j['text'] as String?,
        type: MessageType.values.firstWhere((e) => e.name == j['type'],
            orElse: () => MessageType.text),
        status: MessageStatus.values.firstWhere((e) => e.name == j['status'],
            orElse: () => MessageStatus.sent),
        timestamp: DateTime.parse(j['timestamp'] as String),
        mediaUrl: j['mediaUrl'] as String?,
        mediaName: j['mediaName'] as String?,
        mediaDurationSeconds: j['mediaDurationSeconds'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'text': text,
        'type': type.name,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
        if (mediaName != null) 'mediaName': mediaName,
        if (mediaDurationSeconds != null)
          'mediaDurationSeconds': mediaDurationSeconds,
      };

  MessageModel copyWith({MessageStatus? status}) => MessageModel(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        text: text,
        type: type,
        status: status ?? this.status,
        timestamp: timestamp,
        mediaUrl: mediaUrl,
        mediaName: mediaName,
        mediaDurationSeconds: mediaDurationSeconds,
      );
}

// ---------------------------------------------------------------------------
// CONVERSATION MODEL
// ---------------------------------------------------------------------------

/// Represents a 1-to-1 chat room between the current user and one other
/// participant. Group chats are out of scope for this iteration.
class ConversationModel {
  final String id;

  /// The *other* participant (not the currently logged-in user).
  final ChatUserModel participant;

  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  /// Whether the current user has pinned this conversation.
  final bool isPinned;

  const ConversationModel({
    required this.id,
    required this.participant,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> j) =>
      ConversationModel(
        id: j['id'] as String,
        participant:
            ChatUserModel.fromJson(j['participant'] as Map<String, dynamic>),
        lastMessage: j['lastMessage'] != null
            ? MessageModel.fromJson(j['lastMessage'] as Map<String, dynamic>)
            : null,
        unreadCount: j['unreadCount'] as int? ?? 0,
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        isPinned: j['isPinned'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'participant': participant.toJson(),
        if (lastMessage != null) 'lastMessage': lastMessage!.toJson(),
        'unreadCount': unreadCount,
        'updatedAt': updatedAt.toIso8601String(),
        'isPinned': isPinned,
      };

  ConversationModel copyWith({
    MessageModel? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
    bool? isPinned,
  }) =>
      ConversationModel(
        id: id,
        participant: participant,
        lastMessage: lastMessage ?? this.lastMessage,
        unreadCount: unreadCount ?? this.unreadCount,
        updatedAt: updatedAt ?? this.updatedAt,
        isPinned: isPinned ?? this.isPinned,
      );
}

// ---------------------------------------------------------------------------
// ROLE RELATIONSHIP HELPER
// ---------------------------------------------------------------------------

/// Resolves how a [participant] should be badged relative to [currentUser].
enum ParticipantRelationship {
  currentTrainer, // actively training with this trainer right now
  pastTrainer, // was a trainer, relationship ended
  trainer, // a trainer the user has never trained with
  trainee, // a trainee client
}

ParticipantRelationship resolveRelationship({
  required ChatUserModel currentUser,
  required ChatUserModel participant,
}) {
  if (participant.role == UserRole.trainer) {
    if (currentUser.currentTrainerId == participant.id) {
      return ParticipantRelationship.currentTrainer;
    }
    // In a real app you'd check a "pastTrainerIds" list on the user model.
    // For now everything that isn't current defaults to general trainer.
    return ParticipantRelationship.trainer;
  }
  return ParticipantRelationship.trainee;
}

// ---------------------------------------------------------------------------
// COLOUR / ICON THEMING FOR ROLE BADGES  (used by both list & chat header)
// ---------------------------------------------------------------------------

class RoleTheme {
  final Color color;
  final IconData icon;
  final String label;

  const RoleTheme({
    required this.color,
    required this.icon,
    required this.label,
  });

  static RoleTheme of(ParticipantRelationship rel) {
    switch (rel) {
      case ParticipantRelationship.currentTrainer:
        return const RoleTheme(
          color: Color(0xFF34D399), // cardGreen
          icon: Icons.star_rounded,
          label: 'My Coach',
        );
      case ParticipantRelationship.pastTrainer:
        return const RoleTheme(
          color: Color(0xFFA0A5AA), // textSecondary
          icon: Icons.fitness_center_rounded,
          label: 'Past Trainer',
        );
      case ParticipantRelationship.trainer:
        return const RoleTheme(
          color: Color(0xFF60A5FA), // cardBlue
          icon: Icons.verified_rounded,
          label: 'Trainer',
        );
      case ParticipantRelationship.trainee:
        return const RoleTheme(
          color: Color(0xFFA78BFA), // cardPurple
          icon: Icons.person_rounded,
          label: 'Trainee',
        );
    }
  }
}
