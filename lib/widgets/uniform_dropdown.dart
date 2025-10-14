import 'package:flutter/material.dart';

class UniformDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final String? labelText;
  final bool isExpanded;
  final Color? dropdownColor;
  final Color? textColor;
  final Color? iconColor;
  final double? itemHeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final double? elevation;

  const UniformDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText = 'Select an item',
    this.labelText,
    this.isExpanded = true,
    this.dropdownColor,
    this.textColor,
    this.iconColor,
    this.itemHeight,
    this.padding,
    this.borderRadius,
    this.border,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = Theme.of(context).textTheme.bodyLarge?.color;
    
    // Couleurs selon le thème
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF87CEEB) : const Color(0xFF1A237E); // Bleu ciel en nuit, bleu nuit en jour

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: dropdownColor ?? Theme.of(context).cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: border ?? Border.all(color: borderColor, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value != null && items.contains(value)) ? value : null,
              hint: Text(
                hintText,
                style: TextStyle(
                  color: textColor ?? defaultTextColor?.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: iconColor ?? borderColor,
                size: 16,
              ),
              isExpanded: isExpanded,
              dropdownColor: dropdownColor ?? Theme.of(context).cardColor,
              style: TextStyle(
                color: textColor ?? defaultTextColor,
                fontSize: 12,
              ),
              itemHeight: itemHeight ?? 48, // Minimum requis par Flutter
              elevation: (elevation ?? 8).toInt(),
              items: items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: textColor ?? defaultTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
      ),
    );
  }
}