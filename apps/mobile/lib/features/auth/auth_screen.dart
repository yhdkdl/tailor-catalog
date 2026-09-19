import 'package:flutter/material.dart';

import '../../core/errors/error_utils.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/locale/language_toggle.dart';
import '../../core/locale/locale_provider.dart';
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
    } catch (e, stackTrace) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final friendlyMessage = ErrorUtils.getFriendlyErrorMessage(
          e,
          stackTrace: stackTrace,
          contextTag: 'AUTH_SIGN_IN',
          l10n: l10n,
        );
        setState(() => error = friendlyMessage);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF18181A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.localeProvider != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: LanguageToggle(provider: widget.localeProvider!),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Circular glowing badge with scissors icon
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF262015),
                        border: Border.all(
                          color: const Color(0x33F59E0B),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x38F59E0B),
                            blurRadius: 42,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.content_cut_rounded,
                          size: 38,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Title
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE5A01A),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // App Subtitle / Tagline
                  Text(
                    l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 38),

                  // Section Title: "Tailor sign in"
                  Text(
                    l10n.signInTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Email input field
                  TextField(
                    key: const Key('email_field'),
                    controller: emailController,
                    enabled: !loading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: l10n.email,
                      hintStyle: const TextStyle(color: Color(0xFF71717A), fontSize: 15),
                      prefixIcon: const Icon(
                        Icons.mail_outline_rounded,
                        color: Color(0xFF71717A),
                        size: 22,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF242427),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF333338), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF333338), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password input field
                  TextField(
                    key: const Key('password_field'),
                    controller: passwordController,
                    enabled: !loading,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submit(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: l10n.password,
                      hintStyle: const TextStyle(color: Color(0xFF71717A), fontSize: 15),
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFF71717A),
                        size: 22,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF71717A),
                          size: 22,
                        ),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF242427),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF333338), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF333338), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                      ),
                    ),
                  ),

                  // Graceful Error Banner
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1518),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x66E11D48)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              error!,
                              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Sign in Button
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      key: const Key('signin_button'),
                      onPressed: loading ? null : submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB87D0E),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0x80B87D0E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.signIn),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact admin to reset password
                  Text(
                    l10n.contactAdminReset,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF71717A),
                    ),
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
