import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class FarmHealthWidget extends StatelessWidget {
  final VoidCallback onViewMoreTap;

  const FarmHealthWidget({
    super.key,
    required this.onViewMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with line and button
        Row(
          children: [
            Text(
              'Farm Health Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onViewMoreTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'More',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      HugeIcons.strokeRoundedLinkForward,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildHealthIndicator(
                    context,
                    'Soil Moisture',
                    '75%',
                    Icons.water_drop,
                    Colors.blue,
                    0.75,
                  ),
                  const SizedBox(width: 16),
                  _buildHealthIndicator(
                    context,
                    'Soil pH',
                    '6.5',
                    Icons.science,
                    Colors.green,
                    0.65,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildHealthIndicator(
                    context,
                    'Nitrogen',
                    '60%',
                    Icons.eco,
                    Colors.amber,
                    0.6,
                  ),
                  const SizedBox(width: 16),
                  _buildHealthIndicator(
                    context,
                    'Crop Health',
                    '90%',
                    Icons.spa,
                    Colors.teal,
                    0.9,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build Health Indicator
  Widget _buildHealthIndicator(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      double progress,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}