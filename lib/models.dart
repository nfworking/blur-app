// models.dart
import 'package:hive/hive.dart';

part 'models.g.dart'; // Hive will generate this file

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  List<Task> tasks;

  Project({
    required this.name,
    required this.createdAt,
    required this.tasks,
  });

  @override
  String toString() => 'Project(name: $name, tasks: ${tasks.length})';
}

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  DateTime createdAt;

  Task({
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });

  @override
  String toString() => 'Task(title: $title, isDone: $isDone)';
}
