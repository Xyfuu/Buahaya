import 'package:go_router/go_router.dart';

import '../../app/shell_scaffold.dart';
import '../../controllers/auth_controller.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/auth/terms_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/lists/add_to_list_screen.dart';
import '../../features/lists/create_list_screen.dart';
import '../../features/lists/lists_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/help_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../theme/app_colors.dart';
import 'app_routes.dart';

const _publicPaths = {
  AppRoutes.login,
  AppRoutes.forgotPassword,
  AppRoutes.terms,
  AppRoutes.resetPassword,
};

GoRouter createRouter(AuthController auth) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      switch (auth.status) {
        case AuthStatus.unknown:
          return loc == AppRoutes.splash ? null : AppRoutes.splash;
        case AuthStatus.unauthenticated:
          return _publicPaths.contains(loc) ? null : AppRoutes.login;
        case AuthStatus.authenticated:
          return (loc == AppRoutes.splash || loc == AppRoutes.login) ? AppRoutes.home : null;
      }
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const AuthScreen(),
        routes: [
                    GoRoute(
            path: 'forgot',
            pageBuilder: (context, state) => CustomTransitionPage<bool>(
              key: state.pageKey,
              opaque: false,
              barrierDismissible: true,
              barrierColor: AppColors.scrim,
              barrierLabel: 'Close',
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: const Duration(milliseconds: 220),
              child: const ForgotPasswordScreen(),
              transitionsBuilder: (context, animation, secondary, child) => child,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (_, state) => TermsScreen(readOnly: state.uri.queryParameters['view'] == '1'),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, state) => ResetPasswordScreen(token: state.uri.queryParameters['token'] ?? ''),
      ),

            StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.lists,
              builder: (_, state) => ListsScreen(initialTab: state.uri.queryParameters['tab']),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.explore, builder: (_, __) => const ExploreScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),

            GoRoute(path: AppRoutes.scan, builder: (_, __) => const ScanScreen()),
      GoRoute(path: AppRoutes.createList, builder: (_, __) => const CreateListScreen()),
      GoRoute(path: AppRoutes.addToList, builder: (_, __) => const AddToListScreen()),
      GoRoute(path: AppRoutes.editProfile, builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: AppRoutes.help, builder: (_, __) => const HelpScreen()),
    ],
  );
}
