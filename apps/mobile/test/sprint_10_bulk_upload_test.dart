import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_catalog/core/theme/app_theme.dart';
import 'package:tailor_catalog/features/auth/auth_repository.dart';
import 'package:tailor_catalog/features/designs/dashboard_screen.dart';
import 'package:tailor_catalog/features/designs/design_repository.dart';
import 'package:tailor_catalog/features/designs/models.dart';
import 'package:tailor_catalog/features/upload/bulk_upload_screen.dart';

class FakeBulkDesignRepository implements DesignRepository {
  List<CategoryItem> categories = [
    const CategoryItem(
      id: 'cat-1',
      nameEn: 'Traditional Attire',
      nameAm: 'ባህላዊ ልብስ',
      nameOm: 'Uffata Aadaa',
      nameSo: 'Dharka Dhaqanka',
      sortOrder: 1,
    ),
  ];

  List<DesignItem> designs = [];
  int createGroupedCallCount = 0;
  int createBulkIndividualCallCount = 0;

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
  }) async {
    final d = DesignItem(
      id: 'single-design-${DateTime.now().millisecondsSinceEpoch}',
      tailorId: tailorId,
      categoryId: categoryId,
      price: price,
      tag: tag,
      isGrouped: false,
      categoryName: 'Traditional Attire',
      photos: [
        DesignPhotoItem(
          id: 'photo-1',
          designId: 'single-1',
          cloudinaryPublicId: 'tailor-designs/$authUid/single-1/photo1',
          cloudinaryUrl: 'https://example.com/single.jpg',
        ),
      ],
    );
    designs.add(d);
    return d;
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
    createGroupedCallCount++;
    final photos = <DesignPhotoItem>[];
    for (var i = 0; i < imageBytesList.length; i++) {
      photos.add(
        DesignPhotoItem(
          id: 'grouped-photo-$i',
          designId: 'grouped-design-1',
          cloudinaryPublicId: 'tailor-designs/$authUid/grouped-1/photo$i',
          cloudinaryUrl: 'https://example.com/photo$i.jpg',
          orderIndex: i,
        ),
      );
      onProgress?.call(i + 1, imageBytesList.length);
    }

    final d = DesignItem(
      id: 'grouped-design-1',
      tailorId: tailorId,
      categoryId: categoryId,
      price: price,
      tag: tag,
      isGrouped: true,
      categoryName: 'Traditional Attire',
      photos: photos,
    );
    designs.add(d);
    return d;
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
    createBulkIndividualCallCount++;
    final created = <DesignItem>[];
    for (var i = 0; i < imageBytesList.length; i++) {
      final d = await createSingleDesign(
        tailorId: tailorId,
        categoryId: categoryId,
        price: price,
        tag: tag,
        imageBytes: imageBytesList[i],
        filename: filenames[i],
        authUid: authUid,
      );
      created.add(d);
      onProgress?.call(i + 1, imageBytesList.length);
    }
    return created;
  }

  @override
  Future<void> deleteDesign(String designId) async {
    designs.removeWhere((d) => d.id == designId);
  }
}

void main() {
  group('Sprint 10: Bulk & Multi-Photo Upload Tests', () {
    const testProfile = TailorProfile(
      id: 'tailor-uuid-1',
      authId: 'auth-uuid-1',
      shopName: 'Bole Traditional Styles',
      shopSlug: 'bole-traditional',
      status: 'approved',
      email: 'bole@example.com',
    );

    testWidgets('BulkUploadScreen renders UI controls and switches upload modes', (tester) async {
      final fakeRepo = FakeBulkDesignRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: BulkUploadScreen(
            tailorProfile: testProfile,
            designRepository: fakeRepo,
            authUid: 'auth-uuid-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bulk & Multi-Photo Upload'), findsOneWidget);
      expect(find.text('Selected Photos (0)'), findsOneWidget);
      expect(find.text('Upload Structure'), findsOneWidget);
      expect(find.text('Separate Cards'), findsOneWidget);
      expect(find.text('Grouped Carousel'), findsOneWidget);
      expect(find.byKey(const Key('bulk_price_field')), findsOneWidget);
      expect(find.byKey(const Key('bulk_tag_field')), findsOneWidget);
      expect(find.byKey(const Key('publish_bulk_btn')), findsOneWidget);

      // Select Grouped mode
      await tester.tap(find.text('Grouped Carousel'));
      await tester.pumpAndSettle();
      expect(find.text('Publish Multi-Photo Design'), findsOneWidget);

      // Attempt submit without photos -> error message displayed
      await tester.ensureVisible(find.byKey(const Key('publish_bulk_btn')));
      await tester.tap(find.byKey(const Key('publish_bulk_btn')));
      await tester.pump();
      expect(find.text('Please select at least one photo.'), findsOneWidget);
    });

    testWidgets('Dashboard renders multi-photo badge on grouped design cards', (tester) async {
      final fakeRepo = FakeBulkDesignRepository();
      fakeRepo.designs = [
        const DesignItem(
          id: 'multi-design-1',
          tailorId: 'tailor-uuid-1',
          categoryId: 'cat-1',
          categoryName: 'Traditional Attire',
          price: 5200,
          tag: 'Wedding Set',
          isGrouped: true,
          photos: [
            DesignPhotoItem(
              id: 'p-1',
              designId: 'multi-design-1',
              cloudinaryPublicId: 'tailor-designs/auth-1/multi-design-1/img1',
              cloudinaryUrl: 'https://example.com/img1.jpg',
              orderIndex: 0,
            ),
            DesignPhotoItem(
              id: 'p-2',
              designId: 'multi-design-1',
              cloudinaryPublicId: 'tailor-designs/auth-1/multi-design-1/img2',
              cloudinaryUrl: 'https://example.com/img2.jpg',
              orderIndex: 1,
            ),
            DesignPhotoItem(
              id: 'p-3',
              designId: 'multi-design-1',
              cloudinaryPublicId: 'tailor-designs/auth-1/multi-design-1/img3',
              cloudinaryUrl: 'https://example.com/img3.jpg',
              orderIndex: 2,
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

      expect(find.text('ETB 5200'), findsOneWidget);
      expect(find.text('#Wedding Set'), findsOneWidget);
      // Photo count badge shows 3
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.collections_outlined), findsOneWidget);

      // Tap FAB -> displays upload bottom sheet modal
      await tester.tap(find.byKey(const Key('upload_fab')));
      await tester.pumpAndSettle();

      expect(find.text('Single Photo Design'), findsOneWidget);
      expect(find.text('Bulk & Multi-Photo Upload'), findsOneWidget);
    });
  });
}
