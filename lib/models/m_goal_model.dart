import 'package:equatable/equatable.dart';

class GoalCategory extends Equatable {
  final String id;
  final String name;
  final List<GoalItem> items;

  const GoalCategory({
    required this.id,
    required this.name,
    required this.items,
  });

  @override
  List<Object?> get props => [id, name, items];
}

class GoalItem extends Equatable {
  final String id;
  final String categoryId;
  final String title;
  final String description;

  const GoalItem({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [id, categoryId, title, description];
}
