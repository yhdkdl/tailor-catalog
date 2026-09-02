import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailor_catalog/core/theme/app_theme.dart';
import 'package:tailor_catalog/features/auth/auth_repository.dart';
import 'package:tailor_catalog/features/designs/dashboard_screen.dart';
import 'package:tailor_catalog/features/designs/design_repository.dart';
import 'package:tailor_catalog/features/designs/models.dart';
import 'package:tailor_catalog/features/offline/offline_service.dart';
import 'package:tailor_catalog/features/offline/offline_sync_manager.dart';

class FakeFailingDesignRepository implements DesignRepository {
  List<DesignItem> uploadedDesigns = [];
  bool shouldFail = false;

  @override
  Future<List<CategoryItem>> getCategories() async {
    if (shouldFail) throw Exception('Network offline');
    return [
      const CategoryItem(
        id: 'cat-1',
        nameEn: 'Traditional Attire',
        nameAm: 'ባህላዊ ልብስ',
        nameOm: 'Uffata Aadaa',
        nameSo: 'Dharka Dhaqanka',
        sortOrder: 1,
      ),
    ];
  }

  @override
  Future<List<DesignItem>> getTailorDesigns(String tailorId) async {
    if (shouldFail) throw Exception('Network offline');
    return [
      const DesignItem(
        id: 'cached-design-1',
        tailorId: 'tailor-1',
        categoryId: 'cat-1',
        categoryName: 'Traditional Attire',
        price: 4500,
        tag: 'Silk Gabi',
        isGrouped: false,
        photos: [
          DesignPhotoItem(
            id: 'photo-1',
            designId: 'cached-design-1',
            cloudinaryPublicId: 'sample/cached',
            cloudinaryUrl: 'https://example.com/cached.jpg',
          ),
        ],
      ),
    ];
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
    if (shouldFail) throw Exception('Network offline');
    final d = DesignItem(
      id: 'synced-single',
      tailorId: tailorId,
      categoryId: categoryId,
      price: price,
      tag: tag,
      isGrouped: false,
      photos: [
        const DesignPhotoItem(
          id: 'p-1',
          designId: 'synced-single',
          cloudinaryPublicId: 'sample/synced',
          cloudinaryUrl: 'https://example.com/synced.jpg',
        ),
      ],
    );
    uploadedDesigns.add(d);
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
    if (shouldFail) throw Exception('Network offline');
    final d = DesignItem(
      id: 'synced-grouped',
      tailorId: tailorId,
      categoryId: categoryId,
      price: price,
      tag: tag,
      isGrouped: true,
      photos: [
        const DesignPhotoItem(
          id: 'p-1',
          designId: 'synced-grouped',
          cloudinaryPublicId: 'sample/synced-g',
          cloudinaryUrl: 'https://example.com/synced-g.jpg',
        ),
      ],
    );
    uploadedDesigns.add(d);
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
    if (shouldFail) throw Exception('Network offline');
    final results = <DesignItem>[];
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
      results.add(d);
    }
    return results;
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
    if (shouldFail) throw Exception('Network offline');
    return DesignItem(
      id: designId,
      tailorId: 'tailor-1',
      categoryId: categoryId,
      price: price,
      tag: tag,
      isGrouped: false,
      photos: existingPhotosToKeep,
    );
  }

  @override
  Future<void> deleteDesign(String designId) async {}
}

void main() {
  group('Sprint 11: Offline Support & Upload Retry Queue Tests', () {
    const testProfile = TailorProfile(
      id: 'tailor-1',
      authId: 'auth-1',
      shopName: 'Piassa Couture',
      shopSlug: 'piassa-couture',
      status: 'approved',
      email: 'piassa@example.com',
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Local cache stores designs and retrieves them when offline', () async {
      final storage = SharedPreferencesOfflineStorage();
      final repo = FakeFailingDesignRepository();
      final syncManager = OfflineSyncManager(designRepository: repo, storage: storage);

      // 1. Initial online fetch caches data
      final designs = await syncManager.getTailorDesigns('tailor-1');
      expect(designs.length, equals(1));
      expect(designs.first.tag, equals('Silk Gabi'));

      // 2. Set repository to fail (offline)
      repo.shouldFail = true;

      // 3. getTailorDesigns still returns cached designs
      final cachedDesigns = await syncManager.getTailorDesigns('tailor-1');
      expect(cachedDesigns.length, equals(1));
      expect(cachedDesigns.first.tag, equals('Silk Gabi'));
      expect(cachedDesigns.first.price, equals(4500));
    });

    test('Pending upload queue enqueues and syncs automatically', () async {
      final storage = SharedPreferencesOfflineStorage();
      final repo = FakeFailingDesignRepository();
      final syncManager = OfflineSyncManager(designRepository: repo, storage: storage);

      // Enqueue offline upload
      await syncManager.enqueueOfflineUpload(
        tailorId: 'tailor-1',
        categoryId: 'cat-1',
        price: 3200,
        tag: 'Modern Kemis',
        isGrouped: false,
        imageBytesList: [Uint8List.fromList([1, 2, 3, 4])],
        filenames: ['kemis.jpg'],
        authUid: 'auth-1',
      );

      var pending = await syncManager.getPendingUploads();
      expect(pending.length, equals(1));
      expect(pending.first.tag, equals('Modern Kemis'));

      // Process queue while online
      final result = await syncManager.processQueue();
      expect(result.succeededCount, equals(1));
      expect(result.failedCount, equals(0));

      pending = await syncManager.getPendingUploads();
      expect(pending.isEmpty, isTrue);
      expect(repo.uploadedDesigns.length, equals(1));
    });

    testWidgets('Dashboard renders offline pending queue banner', (tester) async {
      final storage = SharedPreferencesOfflineStorage();
      final repo = FakeFailingDesignRepository();
      final syncManager = OfflineSyncManager(designRepository: repo, storage: storage);

      // Seed pending queue
      await syncManager.enqueueOfflineUpload(
        tailorId: 'tailor-1',
        categoryId: 'cat-1',
        price: 2800,
        tag: 'Linen Suit',
        isGrouped: false,
        imageBytesList: [Uint8List.fromList([5, 6, 7, 8])],
        filenames: ['suit.jpg'],
        authUid: 'auth-1',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: DashboardScreen(
            profile: testProfile,
            designRepository: repo,
            syncManager: syncManager,
            onSignOut: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify pending queue banner is visible
      expect(find.text('1 upload(s) pending in offline queue.'), findsOneWidget);
      expect(find.text('Sync now'), findsOneWidget);

      // Tap Sync now
      await tester.tap(find.text('Sync now'));
      await tester.pumpAndSettle();

      // Verify queue is synced and banner disappears
      expect(find.text('1 upload(s) pending in offline queue.'), findsNothing);
    });
  });
}
