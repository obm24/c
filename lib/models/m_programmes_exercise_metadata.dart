import 'package:equatable/equatable.dart';

class ExerciseMetadata extends Equatable {
  final List<String> trainingTypes;
  final List<String> bodyParts;

  const ExerciseMetadata({
    required this.trainingTypes,
    required this.bodyParts,
  });

  const ExerciseMetadata.empty()
      : trainingTypes = const [],
        bodyParts = const [];

  factory ExerciseMetadata.fromJson(Map<String, dynamic> json) {
    final bodyParts = _readStringList(json['bodyParts']);
    return ExerciseMetadata(
      trainingTypes: _readStringList(json['trainingTypes']),
      bodyParts: bodyParts.isNotEmpty
          ? bodyParts
          : _readStringList(json['targetBodyParts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainingTypes': trainingTypes,
      'bodyParts': bodyParts,
    };
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  @override
  List<Object?> get props => [trainingTypes, bodyParts];
}
