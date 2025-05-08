import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class MacosWindowTitleBar extends StatelessWidget {
  const MacosWindowTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        color: const Color(0xFF1C1C1E),
        child: Row(
          children: [
            const MacosWindowButtons(),
            const SizedBox(width: 8),
            Expanded(child: MoveWindow()),
          ],
        ),
      ),
    );
  }
}

class MacosWindowButtons extends StatelessWidget {
  const MacosWindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton(const Color(0xFFFF5F56), () => appWindow.close()),
        const SizedBox(width: 6),
        _buildButton(const Color(0xFFFFBD2E), () => appWindow.minimize()),
        const SizedBox(width: 6),
        _buildButton(const Color(0xFF27C93F), () {
          appWindow.isMaximized ? appWindow.restore() : appWindow.maximize();
        }),
      ],
    );
  }

  Widget _buildButton(Color color, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
