import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/database_service.dart';
import '../utils/app_palette.dart';
import '../l10n/l10n.dart';

/// Shows a single-field dialog. The dialog owns its controller, so nothing is
/// disposed while the closing animation is still running. [onSubmit] may throw
/// a [DatabaseOperationException]; its message is shown inside the dialog.
Future<void> showInputDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required Future<void> Function(String value) onSubmit,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  int? maxLength,
  int maxLines = 1,
  List<TextInputFormatter>? inputFormatters,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _InputDialog(
      title: title,
      hint: hint,
      onSubmit: onSubmit,
      validator: validator,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
    ),
  );
}

class _InputDialog extends StatefulWidget {
  const _InputDialog({
    required this.title,
    required this.hint,
    required this.onSubmit,
    this.validator,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
  });

  final String title;
  final String hint;
  final Future<void> Function(String value) onSubmit;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      await widget.onSubmit(_controller.text);
      if (mounted) Navigator.pop(context);
    } on DatabaseOperationException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = context.l10n.saveFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          enabled: !_isSaving,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          decoration: InputDecoration(hintText: widget.hint, errorText: _errorText),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(context.l10n.cancel, style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(context.l10n.save, style: TextStyle(color: AppPalette.primary)),
        ),
      ],
    );
  }
}
