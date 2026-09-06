import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main_screen.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/role_utils.dart';
import '../courier/courier_home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF53B175))),
          );
        }

        final firebaseUser = snapshot.data;
        if (firebaseUser == null) {
          return const LoginScreen();
        }

        // Own Navigator so logout disposes every pushed route / modal with
        // the shell. Replacing only the child of MaterialApp.home while root
        // overlays stay alive is what triggers InheritedElement
        // '_dependents.isEmpty'.
        return _AuthenticatedShell(
          key: ValueKey<String>(firebaseUser.uid),
          user: firebaseUser,
        );
      },
    );
  }
}

class _AuthenticatedShell extends StatefulWidget {
  const _AuthenticatedShell({super.key, required this.user});

  final User user;

  @override
  State<_AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<_AuthenticatedShell> {
  late final Future<String> _roleFuture = _resolveRole(widget.user);

  Future<String> _resolveRole(User currentUser) async {
    final databaseService = DatabaseService();
    await databaseService.ensureUserProfileFromAuth(currentUser, defaultRole: AppRoles.buyer);
    final userProfile = await databaseService.getUserProfile(currentUser.uid);

    final isDeleted = userProfile?['isDeleted'] == true;
    if (isDeleted) {
      await AuthService().logout();
      return AppRoles.guest;
    }

    return userProfile?['role']?.toString() ?? AppRoles.buyer;
  }

  Widget _homeForRole(String roleCode) {
    if (canAccessBuyerApp(roleCode)) {
      return const MainScreen();
    }
    if (canAccessCourierApp(roleCode)) {
      return const CourierHomeScreen();
    }
    return MobileRoleBlockedScreen(roleName: roleLabel(roleCode));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _roleFuture,
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppPalette.primary)),
          );
        }

        final roleCode = roleSnapshot.data ?? AppRoles.buyer;

        return Navigator(
          key: ValueKey<String>('auth-nav-${widget.user.uid}-$roleCode'),
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => _homeForRole(roleCode),
            );
          },
        );
      },
    );
  }
}

class MobileRoleBlockedScreen extends StatelessWidget {
  const MobileRoleBlockedScreen({super.key, required this.roleName});

  final String roleName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppPalette.warning, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'Роль "$roleName" не может работать в мобильном приложении.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Пожалуйста, используйте веб-версию (сайт) для администрирования.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppPalette.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary, foregroundColor: Colors.white),
                      onPressed: () async {
                        await AuthService().logout();
                      },
                      child: const Text('Выйти из аккаунта'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
