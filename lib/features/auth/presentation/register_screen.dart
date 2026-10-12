import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/auth_repository.dart';
import 'widgets/auth_form_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;

  /// Po prvem poskusu oddaje se polja preverjajo sproti, da napaka
  /// izgine takoj, ko je vnos popravljen.
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _error = null;
      _submitted = true;
    });
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await AppScope.of(context).auth.register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.failure.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: AutofillGroup(
        child: AuthFormLayout(
          title: 'Ustvari račun',
          subtitle: 'Še zadnji korak, preden začneš z vajo.',
          error: _error,
          loading: _loading,
          primaryLabel: 'Ustvari račun',
          onPrimary: _submit,
          showDemoNotice: AppScope.of(context).auth.isLocal,
          fields: [
            AppTextField(
              label: 'Ime',
              controller: _name,
              validator: Validators.name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              enabled: !_loading,
            ),
            AppTextField(
              label: 'E-poštni naslov',
              controller: _email,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              enabled: !_loading,
            ),
            AppTextField(
              label: 'Geslo',
              controller: _password,
              validator: Validators.newPassword,
              obscureToggle: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !_loading,
              onSubmitted: (_) => _submit(),
            ),
          ],
          secondary: TextButton(
            onPressed: _loading
                ? null
                : () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
            child: const Text('Že imaš račun? Prijava'),
          ),
        ),
      ),
    );
  }
}
