import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

class DownloadArrowIcon extends StatelessWidget {
  const DownloadArrowIcon({
    super.key,
    this.size = 48,
    this.color = AppColors.label,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DownloadArrowPainter(color: color),
    );
  }
}

class _DownloadArrowPainter extends CustomPainter {
  _DownloadArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final trayPath = Path()
      ..moveTo(w * 0.15, h * 0.72)
      ..lineTo(w * 0.15, h * 0.88)
      ..lineTo(w * 0.85, h * 0.88)
      ..lineTo(w * 0.85, h * 0.72);

    canvas.drawPath(trayPath, paint);

    final arrowPath = Path()
      ..moveTo(w * 0.5, h * 0.12)
      ..lineTo(w * 0.5, h * 0.62)
      ..moveTo(w * 0.28, h * 0.38)
      ..lineTo(w * 0.5, h * 0.62)
      ..lineTo(w * 0.72, h * 0.38);

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DownloadArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
