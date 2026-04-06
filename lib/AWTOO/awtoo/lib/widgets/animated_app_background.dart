import 'package:flutter/material.dart';

class AnimatedAppBackground extends StatefulWidget {
  final Widget child;
  final String? title;

  const AnimatedAppBackground({super.key, required this.child, this.title});

  @override
  State<AnimatedAppBackground> createState() => _AnimatedAppBackgroundState();
}

class _AnimatedAppBackgroundState extends State<AnimatedAppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation1;
  late final Animation<double> _animation2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _animation1 = Tween<double>(begin: 0, end: 30).animate(_controller);
    _animation2 = Tween<double>(begin: 0, end: 20).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _circle({
    required double size,
    required Color color,
    required double top,
    required double left,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          top: top + _animation1.value,
          left: left + _animation2.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        _circle(
          size: 180,
          color: Colors.white.withValues(alpha: 0.22),
          top: -30,
          left: 240,
        ),
        _circle(
          size: 140,
          color: Colors.white.withValues(alpha: 0.18),
          top: 120,
          left: -30,
        ),
        _circle(
          size: 220,
          color: Colors.white.withValues(alpha: 0.16),
          top: 520,
          left: 180,
        ),
        SafeArea(
          child: Column(
            children: [
              if (widget.title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Text(
                    widget.title!,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ],
    );
  }
}
