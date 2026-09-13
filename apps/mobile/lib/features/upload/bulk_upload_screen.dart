import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_repository.dart';
import '../designs/design_repository.dart';
import '../designs/models.dart';
import 'photo_preview_screen.dart';

enum BulkUploadMode { individual, grouped }

class _PickedImageItem {
  const _PickedImageItem({
    required this.bytes,
    required this.name,
  });

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
    final l10n = AppLocalizations.of(context);
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
          _errorMessage = '${l10n.failedToLoadCategories}: $e';
        });
      }
    }
  }

  Future<void> _pickMultiImages() async {
    final l10n = AppLocalizations.of(context);
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
        _errorMessage = '${l10n.couldNotSelectPhotos}: $e';
      });
    }
  }

  Future<void> _pickCameraImage() async {
    final l10n = AppLocalizations.of(context);
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
            counter: '${l10n.takePhoto} ${_pickedImages.length + 1}',
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
      if (mounted) setState(() => _errorMessage = '${l10n.cameraCaptureFailed}: $e');
    }
  }

  void _showAddPhotoOptions() {
    final l10n = AppLocalizations.of(context);
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
              title: Text(l10n.chooseFromGallery),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickMultiImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.brand),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickCameraImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewTile(int index) {
    final l10n = AppLocalizations.of(context);
    final image = _pickedImages[index];
    return SizedBox(
      key: ValueKey('${image.name}-$index'),
      width: 100,
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                image.bytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: _uploading ? null : () => _removeImage(index),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          if (_mode == BulkUploadMode.grouped)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: index == 0 ? AppColors.brand : Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  index == 0 ? l10n.cover : '#${index + 1}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: index == 0 ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _addMoreTile() {
    return SizedBox(
      width: 100,
      height: 120,
      child: InkWell(
        onTap: _uploading ? null : _showAddPhotoOptions,
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

  void _removeImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (_pickedImages.isEmpty) {
      setState(() => _errorMessage = l10n.selectAtLeastOnePhoto);
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _errorMessage = l10n.selectCategoryRequired);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _uploading = true;
      _uploadProgress = 0.0;
      _progressMessage = l10n.preparingPhotos(_pickedImages.length);
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
                _progressMessage = l10n.uploadedPhotoProgress(
                  current,
                  total,
                  (_uploadProgress * 100).toInt(),
                );
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
                _progressMessage = l10n.uploadedDesignProgress(
                  current,
                  total,
                  (_uploadProgress * 100).toInt(),
                );
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
                  ? l10n.multiPhotoSuccess
                  : l10n.individualDesignsSuccess(_pickedImages.length),
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
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bulkUploadTitle)),
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
                                l10n.selectedPhotosCount(_pickedImages.length),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton.icon(
                                key: const Key('add_photos_btn'),
                                onPressed: _uploading
                                    ? null
                                    : _showAddPhotoOptions,
                                icon: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 18,
                                ),
                                label: Text(l10n.addPhotos),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_pickedImages.isEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Primary: direct gallery multi-select
                                FilledButton.icon(
                                  onPressed: _uploading ? null : _pickMultiImages,
                                  icon: const Icon(Icons.photo_library_outlined),
                                  label: Text(
                                    l10n.selectPhotosFromGallery,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Secondary: camera
                                OutlinedButton.icon(
                                  onPressed: _uploading ? null : _pickCameraImage,
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: Text(l10n.takePhotoWithCamera),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    side: const BorderSide(color: Colors.white24),
                                  ),
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
                                      _addMoreTile(),
                                    ],
                                  )
                                : SizedBox(
                                    height: 120,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _pickedImages.length + 1,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 10),
                                      itemBuilder: (ctx, idx) {
                                        if (idx == _pickedImages.length) {
                                          return _addMoreTile();
                                        }
                                        return Stack(
                                          children: [
                                            _reviewTile(idx),
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
                      Text(
                        l10n.uploadStructure,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ModeOptionCard(
                              title: l10n.separateCards,
                              description: l10n.separateCardsDescription,
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
                              title: l10n.groupedCarousel,
                              description: l10n.groupedCarouselDescription,
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
                        decoration: InputDecoration(
                          labelText: '${l10n.category} *',
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.nameForLocale(langCode)),
                          );
                        }).toList(),
                        onChanged: _uploading
                            ? null
                            : (val) {
                                setState(() => _selectedCategoryId = val);
                              },
                        validator: (v) =>
                            v == null ? l10n.selectCategoryRequired : null,
                      ),
                      const SizedBox(height: 16),

                      // Optional Tag input
                      TextFormField(
                        key: const Key('bulk_tag_field'),
                        controller: _tagController,
                        enabled: !_uploading,
                        decoration: InputDecoration(
                          labelText: l10n.bulkTagLabel,
                          hintText: l10n.bulkTagHint,
                          prefixIcon: const Icon(Icons.tag_outlined),
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
                              _progressMessage ?? l10n.uploadingPhotos,
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
                        onPressed: _uploading ? null : () => _submit(l10n),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _uploading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(l10n.publishingToCatalog),
                                ],
                              )
                            : Text(
                                _mode == BulkUploadMode.grouped
                                    ? l10n.publishMultiPhotoDesign
                                    : l10n.publishBulkDesigns(_pickedImages.length),
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
