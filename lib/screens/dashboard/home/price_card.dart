import 'package:flutter/material.dart';
import '../../../services/commodities_service.dart';

class MarketPriceCard extends StatelessWidget {
  final CropPriceData data;

  const MarketPriceCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUp = data.priceChange >= 0;
    final priceFormatted = data.currentPrice.toStringAsFixed(2);
    final changeFormatted = data.percentChange.abs().toStringAsFixed(1);

    final currencySymbol = data.units.split('/')[0];

    final upColor = theme.brightness == Brightness.light
        ? const Color(0xFF22C55E)
        : const Color(0xFF34D399);

    final downColor = theme.brightness == Brightness.light
        ? theme.colorScheme.error
        : const Color(0xFFEF4444);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  data.crop,
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: isUp
                        ? upColor.withOpacity(0.1)
                        : downColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Icon(
                    isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isUp ? upColor : downColor,
                    size: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$currencySymbol $priceFormatted',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isUp ? Icons.trending_up : Icons.trending_down,
                  color: isUp ? upColor : downColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '$changeFormatted%',
                  style: TextStyle(
                    color: isUp ? upColor : downColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              data.lastUpdated,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingMarketPriceCard extends StatelessWidget {
  final String cropName;

  const LoadingMarketPriceCard({
    super.key,
    required this.cropName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        width: 140,
        height: 140,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cropName,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}