import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.requiredTag = false,
    this.helperText,
    this.readOnly = false,
    this.labelStyle,
    this.dense = false,
    this.focusNode,
    this.maxLength,
  });

  final String label;
  final String hint;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool requiredTag;
  final String? helperText;
  final bool readOnly;
  final TextStyle? labelStyle;
  final bool dense;
  final FocusNode? focusNode;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final lStyle = labelStyle ??
        (dense
            ? text.labelSmall!.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)
            : text.labelLarge!.copyWith(color: AppColors.onSurface, letterSpacing: 0));
    final inputStyle = (dense ? text.bodyMedium! : text.bodyLarge!).copyWith(color: AppColors.onSurface);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label, style: lStyle),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _trailingTag(text, hasError),
              ),
            ),
          ],
        ),
        SizedBox(height: dense ? 4 : 6),
        Stack(
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              obscuringCharacter: '*',
              readOnly: readOnly,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              autofillHints: autofillHints,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              maxLength: maxLength,
              style: inputStyle,
              decoration: InputDecoration(
                hintText: hint,
                counterText: '',
                hintStyle: inputStyle.copyWith(color: AppColors.outline, fontSize: dense ? 12 : 14),
                contentPadding: EdgeInsets.fromLTRB(
                  prefixIcon != null ? 44 : 16,
                  dense ? 11 : 13,
                  suffix != null ? 48 : 16,
                  dense ? 11 : 13,
                ),
                enabledBorder: hasError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.error, width: 1))
                    : null,
              ),
            ),
            if (prefixIcon != null)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Center(widthFactor: 1, child: Icon(prefixIcon, size: 18, color: AppColors.outline)),
                ),
              ),
            if (suffix != null)
              Positioned(right: 8, top: 0, bottom: 0, child: Center(widthFactor: 1, child: suffix!)),
          ],
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(helperText!, style: text.bodyMedium!.copyWith(fontSize: 11)),
          ),
        ],
      ],
    );
  }

    Widget _trailingTag(TextTheme text, bool hasError) {
    if (hasError) {
      return Text(
        errorText!,
        textAlign: TextAlign.right,
        style: text.labelSmall!.copyWith(color: AppColors.error, fontWeight: FontWeight.w500),
      );
    }
    if (requiredTag) {
      return Text(
        'Required',
        style: text.labelSmall!.copyWith(color: AppColors.secondaryDark),
      );
    }
    return const SizedBox.shrink();
  }
}
