import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../upload/cloudinary_service.dart';
import 'models.dart';

abstract interface class DesignRepository {
  Future<List<CategoryItem>> getCategories();
  Future<List<DesignItem>> getTailorDesigns(String tailorId);
  Future<DesignItem> createSingleDesign({
    required String tailorId,
    required String categoryId,
    required double price,
    String? tag,
    required Uint8List imageBytes,
    required String filename,
    required String authUid,
  });
  Future<DesignItem> createGroupedDesign({
    required String tailorId,
    required String categoryId,
    required double price,
    String? tag,
    required List<Uint8List> imageBytesList,
    required List<String> filenames,
    required String authUid,
    void Function(int current, int total)? onProgress,
  });
  Future<List<DesignItem>> createBulkIndividualDesigns({
    required String tailorId,
    required String categoryId,
    required double price,
    String? tag,
    required List<Uint8List> imageBytesList,
    required List<String> filenames,
    required String authUid,
    void Function(int current, int total)? onProgress,
  });
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
  });
  Future<void> deleteDesign(String designId);
}

class SupabaseDesignRepository implements DesignRepository {
  SupabaseDesignRepository({
    required this.client,
    CloudinaryService? cloudinaryService,
  }) : _cloudinaryService = cloudinaryService ?? const HttpCloudinaryService();

  final SupabaseClient client;
  final CloudinaryService _cloudinaryService;
  final _uuid = const Uuid();

