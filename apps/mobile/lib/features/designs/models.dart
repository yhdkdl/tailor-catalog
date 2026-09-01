import '../../core/config/app_config.dart';

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.nameEn,
    required this.nameAm,
    required this.nameOm,
    required this.nameSo,
    this.sortOrder = 0,
  });

  final String id;
  final String nameEn;
  final String nameAm;
  final String nameOm;
  final String nameSo;
  final int sortOrder;

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String,
      nameEn: json['name_en'] as String? ?? '',
      nameAm: json['name_am'] as String? ?? '',
      nameOm: json['name_om'] as String? ?? '',
      nameSo: json['name_so'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  String get localizedName => nameEn.isNotEmpty ? nameEn : nameAm;
}

class DesignPhotoItem {
  const DesignPhotoItem({
    required this.id,
    required this.designId,
    required this.cloudinaryPublicId,
    required this.cloudinaryUrl,
    this.orderIndex = 0,
  });

  final String id;
  final String designId;
  final String cloudinaryPublicId;
  final String cloudinaryUrl;
  final int orderIndex;

  factory DesignPhotoItem.fromJson(Map<String, dynamic> json) {
    return DesignPhotoItem(
      id: json['id'] as String? ?? '',
      designId: json['design_id'] as String? ?? '',
      cloudinaryPublicId: json['cloudinary_public_id'] as String? ?? '',
      cloudinaryUrl: json['cloudinary_url'] as String? ?? '',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
    );
  }

  String get thumbnailOptimizedUrl =>
      CloudinaryUrlHelper.buildUrl(cloudinaryPublicId, width: 400, height: 400);

  String get catalogOptimizedUrl =>
      CloudinaryUrlHelper.buildUrl(cloudinaryPublicId, width: 800);
}

class DesignItem {
  const DesignItem({
    required this.id,
    required this.tailorId,
    required this.categoryId,
    required this.price,
    this.tag,
    this.isGrouped = false,
    this.photos = const [],
    this.categoryName,
    this.createdAt,
  });

  final String id;
  final String tailorId;
  final String categoryId;
  final double price;
  final String? tag;
  final bool isGrouped;
  final List<DesignPhotoItem> photos;
  final String? categoryName;
  final DateTime? createdAt;

  factory DesignItem.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['design_photos'] as List<dynamic>? ?? [];
    final photosList = rawPhotos
        .map((p) => DesignPhotoItem.fromJson(p as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final rawCategory = json['categories'] as Map<String, dynamic>?;
    final catName = rawCategory != null ? (rawCategory['name_en'] as String? ?? '') : null;

    return DesignItem(
      id: json['id'] as String,
      tailorId: json['tailor_id'] as String,
      categoryId: json['category_id'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      tag: json['tag'] as String?,
      isGrouped: json['is_grouped'] as bool? ?? false,
      photos: photosList,
      categoryName: catName,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}

class CloudinaryUrlHelper {
  static String buildUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    if (publicId.isEmpty) return '';
    final cloudName = AppConfig.cloudinaryCloudName;
    if (cloudName.isEmpty) return '';

    final transforms = <String>[
      'q_$quality',
      'f_$format',
      if (width != null) 'w_$width',
      if (height != null) 'h_$height',
      'c_limit',
    ].join(',');

    return 'https://res.cloudinary.com/$cloudName/image/upload/$transforms/$publicId';
  }
}
