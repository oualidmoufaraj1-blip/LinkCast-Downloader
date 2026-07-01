import 'package:flutter/cupertino.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDark,
      child: FadeTransition(
        opacity: _fadeIn,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40FF6B00),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.tv_fill,
                    size: 44,
                    color: AppColors.labelOnDark,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: AppColors.labelOnDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.tagline,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.secondaryOnDark,
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
