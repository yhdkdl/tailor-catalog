import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/errors/error_utils.dart';
import '../../core/l10n/app_localizations.dart';
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
      final cats = await widget.designRepository.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingCategories = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      final confirmed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PhotoPreviewScreen(
            bytes: bytes,
            counter: null,
          ),
        ),
      );

      if (confirmed == true && mounted) {
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = picked.name;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = l10n.couldNotReadPhoto);
      }
    }
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.brand,
                ),
                title: Text(l10n.chooseFromGallery),
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
                title: Text(l10n.takePhoto),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
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

  Future<void> _submit(AppLocalizations l10n) async {
    if (_selectedImageBytes == null) {
      setState(() => _errorMessage = l10n.selectPhotoRequired);
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
          SnackBar(
            content: Text(l10n.designUploadedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(created);
      }
    } catch (e, stackTrace) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final friendly = ErrorUtils.getFriendlyErrorMessage(
          e,
          stackTrace: stackTrace,
          contextTag: 'SINGLE_UPLOAD',
          l10n: l10n,
        );
        setState(() {
          _errorMessage = friendly;
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
      appBar: AppBar(title: Text(l10n.uploadDesign)),
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
                              : Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      _sourceOption(
                                        icon: Icons.camera_alt_outlined,
                                        label: l10n.takePhoto,
                                        onTap: () =>
                                            _pickImage(ImageSource.camera),
                                      ),
                                      const SizedBox(width: 16),
                                      _sourceOption(
                                        icon: Icons.photo_library_outlined,
                                        label: l10n.chooseFromGallery,
                                        onTap: () =>
                                            _pickImage(ImageSource.gallery),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
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

                      // Optional Tag field
                      TextFormField(
                        key: const Key('tag_field'),
                        controller: _tagController,
                        enabled: !_uploading,
                        decoration: InputDecoration(
                          labelText: l10n.optionalTagLabel,
                          hintText: l10n.tagHint,
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
                      const SizedBox(height: 28),

                      // Submit button
                      FilledButton(
                        key: const Key('publish_design_btn'),
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
                                  Text(l10n.uploadingToCatalog),
                                ],
                              )
                            : Text(
                                l10n.publishDesign,
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
