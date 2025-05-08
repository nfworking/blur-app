import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 1)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  DateTime createdAt;

  Todo({
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });
}
