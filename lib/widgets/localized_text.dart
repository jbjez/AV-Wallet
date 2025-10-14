import 'package:flutter/material.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';

/// Widget qui force le rafraîchissement quand la langue change
class LocalizedText extends StatefulWidget {
  final String Function(AppLocalizations) textBuilder;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LocalizedText({
    super.key,
    required this.textBuilder,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<LocalizedText> createState() => _LocalizedTextState();
}

class _LocalizedTextState extends State<LocalizedText> {
  @override
  Widget build(BuildContext context) {
    // Utiliser AppLocalizations.of(context) pour forcer le rafraîchissement
    final localizations = AppLocalizations.of(context)!;
    
    return Text(
      widget.textBuilder(localizations),
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}



