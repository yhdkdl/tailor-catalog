import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../auth/auth_repository.dart';
import 'design_repository.dart';
import 'models.dart';

class _NewPhotoItem {
  const _NewPhotoItem({
    required this.bytes,
    required this.name,
  });

  final Uint8List bytes;
  final String name;
}

class EditDesignScreen extends StatefulWidget {
  const EditDesignScreen({
    required this.design,
    required this.profile,
    required this.designRepository,
    required this.authUid,
    super.key,
  });

  final DesignItem design;
  final TailorProfile profile;
  final DesignRepository designRepository;
  final String authUid;

  @override
  State<EditDesignScreen> createState() => _EditDesignScreenState();
}

class _EditDesignScreenState extends State<EditDesignScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tagController;
  final _imagePicker = ImagePicker();

  late String _selectedCategoryId;
  List<CategoryItem> _categories = [];
  bool _loadingCategories = true;
  bool _saving = false;
  String? _progressMessage;
  String? _errorMessage;

  late List<DesignPhotoItem> _existingPhotos;
  final List<String> _deletedPhotoIds = [];
  final List<String> _deletedCloudinaryPublicIds = [];
  final List<_NewPhotoItem> _newPhotos = [];

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(
      text: widget.design.tag ?? '',
    );
    _selectedCategoryId = widget.design.categoryId;
    _existingPhotos = List<DesignPhotoItem>.from(widget.design.photos);
    _loadCategories();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await widget.designRepository.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          // Ensure selected category is valid
          if (!_categories.any((c) => c.id == _selectedCategoryId) && _categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
          _loadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingCategories = false;
          _errorMessage = 'Failed to load categories: $e';
        });
      }
    }
  }

  void _removeExistingPhoto(int index) {
    if (_existingPhotos.length + _newPhotos.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A design must have at least one photo.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      final photo = _existingPhotos.removeAt(index);
      if (photo.id.isNotEmpty) {
        _deletedPhotoIds.add(photo.id);
      }
      if (photo.cloudinaryPublicId.isNotEmpty) {
        _deletedCloudinaryPublicIds.add(photo.cloudinaryPublicId);
      }
    });
  }

  void _removeNewPhoto(int index) {
    if (_existingPhotos.length + _newPhotos.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A design must have at least one photo.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      _newPhotos.removeAt(index);
    });
  }

  Future<void> _pickFromCamera() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _newPhotos.add(_NewPhotoItem(bytes: bytes, name: file.name));
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera capture failed: $e';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final files = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (files.isNotEmpty) {
        final items = <_NewPhotoItem>[];
        for (final f in files) {
          final bytes = await f.readAsBytes();
          items.add(_NewPhotoItem(bytes: bytes, name: f.name));
        }
        setState(() {
          _newPhotos.addAll(items);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gallery selection failed: $e';
      });
    }
  }

  void _showAddPhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.brand),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.brand),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final totalPhotos = _existingPhotos.length + _newPhotos.length;
    if (totalPhotos == 0) {
      setState(() {
        _errorMessage = 'Please provide at least one photo for this design.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
      _progressMessage = 'Saving design changes...';
    });

    try {
      final updatedDesign = await widget.designRepository.updateDesign(
        designId: widget.design.id,
        categoryId: _selectedCategoryId,
        price: 0,
        tag: _tagController.text.trim().isNotEmpty ? _tagController.text.trim() : null,
        existingPhotosToKeep: _existingPhotos,
        newImageBytesList: _newPhotos.map((p) => p.bytes).toList(),
        newFilenames: _newPhotos.map((p) => p.name).toList(),
        deletedPhotoIds: _deletedPhotoIds,
        deletedCloudinaryPublicIds: _deletedCloudinaryPublicIds,
        authUid: widget.authUid,
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              _progressMessage = 'Uploading new photo $current of $total...';
            });
          }
        },
      );

      if (mounted) {
        Navigator.of(context).pop(updatedDesign);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPhotosCount = _existingPhotos.length + _newPhotos.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Design', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Format Badge (read-only indicator)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.design.isGrouped
                              ? Icons.collections_outlined
                              : Icons.photo_outlined,
                          size: 20,
                          color: AppColors.brand,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.design.isGrouped
                                    ? 'Grouped Carousel ($totalPhotosCount photos)'
                                    : 'Single Photo Design',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Design format is fixed and cannot be changed.',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category Dropdown
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    dropdownColor: AppColors.surface,
                    items: _categories.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.localizedName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategoryId = val);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // Tag Field
                  const Text('Tag / Title (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Habesha Kemis, Wedding Silk',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Photos Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Design Photos ($totalPhotosCount)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      TextButton.icon(
                        onPressed: _saving ? null : _showAddPhotoSheet,
                        icon: const Icon(Icons.add_photo_alternate_outlined, size: 18, color: AppColors.brand),
                        label: const Text('Add Photos', style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Photos Grid
                  if (totalPhotosCount == 0)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Center(
                        child: Text(
                          'No photos. Please add at least one photo.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _existingPhotos.length + _newPhotos.length,
                      itemBuilder: (context, index) {
                        if (index < _existingPhotos.length) {
                          // Existing photo from server
                          final photo = _existingPhotos[index];
                          final url = photo.thumbnailOptimizedUrl.isNotEmpty
                              ? photo.thumbnailOptimizedUrl
                              : photo.cloudinaryUrl;

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12),
                                  color: Colors.black26,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  placeholder: (ctx, url) => Container(
                                    color: Colors.black26,
                                    child: const Icon(Icons.image_outlined, color: Colors.white24),
                                  ),
                                  errorWidget: (ctx, url, err) => const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeExistingPhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                                  ),
                                ),
                              ),
                              if (index == 0)
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.brand,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Cover',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        } else {
                          // Newly added local photo
                          final newIndex = index - _existingPhotos.length;
                          final newPhoto = _newPhotos[newIndex];

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.brand.withValues(alpha: 0.5)),
                                  color: Colors.black26,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.memory(
                                  newPhoto.bytes,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeNewPhoto(newIndex),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade800,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'New',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),

                  const SizedBox(height: 24),

                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Progress message
                  if (_progressMessage != null) ...[
                    Text(
                      _progressMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.brand, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Save Button
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _saving ? null : _saveChanges,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
