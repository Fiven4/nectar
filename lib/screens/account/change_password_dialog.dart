import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/validators.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/l10n.dart';

Future<void> showChangePasswordDialog(BuildContext context) async {
  final changed = await showDialog<bool>(
    context: context,
    builder: (_) => const _ChangePasswordDialog(),
  );

  if (changed == true && context.mounted) {
    showAppSnackBar(context, context.l10n.passwordChanged);
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      await _authService.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = _authService.getErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.changePasswordTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentController,
                obscureText: true,
                enabled: !_isSaving,
                validator: (value) => (value == null || value.isEmpty) ? context.l10n.currentPasswordRequired : null,
                decoration: InputDecoration(labelText: context.l10n.currentPasswordLabel),
              ),
              TextFormField(
                controller: _newController,
                obscureText: true,
                enabled: !_isSaving,
                validator: (value) {
                  final error = Validators.validatePassword(value);
                  if (error != null) return error;
                  if (value == _currentController.text) return context.l10n.newPasswordSame;
                  return null;
                },
                decoration: InputDecoration(labelText: context.l10n.newPasswordLabel),
              ),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                enabled: !_isSaving,
                validator: (value) => Validators.validatePasswordConfirmation(value, _newController.text),
                decoration: InputDecoration(labelText: context.l10n.newPasswordRepeatLabel),
              ),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_errorText!, style: const TextStyle(color: AppPalette.danger)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(context.l10n.save, style: TextStyle(color: AppPalette.primary)),
        ),
      ],
    );
  }
}
