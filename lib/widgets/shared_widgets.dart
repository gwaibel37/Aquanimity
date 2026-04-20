import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PDANotification extends StatelessWidget {
  final String message;
  final Color color;
  final bool visible;

  const PDANotification({
    super.key,
    required this.message,
    required this.color,
    required this.visible,
  });

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
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AbyssalBackground extends StatefulWidget {
  final Widget child;
  final String? backgroundImagePath;
  const AbyssalBackground({
    super.key,
    required this.child,
    this.backgroundImagePath,
  });

  @override
  State<AbyssalBackground> createState() => _AbyssalBackgroundState();
}

class _AbyssalBackgroundState extends State<AbyssalBackground> {
  ImageProvider? _backgroundImage;
  bool _hasBackgroundImage = false;

  @override
  void initState() {
    super.initState();
    _resolveBackgroundImage();
  }

  @override
  void didUpdateWidget(covariant AbyssalBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backgroundImagePath != widget.backgroundImagePath) {
      _resolveBackgroundImage();
    }
  }

  void _resolveBackgroundImage() {
    final String? path = widget.backgroundImagePath;
    if (path != null) {
      print('DEBUG: _resolveBackgroundImage called with path: ${path.substring(0, path.length < 100 ? path.length : 100)}');
    } else {
      print('DEBUG: _resolveBackgroundImage called with null path');
    }
    if (path != null && path.isNotEmpty) {
      if (path.startsWith('data:')) {
        // Handle data URL (base64 encoded image)
        try {
          // Extract base64 data from data URL
          final parts = path.split(',');
          if (parts.length < 2) {
            throw Exception('Invalid data URL format');
          }
          final base64Data = parts.last;
          final bytes = base64Decode(base64Data);
          _backgroundImage = MemoryImage(bytes);
          _hasBackgroundImage = true;
          print('DEBUG: Successfully decoded data URL image, bytes: ${bytes.length}');
        } catch (e) {
          // If decoding fails, set no background
          print('DEBUG: Failed to decode image: $e');
          _backgroundImage = null;
          _hasBackgroundImage = false;
        }
      } else if (!kIsWeb && File(path).existsSync()) {
        // Handle file path on mobile
        _backgroundImage = FileImage(File(path));
        _hasBackgroundImage = true;
      } else {
        _backgroundImage = null;
        _hasBackgroundImage = false;
      }
    } else {
      _backgroundImage = null;
      _hasBackgroundImage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: _hasBackgroundImage
            ? DecorationImage(
                image: _backgroundImage!,
                fit: BoxFit.cover,
                opacity: 0.7,
              )
            : null,
        gradient: !_hasBackgroundImage
            ? RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Theme.of(context).colorScheme.primary.withAlpha(180),
                  Theme.of(context).colorScheme.surface,
                ],
                stops: const [0.0, 0.8],
              )
            : null,
      ),
      child: widget.child,
    );
  }
}

class OneShotFloat extends StatelessWidget {
  final Widget child;
  final double offset;
  final int delayMs;
  const OneShotFloat({
    super.key,
    required this.child,
    this.offset = 30.0,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: offset, end: 0.0),
      duration: Duration(milliseconds: 800 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: (1 - (value / offset)).clamp(0, 1),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
