import 'dart:async';

import 'package:flutter/material.dart';

import 'auth_repository.dart';
import 'auth_screen.dart';

class ProfileGate extends StatefulWidget {
  const ProfileGate({required this.repository, super.key});

  final AuthRepository repository;

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  StreamSubscription? subscription;
  TailorProfile? profile;
  String? error;

  @override
  void initState() {
    super.initState();
    subscription = widget.repository.authStateChanges.listen((_) => loadProfile());
    loadProfile();
  }

  Future<void> loadProfile() async {
    final session = widget.repository.currentSession;
    if (session == null) return;
    try {
      final loaded = await widget.repository.getProfile(session.user.id);
      if (mounted) setState(() => profile = loaded);
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.repository.currentSession;
    if (session == null) return AuthScreen(repository: widget.repository);
    if (profile == null) {
      return Scaffold(body: Center(child: error == null ? const CircularProgressIndicator() : Text(error!)));
    }
    if (profile!.status == 'pending') return const _StatusScreen(title: 'Waiting for approval', message: 'Your tailor account is under review.');
    if (profile!.status == 'rejected') return const _StatusScreen(title: 'Account not approved', message: 'Please contact the administrator for more information.');
    return _StatusScreen(title: 'Welcome back', message: profile!.shopName);
  }
}

class _StatusScreen extends StatelessWidget {
  const _StatusScreen({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.storefront_outlined, size: 48),
        const SizedBox(height: 20),
        Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
      ]))),
    );
  }
}