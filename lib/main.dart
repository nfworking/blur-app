import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart'; // Import your models (Project, Task, etc.)
import 'widgets/macos_window_title_bar.dart';  // Import custom window controls
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and window effects
  await Hive.initFlutter();
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(TaskAdapter());

  await Hive.openBox<Project>('projectsBox');

  // Initialize window effects for Windows (Acrylic effect)
  if (Platform.isWindows) {
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.acrylic,
    color: Colors.transparent, // fully transparent to let acrylic through
    dark: true, // optional: adjusts for light/dark themes
  );
}


  // Set up window behavior for when the app starts
  doWhenWindowReady(() {
    appWindow
      ..minSize = const Size(800, 600)
      ..size = const Size(1000, 700)
      ..alignment = Alignment.center
      ..title = "Task Manager"
      ..show();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
  ),
  home: const HomeScreen(),
);

  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Project> _projectsBox;
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();

  int? _selectedProjectIndex;
  int? _selectedTaskIndex;

  @override
  void initState() {
    super.initState();
    _projectsBox = Hive.box<Project>('projectsBox');
  }

  void _addProject() {
    final name = _projectController.text.trim();
    if (name.isNotEmpty) {
      final newProject = Project(
        name: name,
        createdAt: DateTime.now(),
        tasks: [],
      );
      _projectsBox.add(newProject);
      _projectController.clear();
      setState(() {});
    }
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isNotEmpty && _selectedProjectIndex != null) {
      final newTask = Task(
        title: title,
        createdAt: DateTime.now(),
      );
      final project = _projectsBox.getAt(_selectedProjectIndex!);
      project!.tasks.add(newTask);
      project.save();
      _taskController.clear();
      setState(() {});
    }
  }

  void _toggleTaskDone(int taskIndex) {
    final project = _projectsBox.getAt(_selectedProjectIndex!);
    final task = project!.tasks[taskIndex];
    task.isDone = !task.isDone;
    task.save();
    setState(() {});
  }

  void _deleteTask(int taskIndex) {
    final project = _projectsBox.getAt(_selectedProjectIndex!);
    project!.tasks.removeAt(taskIndex);
    project.save();
    setState(() {});
  }

  void _selectProject(int index) {
    setState(() {
      _selectedProjectIndex = index;
      _selectedTaskIndex = null;  // Reset task selection
    });
  }

  @override
  Widget build(BuildContext context) {
    final projects = _projectsBox.values.toList().cast<Project>();

   return Scaffold(
  backgroundColor: Colors.transparent,
  appBar: PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: MacosWindowTitleBar(),
  ),
body: BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  child: Row(
    children: [
      // Sidebar: Project List
      Container(
        width: 280,
        color: Colors.black.withOpacity(0.9),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _projectController,
                decoration: const InputDecoration(
                  hintText: 'Enter Project name...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addProject(),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _projectsBox.listenable(),
                builder: (context, Box<Project> box, _) {
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final project = box.getAt(index)!;
                      return ListTile(
                        title: Text(project.name),
                        onTap: () => _selectProject(index),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

          // Main Content: Tasks in the selected project
          Expanded(
            child: _selectedProjectIndex == null
                ? const Center(child: Text('Select a project to view tasks'))
                : Column(
                    children: [
                      // Project Name
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          projects[_selectedProjectIndex!].name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Add task field
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _taskController,
                          decoration: const InputDecoration(
                            hintText: 'Enter task title...',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addTask(),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: projects[_selectedProjectIndex!].tasks.length,
                          itemBuilder: (context, taskIndex) {
                            final task = projects[_selectedProjectIndex!].tasks[taskIndex];
                            return ListTile(
                              title: Text(task.title),
                              trailing: IconButton(
                                icon: Icon(task.isDone ? Icons.check_box : Icons.check_box_outline_blank),
                                onPressed: () => _toggleTaskDone(taskIndex),
                              ),
                              onLongPress: () => _deleteTask(taskIndex),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
 ),
          ],
        ),
      ),
    );
  } // <-- This was missing
}
