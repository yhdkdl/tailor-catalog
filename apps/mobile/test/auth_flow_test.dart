import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailor_catalog/core/theme/app_theme.dart';
import 'package:tailor_catalog/features/auth/auth_repository.dart';
import 'package:tailor_catalog/features/auth/auth_screen.dart';
import 'package:tailor_catalog/features/auth/profile_gate.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    Session? initialSession,
    this.profileToReturn,
    this.shouldFailSignIn = false,
    this.signInErrorMessage = 'Invalid login credentials',
  }) : _currentSession = initialSession;

  Session? _currentSession;
  TailorProfile? profileToReturn;
  bool shouldFailSignIn;
  String signInErrorMessage;
  final _controller = StreamController<AuthState>.broadcast();

  int signInCallCount = 0;
  int getProfileCallCount = 0;
  int signOutCallCount = 0;

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

  @override
  Session? get currentSession => _currentSession;

  @override
  Future<void> signIn(String email, String password) async {
    signInCallCount++;
    if (shouldFailSignIn) {
      throw AuthException(signInErrorMessage);
    }
    // Simulate successful login
    final user = User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );
    _currentSession = Session(
      accessToken: 'fake-token',
      tokenType: 'bearer',
      user: user,
    );
    _controller.add(AuthState(AuthChangeEvent.signedIn, _currentSession));
  }

  @override
  Future<TailorProfile> getProfile(String authId) async {
    getProfileCallCount++;
    return profileToReturn ??
        const TailorProfile(
          shopName: 'Habesha Classic',
          shopSlug: 'habesha-classic',
          status: 'pending',
          email: 'tailor@example.com',
        );
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    _currentSession = null;
    _controller.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  void updateProfileStatus(String newStatus) {
    profileToReturn = TailorProfile(
      shopName: profileToReturn?.shopName ?? 'Habesha Classic',
      shopSlug: profileToReturn?.shopSlug ?? 'habesha-classic',
      status: newStatus,
      email: profileToReturn?.email ?? 'tailor@example.com',
    );
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('Tailor Auth Flow Tests', () {
    testWidgets('Part 2 - Screen 1: Login screen UI elements and password toggle', (tester) async {
      final fakeRepo = FakeAuthRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AuthScreen(repository: fakeRepo),
        ),
      );

      // Verify app logo / icon and heading
      expect(find.byIcon(Icons.content_cut_rounded), findsOneWidget);
      expect(find.text('Tailor sign in'), findsOneWidget);
      expect(find.text('Sign in to manage your design catalog.'), findsOneWidget);

      // Verify email and password text fields
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);

      // Verify password visibility toggle
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Verify Sign in button
      expect(find.byKey(const Key('signin_button')), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);

      // Verify admin help text
      expect(
        find.text('Contact your administrator to reset your password.'),
        findsOneWidget,
      );
    });

    testWidgets('Part 2 - Screen 1: Validation and wrong password error handling', (tester) async {
      final fakeRepo = FakeAuthRepository(
        shouldFailSignIn: true,
        signInErrorMessage: 'Invalid login credentials',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AuthScreen(repository: fakeRepo),
        ),
      );

      // 1. Submit without valid email
      await tester.tap(find.byKey(const Key('signin_button')));
      await tester.pump();
      expect(find.text('Enter a valid email address.'), findsOneWidget);

      // 2. Submit with valid email but empty password
      await tester.enterText(find.byKey(const Key('email_field')), 'tailor@example.com');
      await tester.tap(find.byKey(const Key('signin_button')));
      await tester.pump();
      expect(find.text('Enter your password.'), findsOneWidget);

      // 3. Submit with wrong password -> shows clear error
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
      await tester.tap(find.byKey(const Key('signin_button')));
      await tester.pump(); // Start async
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password. Please try again.'), findsOneWidget);
    });

    testWidgets('Part 2 - Screen 2: Pending approval screen routing, refresh, and sign out', (tester) async {
      final fakeRepo = FakeAuthRepository(
        profileToReturn: const TailorProfile(
          shopName: 'Addis Elegance',
          shopSlug: 'addis-elegance',
          status: 'pending',
          email: 'addis@example.com',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: ProfileGate(repository: fakeRepo),
        ),
      );

      // Initially at login screen because session is null
      expect(find.text('Tailor sign in'), findsOneWidget);

      // Log in
      await tester.enterText(find.byKey(const Key('email_field')), 'addis@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('signin_button')));
      await tester.pumpAndSettle();

      // Screen 2: Pending approval screen displayed
      expect(find.text('Addis Elegance'), findsOneWidget);
      expect(
        find.text('Your account is pending approval. Please wait for the administrator to review and approve your account.'),
        findsOneWidget,
      );
      expect(find.text('Refresh status'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);

      // Step 3 & 4: Admin approves tailor -> tailor taps refresh
      fakeRepo.updateProfileStatus('approved');
      await tester.tap(find.text('Refresh status'));
      await tester.pumpAndSettle();

      // Screen 4: Main dashboard displayed
      expect(find.text('Welcome Addis Elegance'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);

      // Sign out from dashboard
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      // Back to login screen
      expect(find.text('Tailor sign in'), findsOneWidget);
    });

    testWidgets('Part 2 - Screen 3: Rejected account routing and sign out', (tester) async {
      final fakeRepo = FakeAuthRepository(
        profileToReturn: const TailorProfile(
          shopName: 'Rejected Shop',
          shopSlug: 'rejected-shop',
          status: 'rejected',
          email: 'rejected@example.com',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: ProfileGate(repository: fakeRepo),
        ),
      );

      // Log in
      await tester.enterText(find.byKey(const Key('email_field')), 'rejected@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('signin_button')));
      await tester.pumpAndSettle();

      // Screen 3: Rejected screen displayed
      expect(find.text('Account not approved'), findsOneWidget);
      expect(
        find.text('Your account application was not approved. Please contact the administrator for more information.'),
        findsOneWidget,
      );

      // Tap Sign out
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      // Back to login screen
      expect(find.text('Tailor sign in'), findsOneWidget);
    });

    testWidgets('Part 3 - Session persistence: app opens with existing session', (tester) async {
      final existingSession = Session(
        accessToken: 'stored-token',
        tokenType: 'bearer',
        user: User(
          id: 'existing-tailor-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      final fakeRepo = FakeAuthRepository(
        initialSession: existingSession,
        profileToReturn: const TailorProfile(
          shopName: 'Pre-authenticated Tailor',
          shopSlug: 'pre-auth-tailor',
          status: 'approved',
          email: 'existing@example.com',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: ProfileGate(repository: fakeRepo),
        ),
      );

      await tester.pumpAndSettle();

      // Directly routes to dashboard without showing login screen
      expect(find.text('Welcome Pre-authenticated Tailor'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Tailor sign in'), findsNothing);
    });
  });
}
