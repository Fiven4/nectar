import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/role_utils.dart';
import 'admin_home_screen.dart';
import 'web_role_blocked_screen.dart';

/// Web home of a signed-in session: only admins and managers get the panel.
class WebRoleGate extends StatefulWidget {
  const WebRoleGate({super.key, required this.user});

  final User user;

  @override
  State<WebRoleGate> createState() => _WebRoleGateState();
}

class _WebRoleGateState extends State<WebRoleGate> {
  late final Future<String> _roleFuture = _resolveRole();

  Future<String> _resolveRole() async {
    final databaseService = DatabaseService();
    await databaseService.ensureUserProfileFromAuth(widget.user, defaultRole: AppRoles.buyer);
    final userProfile = await databaseService.getUserProfile(widget.user.uid);
    return userProfile?['role']?.toString() ?? AppRoles.guest;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _roleFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return WebRoleBlockedScreen(roleName: roleLabel(AppRoles.guest));
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppPalette.primary)),
          );
        }

        final roleCode = snapshot.data!;
        if (canAccessAdminPanel(roleCode)) {
          return const AdminHomeScreen();
        }

        return WebRoleBlockedScreen(roleName: roleLabel(roleCode));
      },
    );
  }
}
