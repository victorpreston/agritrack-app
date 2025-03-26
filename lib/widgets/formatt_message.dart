import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FormattedMessageContent extends StatelessWidget {
  final String message;
  final bool isUser;
  final ThemeData theme;

  const FormattedMessageContent({
    Key? key,
    required this.message,
    required this.isUser,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = theme.brightness == Brightness.dark;

    // If it's a user message, just display as regular text
    if (isUser) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      );
    }

    // For bot messages, use Markdown to handle formatting
    return Padding(
      padding: const EdgeInsets.all(12),
      child: MarkdownBody(
        data: message,
        styleSheet: MarkdownStyleSheet(
          p: theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          strong: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          em: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          code: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: isDarkMode
                ? Colors.grey[800]
                : Colors.grey[200],
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          codeblockDecoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        selectable: true,
      ),
    );
  }
}