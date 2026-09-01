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
  Future<void> deleteDesign(String designId) async {}
}
