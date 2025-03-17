import 'package:flutter/material.dart';

class CropPriceChart extends StatelessWidget {
  const CropPriceChart({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder for a real chart implementation
    // In a real app, you would use a charting library like fl_chart or syncfusion_flutter_charts
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: ChartPainter(
        context: context,
        data: const [6.9, 7.1, 6.8, 7.0, 7.2, 7.1, 7.3, 7.25],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final BuildContext context;
  final List<double> data;

  ChartPainter({required this.context, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.3),
          Theme.of(context).colorScheme.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = Theme.of(context).colorScheme.primary
      ..style = PaintingStyle.fill;

    final outlineDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Find min and max values for scaling
    final double minValue = data.reduce((a, b) => a < b ? a : b);
    final double maxValue = data.reduce((a, b) => a > b ? a : b);
    final double range = maxValue - minValue;

    // Create path for the line
    final path = Path();
    final fillPath = Path();

    // Calculate point positions
    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - (data[i] - minValue) / range * size.height * 0.8;
      points.add(Offset(x, y));
    }

    // Draw the line path
    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
      fillPath.lineTo(points[i].dx, points[i].dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    // Draw the fill
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw dots at each data point
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 4, outlineDotPaint);
    }

    // Draw the last point larger to highlight current value
    canvas.drawCircle(points.last, 6, dotPaint);
    canvas.drawCircle(points.last, 6, outlineDotPaint);

    // Draw price labels
    final textStyle = TextStyle(
      color: Colors.grey.shade600,
      fontSize: 10,
    );
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw min and max labels
    textPainter.text = TextSpan(
      text: '\$${maxValue.toStringAsFixed(2)}',
      style: textStyle,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, 5));

    textPainter.text = TextSpan(
      text: '\$${minValue.toStringAsFixed(2)}',
      style: textStyle,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, size.height - 15));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}