import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_checkbox.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_toast.dart';
import '../../shared/widgets/hover_text.dart';
import '../../shared/widgets/info_banner.dart';
import '../../shared/widgets/password_field.dart';
import '../../shared/widgets/pill_tabs.dart';
import '../../shared/widgets/surface_card.dart';
import 'widgets/auth_layout.dart';

/// Frame Figma "Log in" dan "Sign up" (tab). Termasuk varian error password.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _tab = 0;

  // Log in
  final _loginId = TextEditingController();
  final _loginPw = TextEditingController();
  bool _remember = true;
  String? _loginIdError;
  String? _loginPwError;

  // Sign up
  final _suUser = TextEditingController();
  final _suEmail = TextEditingController();
  final _suPw = TextEditingController();
  final _suConfirm = TextEditingController();
  bool _agree = false;
  String? _userError;
  String? _emailError;
  String? _pwError;
  String? _confirmError;

  @override
  void dispose() {
    for (final c in [_loginId, _loginPw, _suUser, _suEmail, _suPw, _suConfirm]) {
      c.dispose();
    }
    super.dispose();
  }

  // ------------------------------------------------------------------ actions
  Future<void> _openTerms() async {
    final accepted = await context.push<bool>(AppRoutes.terms);
    if (!mounted || accepted == null) return;
    if (_tab == 1) setState(() => _agree = accepted);
  }

  Future<void> _openForgot() async {
    final sent = await context.push<bool>(AppRoutes.forgotPassword);
    if (!mounted || sent != true) return;
    AppToast.show(context, title: 'Reset link sent.', message: 'Reset your password, then log in again.');
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loginIdError = _loginId.text.trim().isEmpty ? 'Required' : null;
      _loginPwError = _loginPw.text.isEmpty ? 'Required' : null;
    });
    if (_loginIdError != null || _loginPwError != null) return;
    final err = await context.read<AuthController>().login(_loginId.text.trim(), _loginPw.text, remember: _remember);
    if (!mounted) return;
    if (err != null) setState(() => _loginPwError = err);
    // Berhasil: router (redirect) otomatis membuka Home.
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _userError = _suUser.text.trim().isEmpty ? 'Required' : null;
      _emailError = !Validators.isEmail(_suEmail.text) ? 'Enter a valid email' : null;
      _pwError = Validators.isStrongPassword(_suPw.text) ? null : '*doesn’t meet the requirement';
      _confirmError = (_suConfirm.text == _suPw.text && _suConfirm.text.isNotEmpty) ? null : '*Passwords do not match';
    });
    if ([_userError, _emailError, _pwError, _confirmError].any((e) => e != null)) return;
    if (!_agree) {
      AppToast.show(context,
          title: 'Terms required', message: 'Please agree to the Terms & Conditions to continue.', error: true);
      return;
    }
    final auth = context.read<AuthController>();
    final err = await auth.signUp(username: _suUser.text.trim(), email: _suEmail.text.trim(), password: _suPw.text);
    if (!mounted) return;
    if (err != null) {
      AppToast.show(context, title: 'Could not create account', message: err, error: true);
      return;
    }
    final email = _suEmail.text.trim();
    setState(() {
      _tab = 0;
      _loginId.text = email;
      _loginPw.clear();
      _suUser.clear();
      _suEmail.clear();
      _suPw.clear();
      _suConfirm.clear();
      _agree = false;
    });
    AppToast.show(context, title: 'Account created.', message: 'Check your email to verify it, then log in.');
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    final busy = context.select<AuthController, bool>((a) => a.busy);
    return AuthLayout(
      child: Column(
        children: [
          PillTabs(
            tabs: const [PillTab(Icons.login_rounded, 'Log in'), PillTab(Icons.person_add_alt_1_rounded, 'Sign up')],
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _tab == 0 ? _buildLogin(busy) : _buildSignUp(busy),
          ),
        ],
      ),
    );
  }

  Widget _buildLogin(bool busy) {
    final text = context.textTheme;
    return Column(
      key: const ValueKey('login'),
      children: [
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppTextField(
                label: 'Email address / Username',
                hint: 'buahahahah@gmail.com',
                prefixIcon: Icons.mail_outline_rounded,
                controller: _loginId,
                errorText: _loginIdError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
              ),
              const SizedBox(height: 16),
              PasswordField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _loginPw,
                errorText: _loginPwError,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppCheckbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v),
                    label: Text('Remember me', style: text.bodyMedium),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: _openForgot,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                      child: Text('Forgot password?',
                          style: text.labelMedium!.copyWith(color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(label: 'Log in', trailingIcon: Icons.arrow_forward_rounded, loading: busy, onPressed: _login),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InfoBanner(
          padding: const EdgeInsets.all(14),
          gap: 12,
          leading: _circleIcon(Icons.verified_outlined),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart shopping tips', style: text.labelMedium!.copyWith(color: AppColors.onSurface)),
              const SizedBox(height: 2),
              Text('Sign up for free to save shopping lists and check how fresh your fruit is.',
                  style: text.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('New here? ', style: text.bodyLarge),
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => setState(() => _tab = 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('Sign up now', style: text.labelLarge!.copyWith(color: AppColors.primary)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 300,
          child: HoverText(
            text: 'By logging in, you agree to Buahaya’s Terms of Service and Privacy Policy.',
            textAlign: TextAlign.center,
            style: text.labelSmall!.copyWith(color: AppColors.outline, fontWeight: FontWeight.w500, height: 1.5),
            onTap: _openTerms,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUp(bool busy) {
    final text = context.textTheme;
    final linkStyle = text.bodyMedium!.copyWith(fontWeight: FontWeight.w700, color: AppColors.onSurface);
    Widget link(String label) => HoverText(text: label, style: linkStyle, onTap: _openTerms);

    return Column(
      key: const ValueKey('signup'),
      children: [
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppTextField(
                label: 'Username',
                hint: 'Example: Roy_Kanji',
                prefixIcon: Icons.person_outline_rounded,
                controller: _suUser,
                requiredTag: true,
                errorText: _userError,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Email address',
                hint: 'buahahahah@gmail.com',
                prefixIcon: Icons.mail_outline_rounded,
                controller: _suEmail,
                requiredTag: true,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              PasswordField(
                label: 'Password',
                hint: 'At least 8 characters with a special character',
                controller: _suPw,
                errorText: _pwError,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              PasswordField(
                label: 'Confirm password',
                hint: 'Enter your password again',
                controller: _suConfirm,
                errorText: _confirmError,
                prefixIcon: Icons.verified_user_outlined,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signUp(),
              ),
              const SizedBox(height: 12),
              AppCheckbox(
                value: _agree,
                onChanged: (v) => setState(() => _agree = v),
                label: Text.rich(
                  TextSpan(style: text.bodyMedium, children: [
                    const TextSpan(text: 'I agree to Buahaya’s '),
                    WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: link('Terms & Conditions')),
                    const TextSpan(text: ' and '),
                    WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: link('Privacy Policy')),
                    const TextSpan(text: '.'),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                  label: 'Create account', icon: Icons.person_add_alt_1_rounded, loading: busy, onPressed: _signUp),
            ],
          ),
        ),
        const SizedBox(height: 14),
        InfoBanner(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          crossAxisAlignment: CrossAxisAlignment.center,
          leading: const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primary),
          child: Text('Your data is encrypted and kept private.\nNo spam ads.',
              style: text.bodyMedium!.copyWith(color: const Color(0xFF334C43))),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Have an account? ', style: text.bodyLarge),
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => setState(() => _tab = 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('Log in', style: text.labelLarge!.copyWith(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _circleIcon(IconData icon) => Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: AppColors.primary),
      );
}
