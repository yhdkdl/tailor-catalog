import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_catalog/core/theme/app_theme.dart';
import 'package:tailor_catalog/features/auth/auth_repository.dart';
import 'package:tailor_catalog/features/designs/dashboard_screen.dart';
import 'package:tailor_catalog/features/designs/design_repository.dart';
import 'package:tailor_catalog/features/designs/models.dart';
import 'package:tailor_catalog/features/upload/cloudinary_service.dart';
import 'package:tailor_catalog/features/upload/single_upload_screen.dart';

class FakeCloudinaryService implements CloudinaryService {
  @override
  Future<CloudinaryUploadResult> uploadImage({
    required Uint8List imageBytes,
    required String filename,
    required String authUid,
    required String designId,
  }) async {
    return CloudinaryUploadResult(
      publicId: 'tailor-designs/$authUid/$designId/fake_sample',
      secureUrl: 'https://res.cloudinary.com/test/image/upload/v1/tailor-designs/$authUid/$designId/fake_sample.jpg',
    );
  }

  @override
  Future<void> deleteImage({required String publicId}) async {}
}

class FakeDesignRepository implements DesignRepository {
  List<CategoryItem> categories = [
    const CategoryItem(
      id: 'cat-1',
      nameEn: 'Women\'s Dress',
      nameAm: 'የሴቶች ልብስ',
      nameOm: 'Uffata Dubartoota',
      nameSo: 'Dhar Dumarku',
      sortOrder: 1,
    ),
    const CategoryItem(
      id: 'cat-2',
      nameEn: 'Traditional Attire',
      nameAm: 'ባህላዊ ልብስ',
      nameOm: 'Uffata Aadaa',
      nameSo: 'Dharka Dhaqanka',
      sortOrder: 2,
    ),
  ];

  List<DesignItem> designs = [];
  int createSingleDesignCallCount = 0;
  int deleteDesignCallCount = 0;

  @override
  Future<List<CategoryItem>> getCategories() async {
    return categories;
  }

  @override
  Future<List<DesignItem>> getTailorDesigns(String tailorId) async {
    return List.from(designs);
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
  }) async {
    createSingleDesignCallCount++;
    final newDesign = DesignItem(
      id: 'design-${DateTime.now().millisecondsSinceEpoch}',
      tailorId: tailorId,
      categoryId: categoryId,
      price: price,
      tag: tag,
      isGrouped: false,
      categoryName: categories.firstWhere((c) => c.id == categoryId).nameEn,
      photos: [
        DesignPhotoItem(
          id: 'photo-1',
          designId: 'design-1',
          cloudinaryPublicId: 'tailor-designs/$authUid/design-1/photo1',
          cloudinaryUrl: 'https://example.com/photo1.jpg',
        ),
      ],
    );
    designs.insert(0, newDesign);
    return newDesign;
  }

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
  }) async {
    return createSingleDesign(
      tailorId: tailorId,
      categoryId: categoryId,
      price: price,
      tag: tag,
      imageBytes: imageBytesList.first,
      filename: filenames.first,
      authUid: authUid,
    );
  }

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
  }) async {
    final d = await createSingleDesign(
      tailorId: tailorId,
      categoryId: categoryId,
      price: price,
      tag: tag,
      imageBytes: imageBytesList.first,
      filename: filenames.first,
      authUid: authUid,
    );
    return [d];
  }

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
  }) async {
    final idx = designs.indexWhere((d) => d.id == designId);
    final existing = idx != -1 ? designs[idx] : null;
    final updated = DesignItem(
      id: designId,
      tailorId: existing?.tailorId ?? 'tailor-1',
      categoryId: categoryId,
      price: price,
      tag: tag,
      isGrouped: existing?.isGrouped ?? false,
      categoryName: categories.firstWhere((c) => c.id == categoryId, orElse: () => categories.first).nameEn,
      photos: existingPhotosToKeep,
    );
    if (idx != -1) {
      designs[idx] = updated;
    }
    return updated;
  }

  @override
  Future<void> deleteDesign(String designId) async {
    deleteDesignCallCount++;
    designs.removeWhere((d) => d.id == designId);
  }
}

void main() {
  group('Sprint 9: Single Design Upload & Catalog Dashboard Tests', () {
    const testProfile = TailorProfile(
      id: 'tailor-uuid-1',
      authId: 'auth-uuid-1',
      shopName: 'Bole Traditional Styles',
      shopSlug: 'bole-traditional',
      status: 'approved',
      email: 'bole@example.com',
    );

    testWidgets('Upload screen renders fields and validates required inputs', (tester) async {
      final fakeRepo = FakeDesignRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: SingleDesignUploadScreen(
            tailorProfile: testProfile,
            designRepository: fakeRepo,
            authUid: 'auth-uuid-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify category, tag, and publish button are rendered
      expect(find.text('Upload Design'), findsOneWidget);
      expect(find.text('Tap to select design photo'), findsOneWidget);
      expect(find.text('Category *'), findsOneWidget);
      expect(find.byKey(const Key('tag_field')), findsOneWidget);
      expect(find.byKey(const Key('publish_design_btn')), findsOneWidget);

      // Attempt submit without image -> displays error message
      await tester.tap(find.byKey(const Key('publish_design_btn')));
      await tester.pump();
      expect(find.text('Please select a design photo.'), findsOneWidget);
    });

    testWidgets('Dashboard renders catalog, displays design details, and handles deletion', (tester) async {
      final fakeRepo = FakeDesignRepository();
      fakeRepo.designs = [
        const DesignItem(
          id: 'design-abc',
          tailorId: 'tailor-uuid-1',
          categoryId: 'cat-1',
          categoryName: 'Traditional Attire',
          price: 3500,
          tag: 'Gold Tilf',
          isGrouped: false,
          photos: [
            DesignPhotoItem(
              id: 'p-1',
              designId: 'design-abc',
              cloudinaryPublicId: 'tailor-designs/auth-1/design-abc/img1',
              cloudinaryUrl: 'https://example.com/img1.jpg',
            ),
          ],
        ),
      ];

      var signedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: DashboardScreen(
            profile: testProfile,
            designRepository: fakeRepo,
            onSignOut: () async {
              signedOut = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify shop name, approved badge, and design details
      expect(find.text('Bole Traditional Styles'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Traditional Attire'), findsOneWidget);
      expect(find.text('#Gold Tilf'), findsOneWidget);
      expect(find.byKey(const Key('upload_fab')), findsOneWidget);

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Delete Design'), findsOneWidget);
      expect(find.text('Are you sure you want to remove this design from your catalog?'), findsOneWidget);

      // Confirm delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(fakeRepo.deleteDesignCallCount, equals(1));
      expect(find.text('ETB 3500'), findsNothing);
      expect(find.text('Your catalog is empty'), findsOneWidget);

      // Test sign out
      await tester.tap(find.byIcon(Icons.logout_outlined));
      expect(signedOut, isTrue);
    });
  });
}
