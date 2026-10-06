import 'package:flutter/material.dart';

/// Reveals [text] one character at a time, starting after [startDelay].
/// Used for body copy sitting over a photo, where a static fade-in reads as
/// flat compared to the headline and buttons around it.
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.speed = const Duration(milliseconds: 18),
    this.startDelay = Duration.zero,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration speed;
  final Duration startDelay;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.startDelay, _tick);
  }

  void _tick() {
    if (!mounted || _charCount >= widget.text.length) return;
    setState(() => _charCount++);
    Future<void>.delayed(widget.speed, _tick);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _charCount),
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
