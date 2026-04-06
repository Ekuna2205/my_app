import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool useSafeArea;

  const AppBackground({
    super.key,
    required this.child,
    this.title,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final body = Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -20,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: -30,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
        if (title != null)
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(top: title == null ? 0 : 70),
          child: child,
        ),
      ],
    );

    if (useSafeArea) {
      return SafeArea(child: body);
    }
    return body;
  }
}
