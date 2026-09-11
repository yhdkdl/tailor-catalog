import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_catalog/core/theme/app_theme.dart';
import 'package:tailor_catalog/features/auth/auth_repository.dart';
import 'package:tailor_catalog/features/designs/dashboard_screen.dart';
import 'package:tailor_catalog/features/designs/design_repository.dart';
import 'package:tailor_catalog/features/designs/models.dart';

class FakeBatchDeleteRepository implements DesignRepository {
  List<DesignItem> designs = [];
  final List<String> deletedIds = [];

  @override
  Future<List<CategoryItem>> getCategories() async => const [];

  @override
  Future<List<DesignItem>> getTailorDesigns(String tailorId) async => designs;

  @override
  Future<void> deleteDesign(String designId) async {
    deletedIds.add(designId);
    designs.removeWhere((d) => d.id == designId);
  }

  @override
  Future<DesignItem> createSingleDesign({
    required String tailorId,
    required String categoryId,
    required double price,
    String? tag,
    required Uint8List imageBytes,
    required String filename,
    required String authUid,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<DesignItem>> createBulkIndividualDesigns({
    required String tailorId,
    required String categoryId,
    required double price,
    String? tag,
    required List<Uint8List> imageBytesList,
    required List<String> filenames,
    required String authUid,
    void Function(int current, int total)? onProgress,
  }) async =>
      throw UnimplementedError();

  @override
  Future<DesignItem> createGroupedDesign({
    required String tailorId,
    required String categoryId,
    required double price,
    String? tag,
    required List<Uint8List> imageBytesList,
    required List<String> filenames,
    required String authUid,
    void Function(int current, int total)? onProgress,
  }) async =>
      throw UnimplementedError();

  @override
  Future<DesignItem> updateDesign({
    required String designId,
    required String categoryId,
    required double price,
    String? tag,
    required List<DesignPhotoItem> existingPhotosToKeep,
    required List<Uint8List> newImageBytesList,
    required List<String> newFilenames,
    required List<String> deletedPhotoIds,
    required List<String> deletedCloudinaryPublicIds,
    required String authUid,
    void Function(int current, int total)? onProgress,
  }) async =>
      throw UnimplementedError();
}

void main() {
  const testProfile = TailorProfile(
    id: 'tailor-1',
    authId: 'auth-1',
    shopName: 'Dahlak Tailoring',
    shopSlug: 'dahlak',
    status: 'approved',
    email: 'dahlak@example.com',
  );

  testWidgets('Dashboard allows selecting all designs and deleting in batch', (tester) async {
    final fakeRepo = FakeBatchDeleteRepository();
    fakeRepo.designs = [
      const DesignItem(
        id: 'd-1',
        tailorId: 'tailor-1',
        categoryId: 'cat-1',
        categoryName: 'Dresses',
        price: 0,
        tag: 'Dress 1',
        isGrouped: false,
        photos: [
          DesignPhotoItem(
            id: 'p-1',
            designId: 'd-1',
            cloudinaryPublicId: 'pub-1',
            cloudinaryUrl: 'https://example.com/p1.jpg',
          ),
        ],
      ),
      const DesignItem(
        id: 'd-2',
        tailorId: 'tailor-1',
        categoryId: 'cat-1',
        categoryName: 'Suits',
        price: 0,
        tag: 'Suit 2',
        isGrouped: false,
        photos: [
          DesignPhotoItem(
            id: 'p-2',
            designId: 'd-2',
            cloudinaryPublicId: 'pub-2',
            cloudinaryUrl: 'https://example.com/p2.jpg',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: DashboardScreen(
          profile: testProfile,
          designRepository: fakeRepo,
          onSignOut: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Dahlak Tailoring'), findsOneWidget);
    expect(find.text('#Dress 1'), findsOneWidget);
    expect(find.text('#Suit 2'), findsOneWidget);

    // Enter selection mode
    expect(find.byKey(const Key('enter_selection_btn')), findsOneWidget);
    await tester.tap(find.byKey(const Key('enter_selection_btn')));
    await tester.pumpAndSettle();

    // Verify selection bar is active
    expect(find.text('0 Selected'), findsOneWidget);
    expect(find.byKey(const Key('select_all_btn')), findsOneWidget);

    // Tap "Select All"
    await tester.tap(find.byKey(const Key('select_all_btn')));
    await tester.pumpAndSettle();

    // Verify 2 selected
    expect(find.text('2 Selected'), findsOneWidget);
    expect(find.text('Deselect All'), findsOneWidget);

    // Tap "Delete Selected"
    await tester.tap(find.byKey(const Key('delete_selected_btn')));
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Delete Entire Catalog'), findsOneWidget);
    expect(find.byKey(const Key('confirm_batch_delete_dialog_btn')), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.byKey(const Key('confirm_batch_delete_dialog_btn')));
    await tester.pumpAndSettle();

    // Verify both were deleted via repository
    expect(fakeRepo.deletedIds, containsAll(['d-1', 'd-2']));
    expect(find.text('Your catalog is empty'), findsOneWidget);
  });
}
