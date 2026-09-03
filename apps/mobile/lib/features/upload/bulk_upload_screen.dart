import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../auth/auth_repository.dart';
import '../designs/design_repository.dart';
import '../designs/models.dart';
import 'photo_preview_screen.dart';

import 'package:reorderables/reorderables.dart';

enum BulkUploadMode { individual, grouped }

class _PickedImageItem {
  const _PickedImageItem({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;
}

class BulkUploadScreen extends StatefulWidget {
  const BulkUploadScreen({
    required this.tailorProfile,
    required this.designRepository,
    required this.authUid,
    super.key,
  });

  final TailorProfile tailorProfile;
  final DesignRepository designRepository;
  final String authUid;

  @override
  State<BulkUploadScreen> createState() => _BulkUploadScreenState();
}

class _BulkUploadScreenState extends State<BulkUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  final _imagePicker = ImagePicker();

  final List<_PickedImageItem> _pickedImages = [];
  BulkUploadMode _mode = BulkUploadMode.individual;
  String? _selectedCategoryId;
  List<CategoryItem> _categories = [];
  bool _loadingCategories = true;
  bool _uploading = false;
  double _uploadProgress = 0.0;
  String? _progressMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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
          if (categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
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

  Future<void> _pickMultiImages() async {
    try {
      final files = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (files.isNotEmpty) {
        final newItems = <_PickedImageItem>[];
        for (final f in files) {
          final bytes = await f.readAsBytes();
          newItems.add(_PickedImageItem(bytes: bytes, name: f.name));
        }
        setState(() {
          _pickedImages.addAll(newItems);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not select photos: $e';
      });
    }
  }

  Future<void> _pickCameraImage() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final accepted = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PhotoPreviewScreen(
            bytes: bytes,
            counter: 'Photo ${_pickedImages.length + 1}',
          ),
        ),
      );
      if (!mounted) return;
      if (accepted != true) {
        await _pickCameraImage();
      } else if (mounted) {
        setState(
          () => _pickedImages.add(
            _PickedImageItem(bytes: bytes, name: file.name),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Camera capture failed: $e');
    }
  }

  Widget _reviewTile(int index) {
    final image = _pickedImages[index];
    return SizedBox(
      key: ValueKey('${image.name}-$index'),
      width: 100,
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(image.bytes, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: _uploading ? null : () => _removeImage(index),
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black87,
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              color: Colors.black54,
              child: Text(
                '#${index + 1}',
                style: const TextStyle(fontSize: 9, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addPhotoTile() {
    return SizedBox(
      key: const ValueKey('add-photo'),
      width: 100,
      height: 120,
      child: GestureDetector(
        onTap: _uploading ? null : _showPhotoSourceSheet,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: const Icon(Icons.add, color: AppColors.brand, size: 30),
        ),
      ),
    );
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickCameraImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickMultiImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: _uploading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppColors.brand),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_pickedImages.isEmpty) {
      setState(() => _errorMessage = 'Please select at least one photo.');
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _errorMessage = 'Please choose a category.');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _uploading = true;
      _uploadProgress = 0.0;
      _progressMessage = 'Preparing ${_pickedImages.length} photos...';
      _errorMessage = null;
    });

    try {
      final bytesList = _pickedImages.map((i) => i.bytes).toList();
      final nameList = _pickedImages.map((i) => i.name).toList();

      if (_mode == BulkUploadMode.grouped) {
        await widget.designRepository.createGroupedDesign(
          tailorId: widget.tailorProfile.id,
          categoryId: _selectedCategoryId!,
          price: 0,
          tag: _tagController.text.trim().isNotEmpty
              ? _tagController.text.trim()
              : null,
          imageBytesList: bytesList,
          filenames: nameList,
          authUid: widget.authUid,
          onProgress: (current, total) {
            if (mounted) {
              setState(() {
                _uploadProgress = current / total;
                _progressMessage =
                    'Uploaded photo $current of $total (${(_uploadProgress * 100).toInt()}%)';
              });
            }
          },
        );
      } else {
        await widget.designRepository.createBulkIndividualDesigns(
          tailorId: widget.tailorProfile.id,
          categoryId: _selectedCategoryId!,
          price: 0,
          tag: _tagController.text.trim().isNotEmpty
              ? _tagController.text.trim()
              : null,
          imageBytesList: bytesList,
          filenames: nameList,
          authUid: widget.authUid,
          onProgress: (current, total) {
            if (mounted) {
              setState(() {
                _uploadProgress = current / total;
                _progressMessage =
                    'Uploaded design $current of $total (${(_uploadProgress * 100).toInt()}%)';
              });
            }
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _mode == BulkUploadMode.grouped
                  ? 'Multi-photo design created successfully!'
                  : '${_pickedImages.length} individual designs created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk & Multi-Photo Upload')),
      body: SafeArea(
        child: _loadingCategories
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Photo selection section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Selected Photos (${_pickedImages.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton.icon(
                                key: const Key('add_photos_btn'),
                                onPressed: _uploading
                                    ? null
                                    : _showPhotoSourceSheet,
                                icon: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 18,
                                ),
                                label: const Text('Add Photos'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_pickedImages.isEmpty)
                            Row(
                              children: [
                                _sourceOption(
                                  icon: Icons.camera_alt_outlined,
                                  label: 'Take Photo',
                                  onTap: _pickCameraImage,
                                ),
                                const SizedBox(width: 12),
                                _sourceOption(
                                  icon: Icons.photo_library_outlined,
                                  label: 'Choose from Gallery',
                                  onTap: _pickMultiImages,
                                ),
                              ],
                            )
                          else
                            _mode == BulkUploadMode.grouped
                                ? ReorderableWrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    needsLongPressDraggable: true,
                                    onReorder: (oldIndex, newIndex) =>
                                        setState(() {
                                          final item = _pickedImages.removeAt(
                                            oldIndex,
                                          );
                                          _pickedImages.insert(newIndex, item);
                                        }),
                                    children: [
                                      for (
                                        var idx = 0;
                                        idx < _pickedImages.length;
                                        idx++
                                      )
                                        _reviewTile(idx),
                                      _addPhotoTile(),
                                    ],
                                  )
                                : SizedBox(
                                    height: 120,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _pickedImages.length + 1,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 10),
                                      itemBuilder: (context, idx) {
                                        if (idx == _pickedImages.length) {
                                          return GestureDetector(
                                            onTap: _uploading
                                                ? null
                                                : _showPhotoSourceSheet,
                                            child: Container(
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white12,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                color: AppColors.brand,
                                                size: 30,
                                              ),
                                            ),
                                          );
                                        }

                                        final img = _pickedImages[idx];
                                        return Stack(
                                          children: [
                                            Container(
                                              width: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white24,
                                                ),
                                                image: DecorationImage(
                                                  image: MemoryImage(img.bytes),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: _uploading
                                                    ? null
                                                    : () => _removeImage(idx),
                                                child: const CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      Colors.black87,
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              left: 4,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '#${idx + 1}',
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Mode Selector
                      const Text(
                        'Upload Structure',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ModeOptionCard(
                              title: 'Separate Cards',
                              description:
                                  'Each photo is its own individual design',
                              icon: Icons.grid_view_rounded,
                              selected: _mode == BulkUploadMode.individual,
                              onTap: _uploading
                                  ? null
                                  : () => setState(
                                      () => _mode = BulkUploadMode.individual,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModeOptionCard(
                              title: 'Grouped Carousel',
                              description: 'All photos in one swipeable design',
                              icon: Icons.view_carousel_rounded,
                              selected: _mode == BulkUploadMode.grouped,
                              onTap: _uploading
                                  ? null
                                  : () => setState(
                                      () => _mode = BulkUploadMode.grouped,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.localizedName),
                          );
                        }).toList(),
                        onChanged: _uploading
                            ? null
                            : (val) {
                                setState(() => _selectedCategoryId = val);
                              },
                        validator: (v) =>
                            v == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 16),

                      // Optional Tag input
                      TextFormField(
                        key: const Key('bulk_tag_field'),
                        controller: _tagController,
                        enabled: !_uploading,
                        decoration: const InputDecoration(
                          labelText: 'Optional Tag / Label',
                          hintText: 'e.g. Habesha Silk, Men Collection 2026',
                          prefixIcon: Icon(Icons.tag_outlined),
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (_uploading) ...[
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _uploadProgress > 0
                                    ? _uploadProgress
                                    : null,
                                minHeight: 8,
                                backgroundColor: Colors.white12,
                                color: AppColors.brand,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _progressMessage ?? 'Uploading photos...',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 28),

                      // Submit button
                      FilledButton(
                        key: const Key('publish_bulk_btn'),
                        onPressed: _uploading ? null : _submit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _uploading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Publishing to Catalog...'),
                                ],
                              )
                            : Text(
                                _mode == BulkUploadMode.grouped
                                    ? 'Publish Multi-Photo Design'
                                    : 'Publish ${_pickedImages.length} Designs',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _ModeOptionCard extends StatelessWidget {
  const _ModeOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brand.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.brand : Colors.white12,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.brand : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: selected ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
