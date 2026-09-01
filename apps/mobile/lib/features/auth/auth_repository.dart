import 'package:supabase_flutter/supabase_flutter.dart';

class TailorProfile {
  const TailorProfile({
    this.id = '',
    this.authId = '',
    required this.shopName,
    required this.shopSlug,
    required this.status,
    required this.email,
  });

  final String id;
  final String authId;
  final String shopName;
  final String shopSlug;
  final String status;
  final String email;

  factory TailorProfile.fromJson(Map<String, dynamic> json) {
    return TailorProfile(
      id: json['id'] as String? ?? '',
      authId: json['auth_id'] as String? ?? '',
      shopName: json['shop_name'] as String? ?? 'Your shop',
      shopSlug: json['shop_slug'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      email: json['email'] as String? ?? '',
    );
  }
}

abstract interface class AuthRepository {
  Stream<AuthState> get authStateChanges;
  Session? get currentSession;
  Future<void> signIn(String email, String password);
  Future<TailorProfile> getProfile(String authId);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this.client);

  final SupabaseClient client;

  @override
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  @override
  Session? get currentSession => client.auth.currentSession;

  @override
  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<TailorProfile> getProfile(String authId) async {
    final data = await client.from('tailors').select().eq('auth_id', authId).single();
    return TailorProfile.fromJson(data);
  }

  @override
  Future<void> signOut() => client.auth.signOut();
}

class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Session? get currentSession => null;

  @override
  Future<void> signIn(String email, String password) =>
      Future.error(Exception('Supabase is not configured for this build.'));

  @override
  Future<TailorProfile> getProfile(String authId) =>
      Future.error(Exception('Supabase is not configured for this build.'));

  @override
  Future<void> signOut() async {}
}
