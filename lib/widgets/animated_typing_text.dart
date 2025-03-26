// widgets/animated_typing_text.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AnimatedTypingText extends StatefulWidget {
  final String message;
  final ThemeData theme;

  const AnimatedTypingText({
    Key? key,
    required this.message,
    required this.theme,
  }) : super(key: key);

  @override
  _AnimatedTypingTextState createState() => _AnimatedTypingTextState();
}

class _AnimatedTypingTextState extends State<AnimatedTypingText> {
  String visibleText = '';
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_index < widget.message.length) {
        setState(() {
          visibleText += widget.message[_index];
          _index++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: MarkdownBody(
        data: visibleText,
        styleSheet: MarkdownStyleSheet(
          p: widget.theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          strong: widget.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          em: widget.theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          code: widget.theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          codeblockDecoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
