import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../designs/models.dart';

class QueuedUploadItem {
  QueuedUploadItem({
    required this.id,
    required this.tailorId,
    required this.categoryId,
    required this.price,
    this.tag,
    required this.isGrouped,
    required this.imagesBase64,
    required this.filenames,
    required this.authUid,
    required this.createdAt,
    this.retryCount = 0,
  });

  final String id;
  final String tailorId;
  final String categoryId;
  final double price;
  final String? tag;
  final bool isGrouped;
  final List<String> imagesBase64;
  final List<String> filenames;
  final String authUid;
  final DateTime createdAt;
  int retryCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tailor_id': tailorId,
        'category_id': categoryId,
        'price': price,
        'tag': tag,
        'is_grouped': isGrouped,
        'images_base64': imagesBase64,
        'filenames': filenames,
        'auth_uid': authUid,
        'created_at': createdAt.toIso8601String(),
        'retry_count': retryCount,
      };

  factory QueuedUploadItem.fromJson(Map<String, dynamic> json) {
    return QueuedUploadItem(
      id: json['id'] as String,
      tailorId: json['tailor_id'] as String,
      categoryId: json['category_id'] as String,
      price: (json['price'] as num).toDouble(),
      tag: json['tag'] as String?,
      isGrouped: json['is_grouped'] as bool? ?? false,
      imagesBase64: (json['images_base64'] as List<dynamic>).cast<String>(),
      filenames: (json['filenames'] as List<dynamic>).cast<String>(),
      authUid: json['auth_uid'] as String,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
    );
  }
}

abstract interface class OfflineStorage {
  Future<void> cacheDesigns(String tailorId, List<DesignItem> designs);
  Future<List<DesignItem>> getCachedDesigns(String tailorId);
  Future<void> cacheCategories(List<CategoryItem> categories);
  Future<List<CategoryItem>> getCachedCategories();
  Future<void> enqueueUpload(QueuedUploadItem item);
  Future<List<QueuedUploadItem>> getPendingUploads();
  Future<void> removePendingUpload(String id);
}

class InMemoryOfflineStorage implements OfflineStorage {
  final Map<String, List<DesignItem>> _designs = {};
  List<CategoryItem> _categories = [];
  final List<QueuedUploadItem> _queue = [];

  @override
  Future<void> cacheDesigns(String tailorId, List<DesignItem> designs) async {
    _designs[tailorId] = List.from(designs);
  }

  @override
  Future<List<DesignItem>> getCachedDesigns(String tailorId) async {
    return _designs[tailorId] ?? [];
  }

  @override
  Future<void> cacheCategories(List<CategoryItem> categories) async {
    _categories = List.from(categories);
  }

  @override
  Future<List<CategoryItem>> getCachedCategories() async {
    return List.from(_categories);
  }

  @override
  Future<void> enqueueUpload(QueuedUploadItem item) async {
    _queue.add(item);
  }

  @override
  Future<List<QueuedUploadItem>> getPendingUploads() async {
    return List.from(_queue);
  }

  @override
  Future<void> removePendingUpload(String id) async {
    _queue.removeWhere((i) => i.id == id);
  }
}

class SharedPreferencesOfflineStorage implements OfflineStorage {
  static const _designsPrefix = 'cached_designs_';
  static const _categoriesKey = 'cached_categories';
  static const _queueKey = 'pending_upload_queue';

  @override
  Future<void> cacheDesigns(String tailorId, List<DesignItem> designs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = designs.map((d) => {
          'id': d.id,
          'tailor_id': d.tailorId,
          'category_id': d.categoryId,
          'price': d.price,
          'tag': d.tag,
          'is_grouped': d.isGrouped,
          'category_name': d.categoryName,
          'created_at': d.createdAt?.toIso8601String(),
          'design_photos': d.photos
              .map((p) => {
                    'id': p.id,
                    'design_id': p.designId,
                    'cloudinary_public_id': p.cloudinaryPublicId,
                    'cloudinary_url': p.cloudinaryUrl,
                    'order_index': p.orderIndex,
                  })
              .toList(),
        }).toList();
    await prefs.setString('$_designsPrefix$tailorId', jsonEncode(jsonList));
  }

  @override
  Future<List<DesignItem>> getCachedDesigns(String tailorId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_designsPrefix$tailorId');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        final rawPhotos = map['design_photos'] as List<dynamic>? ?? [];
        final photos = rawPhotos
            .map((p) => DesignPhotoItem.fromJson(p as Map<String, dynamic>))
            .toList();
        return DesignItem(
          id: map['id'] as String,
          tailorId: map['tailor_id'] as String,
          categoryId: map['category_id'] as String,
          price: (map['price'] as num?)?.toDouble() ?? 0.0,
          tag: map['tag'] as String?,
          isGrouped: map['is_grouped'] as bool? ?? false,
          categoryName: map['category_name'] as String?,
          photos: photos,
          createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheCategories(List<CategoryItem> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final list = categories.map((c) => {
          'id': c.id,
          'name_en': c.nameEn,
          'name_am': c.nameAm,
          'name_om': c.nameOm,
          'name_so': c.nameSo,
          'sort_order': c.sortOrder,
        }).toList();
    await prefs.setString(_categoriesKey, jsonEncode(list));
  }

  @override
  Future<List<CategoryItem>> getCachedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_categoriesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((c) => CategoryItem.fromJson(c as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> enqueueUpload(QueuedUploadItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getPendingUploads();
    current.add(item);
    final jsonList = current.map((i) => i.toJson()).toList();
    await prefs.setString(_queueKey, jsonEncode(jsonList));
  }

  @override
  Future<List<QueuedUploadItem>> getPendingUploads() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((i) => QueuedUploadItem.fromJson(i as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> removePendingUpload(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getPendingUploads();
    current.removeWhere((i) => i.id == id);
    final jsonList = current.map((i) => i.toJson()).toList();
    await prefs.setString(_queueKey, jsonEncode(jsonList));
  }
}
