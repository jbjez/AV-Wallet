import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool useAccentColor;
  final VoidCallback? onTap;

  const ThemedContainer({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.useAccentColor = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultTheme = theme.extension<ResultContainerTheme>();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: resultTheme?.backgroundColor ?? theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          border: Border.all(
            color: useAccentColor
                ? theme.primaryColor
                : (resultTheme?.borderColor ?? theme.primaryColor),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
} 