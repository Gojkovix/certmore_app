import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Vnosno polje z oznako nad poljem. Slog prihaja iz teme
/// (InputDecorationTheme), zato so vsa polja v aplikaciji enaka.
///
/// Z [obscureToggle] postane polje za geslo z gumbom za prikaz.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.obscureToggle = false,
    this.enabled = true,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final bool obscureToggle;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bralnik zaslona oznako dobi prek Semantics na polju spodaj.
        ExcludeSemantics(child: Text(widget.label, style: AppTypography.label)),
        const SizedBox(height: AppSpacing.xs),
        Semantics(
          label: widget.label,
          child: TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            textCapitalization: widget.textCapitalization,
            obscureText: _obscured,
            enableSuggestions: !widget.obscureToggle,
            autocorrect: false,
            enabled: widget.enabled,
            onFieldSubmitted: widget.onSubmitted,
            style: AppTypography.body,
            decoration: InputDecoration(
              suffixIcon: widget.obscureToggle
                  ? IconButton(
                      onPressed: () => setState(() => _obscured = !_obscured),
                      tooltip: _obscured ? 'Pokaži geslo' : 'Skrij geslo',
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
