import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'auth_repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.repository, super.key});

  final AuthRepository repository;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  bool otpSent = false;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    if (!otpSent && !email.contains('@')) {
      setState(() => error = 'Enter a valid email address.');
      return;
    }
    if (otpSent && otpController.text.trim().length < 6) {
      setState(() => error = 'Enter the 6-digit code from your email.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });
    try {
      if (otpSent) {
        await widget.repository.verifyOtp(email, otpController.text.trim());
      } else {
        await widget.repository.sendOtp(email);
        if (mounted) setState(() => otpSent = true);
      }
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Text(otpSent ? 'Check your email' : 'Tailor sign in',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(otpSent ? 'Enter the one-time code we sent to your email.' : 'Sign in to manage your design catalog.'),
                  const SizedBox(height: 28),
                  TextField(
                    controller: emailController,
                    enabled: !otpSent && !loading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email address'),
                  ),
                  if (otpSent) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: otpController,
                      enabled: !loading,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(labelText: 'One-time code'),
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: loading ? null : submit,
                    child: Text(loading ? 'Working...' : otpSent ? 'Verify code' : 'Send code'),
                  ),
                  if (otpSent)
                    TextButton(onPressed: loading ? null : () => setState(() => otpSent = false), child: const Text('Use a different email')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}