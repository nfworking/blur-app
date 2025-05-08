// window_controls.dart
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Minimize Button
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: appWindow.minimize,
        ),
        // Maximize Button
        IconButton(
          icon: const Icon(Icons.crop_square),
          onPressed: () {
            appWindow.isMaximized ? appWindow.restore() : appWindow.maximize();
          },
        ),
        // Close Button
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: appWindow.close,
        ),
      ],
    );
  }
}