  @override
  Future<List<CategoryItem>> getCategories() async {
    final data = await client
        .from('categories')
        .select()
        .order('sort_order', ascending: true);
    return (data as List<dynamic>)
        .map((c) => CategoryItem.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DesignItem>> getTailorDesigns(String tailorId) async {
    final data = await client
        .from('designs')
        .select('*, design_photos(*), categories(name_en, name_am, name_om, name_so)')
        .eq('tailor_id', tailorId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((d) => DesignItem.fromJson(d as Map<String, dynamic>))
        .toList();
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
    final designId = _uuid.v4();

    // 1. Upload photo directly to Cloudinary
    final uploadResult = await _cloudinaryService.uploadImage(
      imageBytes: imageBytes,
      filename: filename,
      authUid: authUid,
      designId: designId,
    );

    // 2. Insert design record in Supabase
    final designData = await client
        .from('designs')
        .insert({
          'id': designId,
          'tailor_id': tailorId,
          'category_id': categoryId,
          'price': price,
          'tag': tag?.trim().isNotEmpty == true ? tag!.trim() : null,
          'is_grouped': false,
        })
        .select()
        .single();

    // 3. Insert design photo record
    final photoData = await client
        .from('design_photos')
        .insert({
          'design_id': designId,
          'cloudinary_public_id': uploadResult.publicId,
          'cloudinary_url': uploadResult.secureUrl,
          'order_index': 0,
        })
        .select()
        .single();

    final photo = DesignPhotoItem.fromJson(photoData);

    return DesignItem(
      id: designData['id'] as String,
      tailorId: designData['tailor_id'] as String,
      categoryId: designData['category_id'] as String,
      price: (designData['price'] as num?)?.toDouble() ?? price,
      tag: designData['tag'] as String?,
      isGrouped: false,
      photos: [photo],
    );
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
    final designId = _uuid.v4();

    // 1. Insert grouped design record in Supabase
    final designData = await client
        .from('designs')
        .insert({
          'id': designId,
          'tailor_id': tailorId,
          'category_id': categoryId,
          'price': price,
          'tag': tag?.trim().isNotEmpty == true ? tag!.trim() : null,
          'is_grouped': true,
        })
        .select()
        .single();

    final createdPhotos = <DesignPhotoItem>[];

    // 2. Upload each photo & insert design_photo records
    for (var i = 0; i < imageBytesList.length; i++) {
      final bytes = imageBytesList[i];
      final fname = filenames.length > i ? filenames[i] : 'photo_$i.jpg';

      final uploadResult = await _cloudinaryService.uploadImage(
        imageBytes: bytes,
        filename: fname,
        authUid: authUid,
        designId: designId,
      );

      final photoData = await client
          .from('design_photos')
          .insert({
            'design_id': designId,
            'cloudinary_public_id': uploadResult.publicId,
            'cloudinary_url': uploadResult.secureUrl,
            'order_index': i,
          })
          .select()
          .single();

      createdPhotos.add(DesignPhotoItem.fromJson(photoData));
      onProgress?.call(i + 1, imageBytesList.length);
    }

    return DesignItem(
      id: designData['id'] as String,
      tailorId: designData['tailor_id'] as String,
      categoryId: designData['category_id'] as String,
      price: (designData['price'] as num?)?.toDouble() ?? price,
      tag: designData['tag'] as String?,
      isGrouped: true,
      photos: createdPhotos,
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
    final createdDesigns = <DesignItem>[];

    for (var i = 0; i < imageBytesList.length; i++) {
      final bytes = imageBytesList[i];
      final fname = filenames.length > i ? filenames[i] : 'design_$i.jpg';

      final design = await createSingleDesign(
        tailorId: tailorId,
        categoryId: categoryId,
        price: price,
        tag: tag,
        imageBytes: bytes,
        filename: fname,
        authUid: authUid,
      );

      createdDesigns.add(design);
      onProgress?.call(i + 1, imageBytesList.length);
    }

    return createdDesigns;
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
    // 1. Update design core attributes
    await client.from('designs').update({
      'category_id': categoryId,
      'price': price,
      'tag': tag?.trim().isNotEmpty == true ? tag!.trim() : null,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', designId);

    // 2. Delete removed photos from DB and Cloudinary
    for (final pid in deletedPhotoIds) {
      await client.from('design_photos').delete().eq('id', pid);
    }
    for (final pubId in deletedCloudinaryPublicIds) {
      await _cloudinaryService.deleteImage(publicId: pubId);
    }

    // 3. Update existing photos order_index
    for (var i = 0; i < existingPhotosToKeep.length; i++) {
      final p = existingPhotosToKeep[i];
      await client.from('design_photos').update({
        'order_index': i,
      }).eq('id', p.id);
    }

    // 4. Upload and insert new photos
    final startIndex = existingPhotosToKeep.length;
    for (var i = 0; i < newImageBytesList.length; i++) {
      final bytes = newImageBytesList[i];
      final fname = newFilenames.length > i ? newFilenames[i] : 'photo_${startIndex + i}.jpg';

      final uploadResult = await _cloudinaryService.uploadImage(
        imageBytes: bytes,
        filename: fname,
        authUid: authUid,
        designId: designId,
      );

      await client.from('design_photos').insert({
        'design_id': designId,
        'cloudinary_public_id': uploadResult.publicId,
        'cloudinary_url': uploadResult.secureUrl,
        'order_index': startIndex + i,
      });

      onProgress?.call(i + 1, newImageBytesList.length);
    }

    // 5. Fetch updated design record
    final data = await client
        .from('designs')
        .select('*, design_photos(*), categories(name_en, name_am, name_om, name_so)')
        .eq('id', designId)
        .single();

    return DesignItem.fromJson(data);
  }

  @override
  Future<void> deleteDesign(String designId) async {
    await client.from('designs').delete().eq('id', designId);
  }
}

class UnconfiguredDesignRepository implements DesignRepository {
  const UnconfiguredDesignRepository();

  @override
  Future<List<CategoryItem>> getCategories() async => const [];

  @override
  Future<List<DesignItem>> getTailorDesigns(String tailorId) async => const [];

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
      throw Exception('Supabase is not configured.');

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
      throw Exception('Supabase is not configured.');

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
      throw Exception('Supabase is not configured.');

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
      throw Exception('Supabase is not configured.');

  @override
  Future<void> deleteDesign(String designId) async {}
}
