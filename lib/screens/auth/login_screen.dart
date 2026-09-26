import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/auth_target.dart';
import '../../utils/validators.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/language_switcher.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../l10n/l10n.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.authFlowTarget = AuthFlowTarget.mobile,
  });

  final AuthFlowTarget authFlowTarget;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscureText = true;

  bool get _isAdminFlow => widget.authFlowTarget == AuthFlowTarget.adminPanel;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Successful sign-in needs no navigation: the app root replaces this whole
  // session once the auth state changes, disposing this screen with it.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.login(
        _identifierController.text,
        _passwordController.text,
      );
    } catch (error) {
      _handleAuthError(error);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null && mounted) {
        setState(() => _isLoading = false);
      }
    } catch (error) {
      _handleAuthError(error);
    }
  }

  void _handleAuthError(Object error) {
    if (!mounted) return;
    _showMessage(_authService.getErrorMessage(error), isError: true);
    setState(() => _isLoading = false);
  }

  void _showMessage(String message, {bool isError = false}) {
    showAppSnackBar(context, message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 720;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: _isAdminFlow
          ? AppBar(
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        title: Text(context.l10n.loginPanelAppBar),
      )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _isAdminFlow ? 520 : 480),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: LanguageSwitcher(),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppPalette.lightPrimary,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.local_grocery_store,
                            color: AppPalette.primary,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _isAdminFlow ? context.l10n.loginPanelTitle : context.l10n.loginTitle,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.textPrimary,
                          fontFamily: 'Unbounded',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isAdminFlow
                            ? context.l10n.loginPanelSubtitle
                            : context.l10n.loginSubtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppPalette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(context.l10n.loginIdentifierLabel),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _identifierController,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validateLoginIdentifier,
                        decoration: _inputDecoration(
                          hintText: context.l10n.loginIdentifierHint,
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(context.l10n.labelPassword),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        validator: Validators.validatePasswordForLogin,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: _inputDecoration(
                          hintText: context.l10n.passwordHint,
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text(context.l10n.forgotPasswordLink),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: _isLoading
                            ? const Center(
                          child: CircularProgressIndicator(
                            color: AppPalette.primary,
                          ),
                        )
                            : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _submit,
                          child: Text(_isAdminFlow ? context.l10n.signInToPanel : context.l10n.signIn),
                        ),
                      ),
                      if (!_isAdminFlow) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _loginWithGoogle,
                            icon: const Icon(Icons.g_mobiledata, size: 34, color: Colors.red),
                            label: Text(context.l10n.continueWithGoogle),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(context.l10n.noAccount),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              },
                              child: Text(context.l10n.registerAction),
                            ),
                          ],
                        ),
                      ],
                      if (_isAdminFlow && !isCompact && kIsWeb) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.panelInfoNote,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppPalette.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppPalette.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppPalette.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppPalette.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppPalette.danger),
      ),
    );
  }
}