import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/role_utils.dart';
import 'about_screen.dart';
import 'delivery_address_screen.dart';
import 'help_screen.dart';
import 'my_details_screen.dart';
import 'notifications_screen.dart';
import 'orders_screen.dart';
import 'payment_methods_screen.dart';
import 'promo_code_screen.dart';

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

    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) {
      return;
    }

    final fileName = pickedFile.name.toLowerCase();
    final isSupportedFormat = fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png');
    if (!isSupportedFormat) {
      _showMessage('Разрешены только изображения JPEG и PNG.', isError: true);
      return;
    }

    final Uint8List fileBytes = await pickedFile.readAsBytes();
    if (fileBytes.length > 5 * 1024 * 1024) {
      _showMessage('Размер изображения не должен превышать 5 МБ.', isError: true);
      return;
    }

    setState(() => _isUploadingAvatar = true);
    try {
      final storageReference = FirebaseStorage.instance.ref().child(
        'user_avatars/${currentUser.uid}.jpg',
      );

      await storageReference.putData(
        fileBytes,
        SettableMetadata(
          contentType: fileName.endsWith('.png') ? 'image/png' : 'image/jpeg',
        ),
      );

      final downloadUrl = await storageReference.getDownloadURL();
      final userProfile = await _databaseService.getUserProfile(currentUser.uid);
      await currentUser.updatePhotoURL(downloadUrl);
      await _databaseService.updateUserProfile(
        userId: currentUser.uid,
        displayName: userProfile?['displayName']?.toString() ?? currentUser.displayName ?? 'Пользователь',
        phoneNumber: userProfile?['phoneNumber']?.toString() ?? '',
        photoUrl: downloadUrl,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Аватар успешно обновлен.');
    } catch (error) {
      _showMessage('Не удалось загрузить изображение.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _logout() async {
    // Clear root overlays first (while this subtree is still mounted), then
    // let AuthWrapper swap to LoginScreen. Logout-before-pop leaves routes
    // depending on a deactivating InheritedElement → '_dependents.isEmpty'.
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    rootNavigator.popUntil((route) => route.isFirst);
    await _authService.logout();
  }

  Future<void> _deleteCurrentAccount() async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Удалить аккаунт?'),
              content: const Text(
                'Аккаунт будет удален, если у вас нет незавершенных заказов. '
                'Это действие нельзя отменить.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Удалить'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() => _isDeletingAccount = true);
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    try {
      await _databaseService.assertUserCanBeDeleted(currentUser.uid);
      rootNavigator.popUntil((route) => route.isFirst);
      await currentUser.delete();
      await _databaseService.deleteUser(currentUser.uid);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        _showMessage(
          'Для удаления аккаунта нужно войти в систему заново.',
          isError: true,
        );
      } else {
        _showMessage('Не удалось удалить аккаунт.', isError: true);
      }
    } on DatabaseOperationException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      _showMessage('Не удалось удалить аккаунт.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppPalette.danger : AppPalette.primary,
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Пользователь не авторизован.'),
        ),
      );
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _databaseService.watchUserProfile(currentUser.uid),
      builder: (context, snapshot) {
        final profileData = snapshot.data ?? <String, dynamic>{};
        final displayName = profileData['displayName']?.toString().isNotEmpty == true
            ? profileData['displayName'].toString()
            : (currentUser.displayName ?? 'Пользователь');
        final email = profileData['email']?.toString().isNotEmpty == true
            ? profileData['email'].toString()
            : (currentUser.email ?? 'Нет email');
        final roleCode = profileData['role']?.toString() ?? AppRoles.buyer;
        final avatarUrl = profileData['photoUrl']?.toString().isNotEmpty == true
            ? profileData['photoUrl'].toString()
            : currentUser.photoURL;

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
                          onTap: _isUploadingAvatar ? null : _pickAndUploadImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: AppPalette.lightPrimary,
                                  shape: BoxShape.circle,
                                  image: avatarUrl == null
                                      ? null
                                      : DecorationImage(
                                          image: NetworkImage(avatarUrl),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: avatarUrl == null && !_isUploadingAvatar
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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  _buildListTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Заказы',
                    onTap: () => _navigateTo(const OrdersScreen()),
                  ),
                  _buildListTile(
                    icon: Icons.badge_outlined,
                    title: 'Мои данные',
                    onTap: () => _navigateTo(const MyDetailsScreen()),
                  ),
                  _buildListTile(
                    icon: Icons.location_on_outlined,
                    title: 'Адрес доставки',
                    onTap: () => _navigateTo(const DeliveryAddressScreen()),
                  ),
                  _buildListTile(
                    icon: Icons.payment_outlined,
                    title: 'Способы оплаты',
                    onTap: () => _navigateTo(const PaymentMethodsScreen()),
                  ),
                  _buildListTile(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Промокоды',
                    onTap: () => _navigateTo(const PromoCodeScreen()),
                  ),
                  _buildListTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Уведомления',
                    onTap: () => _navigateTo(const NotificationsScreen()),
                  ),
                  _buildListTile(
                    icon: Icons.help_outline,
                    title: 'Помощь',
                    onTap: () => _navigateTo(const HelpScreen()),
                  ),
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: 'О приложении',
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
                            label: const Text('Выйти'),
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
                            onPressed: _isDeletingAccount ? null : _deleteCurrentAccount,
                            icon: _isDeletingAccount
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.delete_outline),
                            label: const Text('Удалить аккаунт'),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
