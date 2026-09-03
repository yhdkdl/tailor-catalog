import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../auth/auth_repository.dart';
import '../designs/design_repository.dart';
import '../designs/models.dart';
import 'photo_preview_screen.dart';

class SingleDesignUploadScreen extends StatefulWidget {
  const SingleDesignUploadScreen({
    required this.tailorProfile,
    required this.designRepository,
    required this.authUid,
    super.key,
  });

  final TailorProfile tailorProfile;
  final DesignRepository designRepository;
  final String authUid;

  @override
  State<SingleDesignUploadScreen> createState() =>
      _SingleDesignUploadScreenState();
}

class _SingleDesignUploadScreenState extends State<SingleDesignUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  final _imagePicker = ImagePicker();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _selectedCategoryId;
  List<CategoryItem> _categories = [];
  bool _loadingCategories = true;
  bool _uploading = false;
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        if (source == ImageSource.camera) {
          final accepted = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => PhotoPreviewScreen(bytes: bytes, counter: null),
            ),
          );
          if (accepted != true) {
            await _pickImage(ImageSource.camera);
            return;
          }
        }
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = file.name;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not select photo: $e';
      });
    }
  }

  void _showImageSourceDialog() {
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
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.brand,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.brand,
              ),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedImageBytes == null) {
      setState(() => _errorMessage = 'Please select a design photo.');
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
      _errorMessage = null;
    });

    try {
      final created = await widget.designRepository.createSingleDesign(
        tailorId: widget.tailorProfile.id,
        categoryId: _selectedCategoryId!,
        price: 0,
        tag: _tagController.text.trim().isNotEmpty
            ? _tagController.text.trim()
            : null,
        imageBytes: _selectedImageBytes!,
        filename:
            _selectedImageName ??
            'design_${DateTime.now().millisecondsSinceEpoch}.jpg',
        authUid: widget.authUid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Design uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(created);
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
      appBar: AppBar(title: const Text('Upload Design')),
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
                      // Photo picker preview container
                      GestureDetector(
                        onTap: _uploading ? null : _showImageSourceDialog,
                        child: Container(
                          height: 240,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedImageBytes != null
                                  ? AppColors.brand
                                  : Colors.white12,
                              width: 1.5,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _selectedImageBytes != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.memory(
                                      _selectedImageBytes!,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black54,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: _uploading
                                              ? null
                                              : _showImageSourceDialog,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.brand.withValues(
                                          alpha: 0.15,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 36,
                                        color: AppColors.brand,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Tap to select design photo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'JPEG or PNG up to 10MB',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
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

                      // Optional Tag field
                      TextFormField(
                        key: const Key('tag_field'),
                        controller: _tagController,
                        enabled: !_uploading,
                        decoration: const InputDecoration(
                          labelText: 'Optional Tag / Accent',
                          hintText: 'e.g. Silk Neckline, Wedding, Men Velvet',
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
                      const SizedBox(height: 28),

                      // Submit button
                      FilledButton(
                        key: const Key('publish_design_btn'),
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
                                  Text('Uploading to Catalog...'),
                                ],
                              )
                            : const Text(
                                'Publish Design',
                                style: TextStyle(
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
