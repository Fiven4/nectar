import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/role_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/language_switcher.dart';
import 'about_screen.dart';
import 'change_password_dialog.dart';
import 'delivery_address_screen.dart';
import 'help_screen.dart';
import 'my_details_screen.dart';
import 'notifications_screen.dart';
import 'orders_screen.dart';
import 'payment_methods_screen.dart';
import 'promo_code_screen.dart';
import '../../l10n/l10n.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isUploadingAvatar = false;
  bool _isDeletingAccount = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _pickAndUploadImage() async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return;
    }

    // Аватар хранится в Firestore, поэтому сжимаем его до маленького квадрата.
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 256,
      maxHeight: 256,
      imageQuality: 75,
    );

    if (pickedFile == null) {
      return;
    }

    final fileName = pickedFile.name.toLowerCase();
    final isSupportedFormat =
        fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png');
    if (!isSupportedFormat) {
      _showMessage(AppLocale.strings.avatarFormatError, isError: true);
      return;
    }

    final Uint8List fileBytes = await pickedFile.readAsBytes();
    if (!mounted) {
      return;
    }
    if (fileBytes.length > DatabaseService.maxAvatarBytes) {
      _showMessage(context.l10n.avatarTooBig, isError: true);
      return;
    }

    setState(() => _isUploadingAvatar = true);
    try {
      await _databaseService.saveUserAvatar(
        userId: currentUser.uid,
        imageBytes: fileBytes,
      );

      if (!mounted) {
        return;
      }

      _showMessage(context.l10n.avatarUpdated);
    } catch (error) {
      _showMessage(context.l10n.avatarUploadFailed, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  /// Аватар из профиля (base64), иначе фото Google-аккаунта.
  ImageProvider? _avatarImage(Map<String, dynamic> profileData, User currentUser) {
    final photoData = profileData['photoData']?.toString() ?? '';
    if (photoData.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(photoData));
      } on FormatException {
        // Поврежденные данные: показываем запасной вариант.
      }
    }
    final photoUrl = profileData['photoUrl']?.toString().isNotEmpty == true
        ? profileData['photoUrl'].toString()
        : currentUser.photoURL;
    return photoUrl == null ? null : NetworkImage(photoUrl);
  }

  Future<void> _logout() async {
    await _authService.logout();
  }

  Future<void> _deleteCurrentAccount() async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(context.l10n.deleteAccountTitle),
              content: Text(
                context.l10n.deleteAccountBody,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(context.l10n.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(context.l10n.delete),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || !mounted) {
      return;
    }

    setState(() => _isDeletingAccount = true);
    var profileMarkedDeleted = false;
    Map<String, dynamic>? releasedLogin;
    try {
      // Профиль помечаем удаленным и освобождаем логин, пока пользователь еще
      // авторизован, и возвращаем все обратно, если Firebase не даст удалить
      // учетную запись.
      await _databaseService.deleteUser(currentUser.uid);
      profileMarkedDeleted = true;
      releasedLogin = await _databaseService.releaseLoginIndex(currentUser.uid);
      await currentUser.delete();
    } on FirebaseAuthException catch (error) {
      await _restoreProfileIfNeeded(currentUser.uid, profileMarkedDeleted, releasedLogin);
      _showMessage(
        error.code == 'requires-recent-login'
            ? AppLocale.strings.deleteAccountRecentLogin
            : AppLocale.strings.deleteAccountFailed,
        isError: true,
      );
    } on DatabaseOperationException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      await _restoreProfileIfNeeded(currentUser.uid, profileMarkedDeleted, releasedLogin);
      _showMessage(AppLocale.strings.deleteAccountFailed, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
  }

  Future<void> _restoreProfileIfNeeded(
    String userId,
    bool profileMarkedDeleted,
    Map<String, dynamic>? releasedLogin,
  ) async {
    if (!profileMarkedDeleted) return;
    try {
      await _databaseService.restoreLoginIndex(releasedLogin);
      await _databaseService.restoreUser(userId);
    } catch (_) {
      // Профиль останется помеченным удаленным; при следующем входе пользователь будет разлогинен.
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    showAppSnackBar(context, message, isError: isError);
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text(context.l10n.authNotSignedIn)),
      );
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _databaseService.watchUserProfile(currentUser.uid),
      builder: (context, snapshot) {
        final profileData = snapshot.data ?? <String, dynamic>{};
        final displayName =
            profileData['displayName']?.toString().isNotEmpty == true
            ? profileData['displayName'].toString()
            : (currentUser.displayName ?? context.l10n.userDefaultName);
        final email = profileData['email']?.toString().isNotEmpty == true
            ? profileData['email'].toString()
            : (currentUser.email ?? context.l10n.noEmail);
        final roleCode = profileData['role']?.toString() ?? AppRoles.buyer;
        final avatarImage = _avatarImage(profileData, currentUser);

        return Scaffold(
          backgroundColor: AppPalette.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _isUploadingAvatar
                              ? null
                              : _pickAndUploadImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: AppPalette.lightPrimary,
                                  shape: BoxShape.circle,
                                  image: avatarImage == null
                                      ? null
                                      : DecorationImage(
                                          image: avatarImage,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: avatarImage == null && !_isUploadingAvatar
                                    ? const Icon(
                                        Icons.person,
                                        size: 36,
                                        color: AppPalette.primary,
                                      )
                                    : null,
                              ),
                              if (_isUploadingAvatar)
                                const Positioned.fill(
                                  child: CircularProgressIndicator(
                                    color: AppPalette.primary,
                                    strokeWidth: 3,
                                  ),
                                ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppPalette.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppPalette.textPrimary,
                                  fontFamily: 'Unbounded',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: AppPalette.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppPalette.lightPrimary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  roleLabel(roleCode),
                                  style: const TextStyle(
                                    color: AppPalette.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (canAccessBuyerApp(roleCode)) ...[
                    _buildListTile(
                      icon: Icons.shopping_bag_outlined,
                      title: context.l10n.menuOrders,
                      onTap: () => _navigateTo(const OrdersScreen()),
                    ),
                    _buildListTile(
                      icon: Icons.badge_outlined,
                      title: context.l10n.menuMyDetails,
                      onTap: () => _navigateTo(const MyDetailsScreen()),
                    ),
                    _buildListTile(
                      icon: Icons.location_on_outlined,
                      title: context.l10n.menuDeliveryAddress,
                      onTap: () => _navigateTo(const DeliveryAddressScreen()),
                    ),
                    _buildListTile(
                      icon: Icons.payment_outlined,
                      title: context.l10n.menuPaymentMethods,
                      onTap: () => _navigateTo(const PaymentMethodsScreen()),
                    ),
                    _buildListTile(
                      icon: Icons.card_giftcard_outlined,
                      title: context.l10n.menuPromoCodes,
                      onTap: () => _navigateTo(const PromoCodeScreen()),
                    ),
                  ],
                  if (_authService.canChangePassword)
                    _buildListTile(
                      icon: Icons.lock_outline,
                      title: context.l10n.menuChangePassword,
                      onTap: () => showChangePasswordDialog(context),
                    ),
                  Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: const Icon(Icons.language, color: AppPalette.textPrimary),
                        title: Text(
                          context.l10n.language,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                        trailing: const LanguageSwitcher(),
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                  _buildListTile(
                    icon: Icons.notifications_none_outlined,
                    title: context.l10n.menuNotifications,
                    onTap: () => _navigateTo(const NotificationsScreen()),
                  ),
                  _buildListTile(
                    icon: Icons.help_outline,
                    title: context.l10n.menuHelp,
                    onTap: () => _navigateTo(const HelpScreen()),
                  ),
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: context.l10n.menuAbout,
                    onTap: () => _navigateTo(const AboutScreen()),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: Text(context.l10n.logout),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppPalette.danger,
                              side: const BorderSide(color: AppPalette.danger),
                            ),
                            onPressed: _isDeletingAccount
                                ? null
                                : _deleteCurrentAccount,
                            icon: _isDeletingAccount
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.delete_outline),
                            label: Text(context.l10n.deleteAccount),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: Icon(icon, color: AppPalette.textPrimary),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppPalette.textPrimary,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
