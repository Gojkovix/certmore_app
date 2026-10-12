import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/auth_repository.dart';
import 'widgets/auth_form_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await AppScope.of(
        context,
      ).auth.signIn(email: _email.text, password: _password.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.failure.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Ponastavitev gesla potrebuje pravi Certmore API, zato to pošteno
  /// povemo, namesto da bi se pretvarjali, da je e-pošta poslana.
  void _forgotPassword() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
          content: Text(
            'Ponastavitev gesla bo na voljo, ko bo aplikacija povezana '
            's tvojim Certmore računom.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: AuthFormLayout(
          title: 'Dobrodošel nazaj.',
          subtitle: 'Nadaljuj tam, kjer si ostal.',
          error: _error,
          loading: _loading,
          primaryLabel: 'Prijava',
          onPrimary: _submit,
          showDemoNotice: AppScope.of(context).auth.isLocal,
          fields: [
            AppTextField(
              label: 'E-poštni naslov',
              controller: _email,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              enabled: !_loading,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Geslo',
                  controller: _password,
                  validator: Validators.password,
                  obscureToggle: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  enabled: !_loading,
                  onSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : _forgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      textStyle: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Pozabljeno geslo?'),
                  ),
                ),
              ],
            ),
          ],
          // Nov račun začne z onboardingom, da imamo odgovore za prilagoditev.
          secondary: TextButton(
            onPressed: _loading
                ? null
                : () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.onboarding,
                  ),
            child: const Text('Ustvari račun'),
          ),
        ),
      ),
    );
  }
}
