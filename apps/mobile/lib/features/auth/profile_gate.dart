import 'dart:async';

import 'package:flutter/material.dart';

import '../designs/dashboard_screen.dart';
import '../designs/design_repository.dart';
import 'auth_repository.dart';
import 'auth_screen.dart';

class ProfileGate extends StatefulWidget {
  const ProfileGate({
    required this.repository,
    this.designRepository,
    super.key,
  });

  final AuthRepository repository;
  final DesignRepository? designRepository;

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
    if (session == null) {
      if (mounted) {
        setState(() {
          profile = null;
          error = null;
        });
      }
      return;
    }

    try {
      final loaded = await widget.repository.getProfile(session.user.id);
      if (mounted) {
        setState(() {
          profile = loaded;
          error = null;
        });
      }
    } catch (exception) {
      if (mounted) {
        setState(() => error = exception.toString());
      }
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
    if (session == null) {
      return AuthScreen(repository: widget.repository);
    }
    if (profile == null) {
      return Scaffold(
        body: Center(
          child: error == null
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: loadProfile,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: widget.repository.signOut,
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }
    switch (profile!.status) {
      case 'pending':
        return _PendingApprovalScreen(
          shopName: profile!.shopName,
          onRefresh: loadProfile,
          onSignOut: widget.repository.signOut,
        );
      case 'rejected':
        return _RejectedScreen(onSignOut: widget.repository.signOut);
      case 'approved':
        final repo = widget.designRepository ??
            (widget.repository is SupabaseAuthRepository
                ? SupabaseDesignRepository(client: (widget.repository as SupabaseAuthRepository).client)
                : const UnconfiguredDesignRepository());
        return DashboardScreen(
          profile: profile!,
          designRepository: repo,
          onSignOut: widget.repository.signOut,
        );
      default:
        return Scaffold(body: Center(child: Text('Unknown account status: ${profile!.status}')));
    }
  }
}

class _PendingApprovalScreen extends StatefulWidget {
  const _PendingApprovalScreen({
    required this.shopName,
    required this.onRefresh,
    required this.onSignOut,
  });

  final String shopName;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onSignOut;

  @override
  State<_PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<_PendingApprovalScreen> {
  bool refreshing = false;

  Future<void> refresh() async {
    setState(() => refreshing = true);
    await widget.onRefresh();
    if (mounted) setState(() => refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.hourglass_top_rounded, size: 56),
              const SizedBox(height: 20),
              Text(widget.shopName, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text(
                'Your account is pending approval. Please wait for the administrator to review and approve your account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: refreshing ? null : refresh,
                icon: refreshing
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                label: const Text('Refresh status'),
              ),
              const Spacer(),
              TextButton(onPressed: widget.onSignOut, child: const Text('Sign out')),
            ],
          ),
        ),
      ),
    );
  }
}

class _RejectedScreen extends StatelessWidget {
  const _RejectedScreen({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.cancel_outlined, size: 56),
              const SizedBox(height: 20),
              Text('Account not approved', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              const Text(
                'Your account application was not approved. Please contact the administrator for more information.',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              TextButton(onPressed: onSignOut, child: const Text('Sign out')),
            ],
          ),
        ),
      ),
    );
  }
}
