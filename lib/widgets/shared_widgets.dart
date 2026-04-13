import 'package:flutter/material.dart';

class PDANotification extends StatelessWidget {
  final String message;
  final Color color;
  final bool visible;

  const PDANotification({super.key, required this.message, required this.color, required this.visible});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      top: visible ? 60 : -120,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(230),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            boxShadow: [BoxShadow(color: color.withAlpha(80), blurRadius: 15)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sensors, color: color, size: 24),
              const SizedBox(width: 15),
              Flexible(child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1.1))),
            ],
          ),
        ),
      ),
    );
  }
}

class AbyssalBackground extends StatelessWidget {
  final Widget child;
  const AbyssalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha(180),
            Theme.of(context).colorScheme.background,
          ],
          stops: const [0.0, 0.8],
        ),
      ),
      child: child,
    );
  }
}

class OneShotFloat extends StatelessWidget {
  final Widget child;
  final double offset;
  final int delayMs;
  const OneShotFloat({super.key, required this.child, this.offset = 30.0, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: UniqueKey(),
      tween: Tween(begin: offset, end: 0.0),
      duration: Duration(milliseconds: 800 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(opacity: (1 - (value / offset)).clamp(0, 1), child: child),
        );
      },
      child: child,
    );
  }
}