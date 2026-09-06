import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.registerBuyer(
        login: _loginController.text,
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context, rootNavigator: true);
      navigator.popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Регистрация прошла успешно. Добро пожаловать!'),
          backgroundColor: AppPalette.primary,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authService.getErrorMessage(error)),
          backgroundColor: AppPalette.danger,
        ),
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                      const Text(
                        'Новый аккаунт покупателя',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.textPrimary,
                          fontFamily: 'Unbounded',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'После регистрации вам автоматически будет назначена роль "Покупатель".',
                        style: TextStyle(color: AppPalette.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Логин'),
                      TextFormField(
                        controller: _loginController,
                        validator: Validators.validateLogin,
                        decoration: _inputDecoration(
                          hintText: 'Например, ivan_venikov',
                          icon: Icons.alternate_email,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Имя'),
                      TextFormField(
                        controller: _nameController,
                        validator: Validators.validateName,
                        decoration: _inputDecoration(
                          hintText: 'Ваше имя',
                          icon: Icons.badge_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Телефон'),
                      TextFormField(
                        controller: _phoneController,
                        validator: Validators.validatePhone,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          hintText: '+7 900 123-45-67',
                          icon: Icons.phone_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Email'),
                      TextFormField(
                        controller: _emailController,
                        validator: Validators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          hintText: 'example@mail.com',
                          icon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Пароль'),
                      TextFormField(
                        controller: _passwordController,
                        validator: Validators.validatePassword,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          hintText: 'Минимум 5 символов и одна цифра',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Подтверждение пароля'),
                      TextFormField(
                        controller: _confirmPasswordController,
                        validator: (value) => Validators.validatePasswordConfirmation(
                          value,
                          _passwordController.text,
                        ),
                        obscureText: _obscureConfirmPassword,
                        decoration: _inputDecoration(
                          hintText: 'Повторите пароль',
                          icon: Icons.lock_reset_outlined,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                            ),
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: _isLoading
                            ? const Center(
                          child: CircularProgressIndicator(color: AppPalette.primary),
                        )
                            : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _register,
                          child: const Text('Зарегистрироваться'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Уже есть аккаунт? Войти'),
                        ),
                      ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimary,
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

