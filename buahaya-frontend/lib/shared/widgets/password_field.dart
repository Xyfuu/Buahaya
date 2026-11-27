import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_text_field.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.readOnly = false,
    this.labelStyle,
    this.prefixIcon = Icons.lock_outline_rounded,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? errorText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final TextStyle? labelStyle;
  final IconData prefixIcon;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      errorText: widget.errorText,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      labelStyle: widget.labelStyle,
      prefixIcon: widget.prefixIcon,
      autofillHints: widget.autofillHints,
      obscureText: !_visible,
      suffix: InkResponse(
        radius: 18,
        onTap: () => setState(() => _visible = !_visible),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            _visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: AppColors.outline,
          ),
        ),
      ),
    );
  }
}
