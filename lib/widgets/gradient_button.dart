import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? trailing;
  final bool expanded;

  const GradientButton({
    super.key,
    required this.text,
    this.onTap,
    this.trailing,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        decoration: BoxDecoration(
          gradient: onTap == null
              ? LinearGradient(colors: [
            AppColors.purple.withValues(alpha: 0.4),
            AppColors.teal.withValues(alpha: 0.35),
          ])
              : kMainGradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:
            expanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 10),
                Icon(trailing, size: 18, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );

    return expanded
        ? SizedBox(width: double.infinity, child: btn)
        : btn;
  }
}




