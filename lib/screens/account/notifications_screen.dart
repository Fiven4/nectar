import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/parsers.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/l10n.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final databaseService = DatabaseService();

    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text(context.l10n.notificationsSignIn)),
      );
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: databaseService.watchUserProfile(currentUser.uid),
      builder: (context, profileSnapshot) {
        final notificationSettings =
            profileSnapshot.data?['notificationSettings'] as Map<String, dynamic>? ??
                {
                  'push': true,
                  'sms': false,
                  'email': true,
                };

        return Scaffold(
          backgroundColor: AppPalette.background,
          appBar: AppBar(
            title: Text(context.l10n.menuNotifications),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    await databaseService.clearNotifications(currentUser.uid);
                    if (context.mounted) showAppSnackBar(context, context.l10n.notificationsCleared);
                  } catch (_) {
                    if (context.mounted) {
                      showAppSnackBar(context, context.l10n.notificationsClearFailed, isError: true);
                    }
                  }
                },
                child: Text(context.l10n.clearAll),
              ),
            ],
          ),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: databaseService.watchNotifications(currentUser.uid),
            builder: (context, notificationsSnapshot) {
              final notifications = notificationsSnapshot.data ?? [];
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SwitchListTile(
                    activeThumbColor: AppPalette.primary,
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.notifPushTitle),
                    subtitle: Text(context.l10n.notifPushSubtitle),
                    value: notificationSettings['push'] == true,
                    onChanged: (value) {
                      databaseService.saveNotificationSettings(
                        userId: currentUser.uid,
                        pushEnabled: value,
                        smsEnabled: notificationSettings['sms'] == true,
                        emailEnabled: notificationSettings['email'] == true,
                      );
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    activeThumbColor: AppPalette.primary,
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.notifSmsTitle),
                    subtitle: Text(context.l10n.notifSmsSubtitle),
                    value: notificationSettings['sms'] == true,
                    onChanged: (value) {
                      databaseService.saveNotificationSettings(
                        userId: currentUser.uid,
                        pushEnabled: notificationSettings['push'] == true,
                        smsEnabled: value,
                        emailEnabled: notificationSettings['email'] == true,
                      );
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    activeThumbColor: AppPalette.primary,
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.notifEmailTitle),
                    subtitle: Text(context.l10n.notifEmailSubtitle),
                    value: notificationSettings['email'] == true,
                    onChanged: (value) {
                      databaseService.saveNotificationSettings(
                        userId: currentUser.uid,
                        pushEnabled: notificationSettings['push'] == true,
                        smsEnabled: notificationSettings['sms'] == true,
                        emailEnabled: value,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.notifHistoryTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textPrimary,
                      fontFamily: 'Unbounded',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (notifications.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        context.l10n.notifEmpty,
                        style: TextStyle(color: AppPalette.textSecondary),
                      ),
                    )
                  else
                    ...notifications.map((notification) {
                      final notificationDate = toDateTimeValue(notification['createdAt']);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppPalette.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pickLocalized(
                                english: context.isEnglish,
                                russian: notification['text']?.toString() ?? context.l10n.notifDefaultText,
                                englishValue: notification['textEn']?.toString(),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppPalette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatDateTime(notificationDate),
                              style: const TextStyle(color: AppPalette.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        );
      },
    );
  }

}
