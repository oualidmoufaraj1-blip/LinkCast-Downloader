import 'package:flutter/cupertino.dart';

import '../services/download_progress.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_scope.dart';

class DownloadProgressBanner extends StatelessWidget {
  const DownloadProgressBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ListenableBuilder(
      listenable: DownloadProgress.instance,
      builder: (context, _) {
        final progress = DownloadProgress.instance;
        if (!progress.active) return const SizedBox.shrink();

        final hasFraction = progress.progress > 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: palette.primaryLight,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Downloading ${progress.fileName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.label,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 4,
                    child: hasFraction
                        ? LinearProgressIndicator(
                            value: progress.progress,
                            backgroundColor: palette.separator,
                            color: AppColors.primary,
                          )
                        : const _IndeterminateProgressBar(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IndeterminateProgressBar extends StatefulWidget {
  const _IndeterminateProgressBar();

  @override
  State<_IndeterminateProgressBar> createState() =>
      _IndeterminateProgressBarState();
}

class _IndeterminateProgressBarState extends State<_IndeterminateProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _IndeterminateBarPainter(
            animationValue: _controller.value,
            backgroundColor: palette.separator,
            color: AppColors.primary,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _IndeterminateBarPainter extends CustomPainter {
  _IndeterminateBarPainter({
    required this.animationValue,
    required this.backgroundColor,
    required this.color,
  });

  final double animationValue;
  final Color backgroundColor;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    final barWidth = size.width * 0.4;
    final left = (size.width + barWidth) * animationValue - barWidth;
    canvas.drawRect(
      Rect.fromLTWH(left, 0, barWidth, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _IndeterminateBarPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class LinearProgressIndicator extends StatelessWidget {
  const LinearProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.color,
  });

  final double? value;
  final Color? backgroundColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarPainter(
        value: value,
        backgroundColor: backgroundColor ?? const Color(0xFFE5E5EA),
        color: color ?? AppColors.primary,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.value,
    required this.backgroundColor,
    required this.color,
  });

  final double? value;
  final Color backgroundColor;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = backgroundColor,
    );
    final fraction = value ?? 0;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * fraction, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
