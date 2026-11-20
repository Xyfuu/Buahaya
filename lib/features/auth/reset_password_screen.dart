import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/config/app_config.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_toast.dart';
import '../../shared/widgets/password_field.dart';
import '../../shared/widgets/surface_card.dart';
import 'widgets/auth_layout.dart';

/// Frame Figma "Redirect pass page" (dibuka dari tautan email reset).
/// Deep link: /reset-password?token=XXXX
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});

  final String token;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _pw = TextEditingController();
  final _confirm = TextEditingController();
  String? _pwError;
  String? _confirmError;

  @override
  void dispose() {
    _pw.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _pwError = Validators.isStrongPassword(_pw.text) ? null : '*doesn’t meet the requirement';
      _confirmError = _pw.text == _confirm.text && _confirm.text.isNotEmpty ? null : '*Passwords do not match';
    });
    if (_pwError != null || _confirmError != null) return;
    final err = await context.read<AuthController>().resetPassword(widget.token, _pw.text);
    if (!mounted) return;
    if (err != null) {
      AppToast.show(context, title: 'Could not change password', message: err, error: true);
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<AuthController, bool>((a) => a.busy);
    return AuthLayout(
      footer: Text('Buahaya ${AppConfig.version}',
          style: context.textTheme.labelSmall!.copyWith(color: AppColors.onSurfaceVariant)),
      child: SurfaceCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            PasswordField(
              label: 'New password',
              hint: 'Enter your password',
              controller: _pw,
              errorText: _pwError,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            PasswordField(
              label: 'Confirm password',
              hint: 'Enter your password again',
              controller: _confirm,
              errorText: _confirmError,
              prefixIcon: Icons.verified_user_outlined,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            AppButton(
                label: 'Change Password', trailingIcon: Icons.arrow_forward_rounded, loading: busy, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
