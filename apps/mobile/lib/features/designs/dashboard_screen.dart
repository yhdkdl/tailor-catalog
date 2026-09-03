import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../auth/auth_repository.dart';
import '../offline/offline_service.dart';
import '../offline/offline_sync_manager.dart';
import '../qr/qr_screen.dart';
import '../upload/bulk_upload_screen.dart';
import '../upload/single_upload_screen.dart';
import 'design_repository.dart';
import 'edit_design_screen.dart';
import 'models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.profile,
    required this.designRepository,
    this.syncManager,
    required this.onSignOut,
    super.key,
  });

  final TailorProfile profile;
  final DesignRepository designRepository;
  final OfflineSyncManager? syncManager;
  final Future<void> Function() onSignOut;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final OfflineSyncManager _syncManager;
  List<DesignItem> _designs = [];
  List<QueuedUploadItem> _pendingQueue = [];
  bool _loading = true;
  bool _isSyncing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _syncManager = widget.syncManager ??
        OfflineSyncManager(designRepository: widget.designRepository);
    _loadDesigns();
  }

  @override
  void dispose() {
    if (widget.syncManager == null) {
      _syncManager.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDesigns() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await _syncManager.getTailorDesigns(widget.profile.id);
      final queue = await _syncManager.getPendingUploads();
      if (mounted) {
        setState(() {
          _designs = list;
          _pendingQueue = queue;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _syncPendingUploads() async {
    setState(() => _isSyncing = true);
    final res = await _syncManager.processQueue();
    if (mounted) {
      setState(() => _isSyncing = false);
      if (res.succeededCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully synced ${res.succeededCount} queued design(s)!'), backgroundColor: Colors.green),
        );
      }
      _loadDesigns();
    }
  }

  Future<void> _deleteDesign(DesignItem design) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Design'),
        content: const Text('Are you sure you want to remove this design from your catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.designRepository.deleteDesign(design.id);
        setState(() {
          _designs.removeWhere((d) => d.id == design.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Design removed')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete design: $e')),
          );
        }
      }
    }
  }

  Future<void> _editDesign(DesignItem design) async {
    final updated = await Navigator.of(context).push<DesignItem>(
      MaterialPageRoute(
        builder: (_) => EditDesignScreen(
          design: design,
          profile: widget.profile,
          designRepository: widget.designRepository,
          authUid: widget.profile.authId,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        final index = _designs.indexWhere((d) => d.id == updated.id);
        if (index != -1) {
          _designs[index] = updated;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Design updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showUploadOptions() {
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
              leading: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.brand),
              title: const Text('Single Photo Design', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Upload one photo with category'),
              onTap: () {
                Navigator.of(ctx).pop();
                _navigateToSingleUpload();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.brand),
              title: const Text('Bulk & Multi-Photo Upload', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Upload multiple photos or a grouped carousel'),
              onTap: () {
                Navigator.of(ctx).pop();
                _navigateToBulkUpload();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToSingleUpload() async {
    final created = await Navigator.of(context).push<DesignItem>(
      MaterialPageRoute(
        builder: (_) => SingleDesignUploadScreen(
          tailorProfile: widget.profile,
          designRepository: widget.designRepository,
          authUid: widget.profile.authId,
        ),
      ),
    );

    if (created != null) {
      _loadDesigns();
    }
  }

  Future<void> _navigateToBulkUpload() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BulkUploadScreen(
          tailorProfile: widget.profile,
          designRepository: widget.designRepository,
          authUid: widget.profile.authId,
        ),
      ),
    );

    if (result == true) {
      _loadDesigns();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.profile.shopName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'Approved',
                      style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('qr_icon_btn'),
            icon: const Icon(Icons.qr_code_2_outlined),
            tooltip: 'Store QR Code',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QrScreen(profile: widget.profile),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: widget.onSignOut,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDesigns,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('upload_fab'),
        onPressed: _showUploadOptions,
        backgroundColor: AppColors.brand,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Upload Design', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        if (_pendingQueue.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.amber.shade900.withValues(alpha: 0.25),
            child: Row(
              children: [
                const Icon(Icons.cloud_queue, size: 20, color: Colors.amberAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_pendingQueue.length} upload(s) pending in offline queue.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amberAccent),
                  ),
                ),
                _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amberAccent),
                      )
                    : TextButton(
                        onPressed: _syncPendingUploads,
                        child: const Text('Sync now', style: TextStyle(fontSize: 12, color: Colors.amberAccent)),
                      ),
              ],
            ),
          ),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadDesigns,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_designs.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.checkroom_outlined, size: 56, color: AppColors.brand),
              ),
              const SizedBox(height: 20),
              Text('Your catalog is empty', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'Upload photos of your tailoring work with categories to showcase them to customers.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _showUploadOptions,
                icon: const Icon(Icons.add),
                label: const Text('Upload First Design'),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _designs.length,
      itemBuilder: (context, index) {
        final design = _designs[index];
        return _DesignCard(
          design: design,
          onEdit: () => _editDesign(design),
          onDelete: () => _deleteDesign(design),
        );
      },
    );
  }
}

class _DesignCard extends StatelessWidget {
  const _DesignCard({
    required this.design,
    required this.onEdit,
    required this.onDelete,
  });

  final DesignItem design;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final photo = design.photos.isNotEmpty ? design.photos.first : null;
    final imageUrl = photo != null
        ? (photo.thumbnailOptimizedUrl.isNotEmpty ? photo.thumbnailOptimizedUrl : photo.cloudinaryUrl)
        : '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview container
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        key: ValueKey(imageUrl),
                        imageUrl: imageUrl,
                        cacheKey: imageUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        placeholder: (ctx, url) => Container(
                          color: Colors.black26,
                          child: const Icon(Icons.image_outlined, color: Colors.white24),
                        ),
                        errorWidget: (ctx, url, err) => const Center(
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.black26,
                        child: const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                // Multi-photo indicator badge
                if (design.photos.length > 1)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.collections_outlined, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${design.photos.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Edit button
                Positioned(
                  top: 6,
                  right: 40,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      key: Key('edit_design_btn_${design.id}'),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.brand),
                      tooltip: 'Edit Design',
                      onPressed: onEdit,
                    ),
                  ),
                ),
                // Delete button
                Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                      onPressed: onDelete,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (design.categoryName != null && design.categoryName!.isNotEmpty)
                  Text(
                    design.categoryName!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (design.tag != null && design.tag!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${design.tag}',
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
