import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main_screen.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/role_utils.dart';
import '../courier/courier_home_screen.dart';
import '../../l10n/l10n.dart';

/// Home of a signed-in session: resolves the user's role and shows the matching
/// app. Sign-out is handled by the app root, which replaces the whole session.
class AuthenticatedShell extends StatefulWidget {
  const AuthenticatedShell({super.key, required this.user});

  final User user;

  @override
  State<AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<AuthenticatedShell> {
  late Future<String> _roleFuture = _resolveRole();

  Future<String> _resolveRole() async {
    final databaseService = DatabaseService();
    var userProfile = await databaseService.getUserProfile(widget.user.uid);

    if (userProfile?['isDeleted'] == true) {
      await AuthService().logout();
      return AppRoles.guest;
    }

    if (userProfile == null) {
      await databaseService.ensureUserProfileFromAuth(widget.user, defaultRole: AppRoles.buyer);
      userProfile = await databaseService.getUserProfile(widget.user.uid);
    }

    return userProfile?['role']?.toString() ?? AppRoles.buyer;
  }

  void _retry() {
    setState(() => _roleFuture = _resolveRole());
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
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ProfileLoadError(onRetry: _retry);
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppPalette.primary)),
          );
        }

        return _homeForRole(snapshot.data!);
      },
    );
  }
}

class _ProfileLoadError extends StatelessWidget {
  const _ProfileLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: AppPalette.textSecondary),
              const SizedBox(height: 16),
              Text(
                context.l10n.profileLoadFailed,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppPalette.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary, foregroundColor: Colors.white),
                onPressed: onRetry,
                child: Text(context.l10n.retry),
              ),
              TextButton(
                onPressed: () => AuthService().logout(),
                child: Text(context.l10n.logoutFromAccount),
              ),
            ],
          ),
        ),
      ),
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
                    context.l10n.roleBlockedTitle(roleName),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.roleBlockedBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppPalette.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary, foregroundColor: Colors.white),
                      onPressed: () => AuthService().logout(),
                      child: Text(context.l10n.logoutFromAccount),
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