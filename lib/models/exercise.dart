import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final int id;
  final String name;
  final String videoUrl;
  final String targetBodyPart;
  final String trainingType;

  const Exercise({
    required this.id,
    required this.name,
    required this.videoUrl,
    required this.targetBodyPart,
    required this.trainingType,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: _readInt(json['id']),
      name: _readString(json['name']),
      videoUrl: _readString(json['videoUrl']),
      targetBodyPart: _readString(json['targetBodyPart']),
      trainingType: _readString(json['trainingType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'videoUrl': videoUrl,
      'targetBodyPart': targetBodyPart,
      'trainingType': trainingType,
    };
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _readString(Object? value) {
    if (value is String) return value;
    return '';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        videoUrl,
        targetBodyPart,
        trainingType,
      ];
}
