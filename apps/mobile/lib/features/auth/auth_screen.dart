import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/locale/language_toggle.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import 'auth_repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.repository,
    this.localeProvider,
    super.key,
  });

  final AuthRepository repository;
  final LocaleProvider? localeProvider;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!email.contains('@')) {
      setState(() => error = 'Enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      setState(() => error = 'Enter your password.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });
    try {
      await widget.repository.signIn(email, password);
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().toLowerCase();
        final message = errStr.contains('invalid login credentials') ||
                errStr.contains('invalid_grant') ||
                errStr.contains('invalid_credentials')
            ? 'Incorrect email or password. Please try again.'
            : e.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException: ', '');
        setState(() => error = message);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: widget.localeProvider != null
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: LanguageToggle(provider: widget.localeProvider!),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.content_cut_rounded, size: 48, color: AppColors.brand),
                  const SizedBox(height: 24),
                  Text(l10n.signInTitle, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(l10n.signInSubtitle),
                  const SizedBox(height: 28),
                  TextField(
                    key: const Key('email_field'),
                    controller: emailController,
                    enabled: !loading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.email),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('password_field'),
                    controller: passwordController,
                    enabled: !loading,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submit(),
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('signin_button'),
                    onPressed: loading ? null : submit,
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.signIn),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Contact your administrator to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
