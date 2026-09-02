import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tailor_catalog/core/theme/app_theme.dart';
import 'package:tailor_catalog/features/auth/auth_repository.dart';
import 'package:tailor_catalog/features/designs/dashboard_screen.dart';
import 'package:tailor_catalog/features/designs/design_repository.dart';
import 'package:tailor_catalog/features/designs/edit_design_screen.dart';
import 'package:tailor_catalog/features/designs/models.dart';

class MockEditDesignRepository implements DesignRepository {
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
      nameEn: 'Men\'s Suit',
      nameAm: 'የወንዶች ልብስ',
      nameOm: 'Uffata Dhiirota',
      nameSo: 'Dhar Ragga',
      sortOrder: 2,
    ),
  ];

  List<DesignItem> designs = [];
  bool updateDesignCalled = false;
  String? lastUpdatedDesignId;
  String? lastUpdatedCategoryId;
  double? lastUpdatedPrice;
  String? lastUpdatedTag;
  List<String>? lastDeletedPhotoIds;

  @override
  Future<List<CategoryItem>> getCategories() async => categories;

  @override
  Future<List<DesignItem>> getTailorDesigns(String tailorId) async => List.from(designs);

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
    updateDesignCalled = true;
    lastUpdatedDesignId = designId;
    lastUpdatedCategoryId = categoryId;
    lastUpdatedPrice = price;
    lastUpdatedTag = tag;
    lastDeletedPhotoIds = deletedPhotoIds;

    final updated = DesignItem(
      id: designId,
      tailorId: 'tailor-1',
      categoryId: categoryId,
      price: price,
      tag: tag,
      isGrouped: existingPhotosToKeep.length > 1,
      categoryName: categories.firstWhere((c) => c.id == categoryId, orElse: () => categories.first).nameEn,
      photos: existingPhotosToKeep,
    );

    final idx = designs.indexWhere((d) => d.id == designId);
    if (idx != -1) {
      designs[idx] = updated;
    }
    return updated;
  }

  @override
  Future<void> deleteDesign(String designId) async {
    designs.removeWhere((d) => d.id == designId);
  }
}

void main() {
  const testProfile = TailorProfile(
    id: 'tailor-1',
    authId: 'auth-1',
    shopName: 'Habesha Couture',
    shopSlug: 'habesha-couture',
    status: 'approved',
    email: 'tailor@example.com',
  );

  final testDesign = DesignItem(
    id: 'design-123',
    tailorId: 'tailor-1',
    categoryId: 'cat-1',
    categoryName: 'Women\'s Dress',
    price: 3200,
    tag: 'Silk Kemis',
    isGrouped: false,
    photos: const [
      DesignPhotoItem(
        id: 'photo-1',
        designId: 'design-123',
        cloudinaryPublicId: 'sample/photo1',
        cloudinaryUrl: 'https://example.com/p1.jpg',
        orderIndex: 0,
      ),
      DesignPhotoItem(
        id: 'photo-2',
        designId: 'design-123',
        cloudinaryPublicId: 'sample/photo2',
        cloudinaryUrl: 'https://example.com/p2.jpg',
        orderIndex: 1,
      ),
    ],
  );

  group('Tailor Edit Design Tests', () {
    testWidgets('Edit screen preloads existing design values', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = MockEditDesignRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: EditDesignScreen(
            design: testDesign,
            profile: testProfile,
            designRepository: repo,
            authUid: 'auth-1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check preloaded price
      expect(find.text('3200'), findsOneWidget);

      // Check preloaded tag
      expect(find.text('Silk Kemis'), findsOneWidget);

      // Check photos count header
      expect(find.text('Design Photos (2)'), findsOneWidget);

      // Check Save button exists
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('Edit screen allows editing price, tag, and submitting', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = MockEditDesignRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: EditDesignScreen(
            design: testDesign,
            profile: testProfile,
            designRepository: repo,
            authUid: 'auth-1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Edit price
      await tester.enterText(find.widgetWithText(TextFormField, '3200'), '4500');

      // Edit tag
      await tester.enterText(find.widgetWithText(TextFormField, 'Silk Kemis'), 'Golden Silk Wedding Kemis');

      // Tap Save
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(repo.updateDesignCalled, isTrue);
      expect(repo.lastUpdatedDesignId, equals('design-123'));
      expect(repo.lastUpdatedPrice, equals(4500.0));
      expect(repo.lastUpdatedTag, equals('Golden Silk Wedding Kemis'));
    });

    testWidgets('Dashboard displays edit button on design card', (tester) async {
      final repo = MockEditDesignRepository();
      repo.designs = [testDesign];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: DashboardScreen(
            profile: testProfile,
            designRepository: repo,
            onSignOut: () async {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check edit button icon exists
      expect(find.byKey(const Key('edit_design_btn_design-123')), findsOneWidget);
    });
  });
}
