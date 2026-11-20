import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/info_banner.dart';

/// Isi sheet "Reset password" / "Change password" (kirim tautan ke email).
/// Layar dikunci (tidak scroll). [onClose] dipanggil dengan true bila tautan terkirim.
class ResetLinkSheetContent extends StatefulWidget {
  const ResetLinkSheetContent({
    super.key,
    required this.title,
    this.subtitle,
    required this.description,
    required this.buttonLabel,
    required this.onClose,
    this.initialEmail = '',
  });

  final String title;
  final String? subtitle;
  final String description;
  final String buttonLabel;
  final String initialEmail;
  final ValueChanged<bool> onClose;

  @override
  State<ResetLinkSheetContent> createState() => _ResetLinkSheetContentState();
}

class _ResetLinkSheetContentState extends State<ResetLinkSheetContent> {
  late final TextEditingController _email = TextEditingController(text: widget.initialEmail);
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    if (!Validators.isEmail(email)) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    setState(() => _error = null);
    final auth = context.read<AuthController>();
    final err = await auth.requestPasswordReset(email);
    if (!mounted) return;
    if (err != null) {
      AppToast.show(context, title: 'Could not send link', message: err, error: true);
      return;
    }
    widget.onClose(true);
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final busy = context.select<AuthController, bool>((a) => a.busy);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: const Icon(Icons.lock_reset_rounded, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: text.titleLarge),
                  if (widget.subtitle != null) Text(widget.subtitle!, style: text.bodyMedium),
                ],
              ),
            ),
            InkResponse(
              onTap: () => widget.onClose(false),
              radius: 20,
              child: const SizedBox(
                  width: 32, height: 32, child: Icon(Icons.close_rounded, size: 18, color: AppColors.onSurfaceVariant)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(widget.description, style: text.bodyMedium),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Your account email',
          hint: 'buahahahah@gmail.com',
          prefixIcon: Icons.mail_outline_rounded,
          controller: _email,
          errorText: _error,
          dense: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _send(),
        ),
        const SizedBox(height: 14),
        InfoBanner(
          padding: const EdgeInsets.all(12),
          leading: const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.schedule_rounded, size: 15, color: AppColors.primary),
          ),
          child: Text.rich(
            TextSpan(
              style: text.bodyMedium,
              children: [
                const TextSpan(text: 'For your safety, the reset link expires in '),
                TextSpan(
                    text: '15 minutes',
                    style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(label: widget.buttonLabel, trailingIcon: Icons.send_outlined, loading: busy, onPressed: _send),
        const SizedBox(height: 8),
        AppButton(
          label: 'Cancel and go back',
          kind: AppButtonKind.neutral,
          height: 40,
          textStyle: text.labelMedium,
          onPressed: busy ? null : () => widget.onClose(false),
        ),
      ],
    );
  }
}
