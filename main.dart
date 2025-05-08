import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the window and set the acrylic effect
  await Window.initialize();
  if (Platform.isWindows) {
    await Window.setEffect(
      effect: WindowEffect.acrylic,
      color: const Color(0xCC222222), // Semi-transparent dark overlay
    );
  }

  runApp(const MyApp());

  if (Platform.isWindows) {
    doWhenWindowReady(() {
      appWindow
        ..minSize = const Size(640, 360)
        ..size = const Size(800, 600)
        ..alignment = Alignment.center
        ..show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make the background transparent
      body: Row(
        children: [
          // Acrylic Sidebar
          SizedBox(
            width: 250,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2), // Semi-transparent overlay
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.menu, color: Colors.white, size: 50),
                  SizedBox(height: 20),
                  Text(
                    'Acrylic Sidebar',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          // Main Content Area
          Expanded(
            child: Container(
              color: Colors.transparent, // Transparent to show acrylic effect
              child: const Center(
                child: Text(
                  'Main Content',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
