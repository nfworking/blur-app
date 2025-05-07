import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:path_provider/path_provider.dart';  // Import this to access getApplicationDocumentsDirectory

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Window.initialize();
  if (Platform.isWindows) {
    await Window.setEffect(
      effect: WindowEffect.acrylic,
      color: const Color(0xCC222222),
    );
  }

  final appDocumentDir = await getApplicationDocumentsDirectory();  // Access documents directory
  Hive.init(appDocumentDir.path);  // Initialize Hive with the directory path
  await Hive.openBox<Note>('notesBox');  // Open the Hive box

  doWhenWindowReady(() {
    appWindow
      ..minSize = const Size(800, 600)
      ..size = const Size(1000, 700)
      ..alignment = Alignment.center
      ..show();
  });

  runApp(const MyApp());
}

// Note class definition remains the same...
// Rest of the code continues as is...

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  String content;
  @HiveField(1)
  DateTime createdAt;

  Note({
    required this.content,
    required this.createdAt,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
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

enum ScreenMode { home, create, edit }

class _HomeScreenState extends State<HomeScreen> {
  late Box<Note> _notesBox;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  int? _selectedNoteIndex;
  ScreenMode _screenMode = ScreenMode.home;
  bool _isSidebarOpen = true;
  bool _isPreview = true;

  @override
  void initState() {
    super.initState();
    _notesBox = Hive.box<Note>('notesBox');
  }

  void _addNote() {
    if (_noteController.text.isNotEmpty) {
      final newNote = Note(
        content: _noteController.text,
        createdAt: DateTime.now(),
      );
      _notesBox.add(newNote);
      _noteController.clear();
      setState(() {
        _screenMode = ScreenMode.home;
      });
    }
  }

  void _selectNoteForEdit(int index) {
    setState(() {
      _selectedNoteIndex = index;
      _editController.text = _notesBox.getAt(index)!.content;
      _screenMode = ScreenMode.edit;
    });
  }

  void _deleteNoteAt(int index) {
    setState(() {
      _notesBox.deleteAt(index);
      if (_selectedNoteIndex == index) {
        _screenMode = ScreenMode.home;
        _selectedNoteIndex = null;
      }
    });
  }

  void _updateNote() {
    if (_selectedNoteIndex != null) {
      final updatedNote = Note(
        content: _editController.text,
        createdAt: _notesBox.getAt(_selectedNoteIndex!)!.createdAt,
      );
      _notesBox.putAt(_selectedNoteIndex!, updatedNote);
      setState(() {
        _screenMode = ScreenMode.home;
        _selectedNoteIndex = null;
        _editController.clear();
      });
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _openCreateNote() {
    setState(() {
      _screenMode = ScreenMode.create;
      _noteController.clear();
    });
  }

  void _togglePreview() {
    setState(() {
      _isPreview = !_isPreview;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orangeStyle = OutlinedButton.styleFrom(
      foregroundColor: Colors.orangeAccent,
      side: const BorderSide(color: Colors.orangeAccent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            width: _isSidebarOpen ? 280 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: _isSidebarOpen
                ? Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left),
                          color: Colors.orangeAccent,
                          onPressed: _toggleSidebar,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton.icon(
                          style: orangeStyle,
                          onPressed: _openCreateNote,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Note"),
                        ),
                      ),
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: _notesBox.listenable(),
                          builder: (context, Box<Note> box, _) {
                            return ListView.builder(
                              itemCount: box.length,
                              itemBuilder: (context, index) {
                                final note = box.getAt(index)!;
                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 12),
                                  title: MarkdownBody(
                                    data: note.content.split('\n').first,
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  subtitle: Text(
                                    DateFormat('MMM d, yyyy h:mm a')
                                        .format(note.createdAt),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.orangeAccent),
                                  ),
                                  tileColor: Colors.transparent,
                                  onTap: () => _selectNoteForEdit(index),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    color: Colors.orangeAccent,
                                    onPressed: () => _deleteNoteAt(index),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : null,
          ),

          // Main Panel
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: _screenMode == ScreenMode.home
                  ? _selectedNoteIndex != null
                      ? Markdown(
                          data: _notesBox.getAt(_selectedNoteIndex!)!.content,
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                      : const Center(
                          child: Text(
                            "Welcome!\nSelect a note or create a new one.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, color: Colors.white70),
                          ),
                        )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _screenMode == ScreenMode.create ? "Create Note" : "Edit Note",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: MarkdownEditorPlus(
                              controller: _screenMode == ScreenMode.create
                                  ? _noteController
                                  : _editController,
                              hintText: "Write your note using Markdown...",
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              style: orangeStyle,
                              onPressed: _screenMode == ScreenMode.create
                                  ? _addNote
                                  : _updateNote,
                              icon: const Icon(Icons.check),
                              label: const Text("Save"),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              style: orangeStyle,
                              onPressed: () {
                                setState(() {
                                  _screenMode = ScreenMode.home;
                                  _selectedNoteIndex = null;
                                  _noteController.clear();
                                  _editController.clear();
                                });
                              },
                              icon: const Icon(Icons.cancel),
                              label: const Text("Cancel"),
                            ),
                          ],
                        )
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

MarkdownEditorPlus({required TextEditingController controller, required String hintText}) {
}
