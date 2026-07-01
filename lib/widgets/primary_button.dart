import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(12),
        color: enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.45),
        onPressed: enabled ? onPressed : null,
        child: isLoading
            ? const CupertinoActivityIndicator(color: AppColors.labelOnDark)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: AppColors.labelOnDark),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.labelOnDark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
