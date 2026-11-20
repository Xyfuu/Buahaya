import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controllers/profile_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_popups.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_toast.dart';
import '../../shared/widgets/password_field.dart';
import '../../shared/widgets/sub_screen_header.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/user_avatar.dart';
import '../auth/widgets/reset_link_sheet.dart';

/// Frame Figma "Edit profile" + pop-up "Change password".
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _email;
  final _pw = TextEditingController(text: 'supersecretpwd');
  String? _emailError;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileController>().profile;
    _name = TextEditingController(text: p?.fullName ?? '');
    _username = TextEditingController(text: p?.username ?? '');
    _email = TextEditingController(text: p?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  void _cancel() => context.canPop() ? context.pop() : context.go(AppRoutes.profile);

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = Validators.isEmail(_email.text) ? null : 'Enter a valid email';
      _usernameError = _username.text.trim().isEmpty ? 'Required' : null;
    });
    if (_emailError != null || _usernameError != null) return;
    final ctrl = context.read<ProfileController>();
    final err = await ctrl.update(
      fullName: _name.text.trim(),
      username: _username.text.trim().replaceFirst('@', ''),
      email: _email.text.trim(),
    );
    if (!mounted) return;
    if (err != null) {
      AppToast.show(context, title: 'Could not save', message: err, error: true);
      return;
    }
    AppToast.show(context, title: 'Profile updated', message: 'Your changes are saved.');
    _cancel();
  }

  Future<void> _pickAvatar() async {
    final picked = await showAppSheet<XFile?>(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Change profile photo', style: ctx.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          AppButton(
            label: 'Take photo',
            icon: Icons.photo_camera_outlined,
            onPressed: () async {
              final f = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
              if (ctx.mounted) Navigator.of(ctx).pop(f);
            },
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Choose from gallery',
            icon: Icons.photo_library_outlined,
            kind: AppButtonKind.tonal,
            onPressed: () async {
              final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
              if (ctx.mounted) Navigator.of(ctx).pop(f);
            },
          ),
        ],
      ),
    );
    if (picked != null && mounted) {
      await context.read<ProfileController>().setAvatar(picked.path);
    }
  }

  Future<void> _changePassword() async {
    final sent = await showPopup<bool>(
      context,
      builder: (ctx) => PopupCard(
        child: ResetLinkSheetContent(
          title: 'Change password',
          description: 'We’ll send you a link to change your password.',
          buttonLabel: 'Send link',
          initialEmail: _email.text,
          onClose: (ok) => Navigator.of(ctx).pop(ok),
        ),
      ),
    );
    if (sent == true && mounted) {
      AppToast.show(context, title: 'Reset link sent.', message: 'Check your inbox to change your password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final profile = context.watch<ProfileController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SubScreenHeader(title: 'Edit Profile', onBack: _cancel, leftAligned: true, circleBack: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        UserAvatar(profile: profile.profile, size: 104),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _pickAvatar,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.photo_camera_outlined, size: 16, color: AppColors.onPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SurfaceCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Full Name',
                          hint: 'Roy Kanji',
                          prefixIcon: Icons.person_outline_rounded,
                          controller: _name,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Username',
                          hint: '@username',
                          prefixIcon: Icons.alternate_email_rounded,
                          controller: _username,
                          errorText: _usernameError,
                          helperText: 'Unique username for collaborative shopping in Buahaya',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Email Address',
                          hint: 'name@email.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          controller: _email,
                          errorText: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppColors.noteBackground, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.noteText),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Note: Changing your email address requires re-verification via a confirmation link sent to your new email before updates take effect.',
                                  style: text.bodySmall!.copyWith(color: AppColors.noteText),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: Text('Password', style: text.labelMedium!.copyWith(color: AppColors.onSurface))),
                            InkWell(
                              onTap: _changePassword,
                              child: Text('Change Password',
                                  style: text.labelSmall!.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        PasswordField(
                          label: 'Current password',
                          hint: 'Enter your password',
                          controller: _pw,
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Save Changes',
                    icon: Icons.check_rounded,
                    loading: profile.saving,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 8),
                  AppButton(label: 'Cancel', kind: AppButtonKind.neutral, onPressed: _cancel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
