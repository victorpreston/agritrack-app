import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const NotificationBanner({
    super.key,
    required this.message,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSuccess ? AppTheme.primaryColor : AppTheme.errorColor;
    final Color borderColor = isSuccess ? AppTheme.primaryColor : AppTheme.errorColor;
    final Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : Colors.white;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(8),
          color: backgroundColor,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: textColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
