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

/// Global RouteObserver — register this in MaterialApp.navigatorObservers
/// so DashboardScreen can detect when it becomes active again after a pop.
final RouteObserver<ModalRoute<void>> dashboardRouteObserver =
    RouteObserver<ModalRoute<void>>();

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

class _DashboardScreenState extends State<DashboardScreen>
    with RouteAware {
  late final OfflineSyncManager _syncManager;
  List<DesignItem> _designs = [];
  List<QueuedUploadItem> _pendingQueue = [];
  bool _loading = true;
  bool _isSyncing = false;
  String? _error;

  // Multi-selection state for batch deletion
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  bool _isDeletingBatch = false;

  @override
  void initState() {
    super.initState();
    _syncManager = widget.syncManager ??
        OfflineSyncManager(designRepository: widget.designRepository);
    _loadDesigns();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the route observer so didPopNext fires when we come back.
    final route = ModalRoute.of(context);
    if (route is ModalRoute<void>) {
      dashboardRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    dashboardRouteObserver.unsubscribe(this);
    if (widget.syncManager == null) {
      _syncManager.dispose();
    }
    super.dispose();
  }

  /// Called when a sub-route is popped and this screen becomes visible again.
  @override
  void didPopNext() {
    // Keep designs active without unmounting the grid
  }

  Future<void> _loadDesigns({bool showSpinner = false}) async {
    if (showSpinner || _designs.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final list = await _syncManager.getTailorDesigns(widget.profile.id);
      final queue = await _syncManager.getPendingUploads();
      if (mounted) {
        setState(() {
          _designs = list;
          _pendingQueue = queue;
          _loading = false;
          // Clean up any selected ids no longer in the list
          _selectedIds.retainWhere((id) => list.any((d) => d.id == id));
          if (_designs.isEmpty) {
            _isSelectionMode = false;
          }
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

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleItemSelection(String designId) {
    setState(() {
      if (_selectedIds.contains(designId)) {
        _selectedIds.remove(designId);
      } else {
        _selectedIds.add(designId);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _designs.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.clear();
        _selectedIds.addAll(_designs.map((d) => d.id));
      }
    });
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
          _selectedIds.remove(design.id);
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

  Future<void> _deleteSelectedDesigns() async {
    if (_selectedIds.isEmpty) return;

    final count = _selectedIds.length;
    final isAll = count == _designs.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(isAll ? 'Delete Entire Catalog' : 'Delete $count Designs'),
        content: Text(
          isAll
              ? 'Are you sure you want to delete ALL $count designs from your catalog? This action cannot be undone.'
              : 'Are you sure you want to delete the $count selected designs from your catalog? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_batch_delete_dialog_btn'),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete ($count)'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeletingBatch = true);

    final toDelete = _selectedIds.toList();
    int successCount = 0;
    final failedIds = <String>[];

    for (final id in toDelete) {
      try {
        await widget.designRepository.deleteDesign(id);
        successCount++;
      } catch (_) {
        failedIds.add(id);
      }
    }

    if (mounted) {
      setState(() {
        _isDeletingBatch = false;
        _designs.removeWhere((d) => toDelete.contains(d.id) && !failedIds.contains(d.id));
        _selectedIds.clear();
        _isSelectionMode = false;
      });

      if (failedIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAll
                  ? 'All $count designs deleted from catalog'
                  : 'Successfully deleted $successCount design(s)',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deleted $successCount design(s). Failed to delete ${failedIds.length}.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
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

    if (created != null && mounted) {
      setState(() {
        _designs = [created, ..._designs];
      });
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

    if (result == true && mounted) {
      _loadDesigns(showSpinner: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSelectionMode
            ? IconButton(
                key: const Key('cancel_selection_btn'),
                icon: const Icon(Icons.close),
                tooltip: 'Cancel',
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedIds.clear();
                  });
                },
              )
            : null,
        title: _isSelectionMode
            ? Text(
                '${_selectedIds.length} Selected',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            : Row(
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
        actions: _isSelectionMode
            ? [
                TextButton.icon(
                  key: const Key('select_all_btn'),
                  onPressed: _designs.isEmpty ? null : _toggleSelectAll,
                  icon: Icon(
                    _selectedIds.length == _designs.length && _designs.isNotEmpty
                        ? Icons.deselect
                        : Icons.select_all,
                    size: 18,
                    color: AppColors.brand,
                  ),
                  label: Text(
                    _selectedIds.length == _designs.length && _designs.isNotEmpty
                        ? 'Deselect All'
                        : 'Select All',
                    style: const TextStyle(
                      color: AppColors.brand,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('delete_selected_btn'),
                  icon: _isDeletingBatch
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                        )
                      : const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: 'Delete Selected',
                  onPressed: _selectedIds.isEmpty || _isDeletingBatch
                      ? null
                      : _deleteSelectedDesigns,
                ),
              ]
            : [
                if (_designs.isNotEmpty)
                  IconButton(
                    key: const Key('enter_selection_btn'),
                    icon: const Icon(Icons.checklist_rtl_outlined),
                    tooltip: 'Select Designs to Delete',
                    onPressed: _toggleSelectionMode,
                  ),
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
      bottomNavigationBar: _isSelectionMode && _designs.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedIds.isEmpty
                            ? 'Select designs to delete'
                            : '${_selectedIds.length} of ${_designs.length} selected',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    FilledButton.icon(
                      key: const Key('bottom_delete_selected_btn'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: _selectedIds.isEmpty || _isDeletingBatch
                          ? null
                          : _deleteSelectedDesigns,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text('Delete (${_selectedIds.length})'),
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
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
      addAutomaticKeepAlives: true,
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
        final isSelected = _selectedIds.contains(design.id);
        return _DesignCard(
          key: ValueKey('design_card_${design.id}'),
          design: design,
          isSelectionMode: _isSelectionMode,
          isSelected: isSelected,
          onToggleSelect: () => _toggleItemSelection(design.id),
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedIds.add(design.id);
              });
            }
          },
          onEdit: () => _editDesign(design),
          onDelete: () => _deleteDesign(design),
        );
      },
    );
  }
}

class _DesignCard extends StatefulWidget {
  const _DesignCard({
    required this.design,
    required this.onEdit,
    required this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelect,
    this.onLongPress,
    super.key,
  });

  final DesignItem design;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onLongPress;

  @override
  State<_DesignCard> createState() => _DesignCardState();
}

class _DesignCardState extends State<_DesignCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final photo = widget.design.photos.isNotEmpty ? widget.design.photos.first : null;
    final imageUrl = photo != null
        ? (photo.thumbnailOptimizedUrl.isNotEmpty ? photo.thumbnailOptimizedUrl : photo.cloudinaryUrl)
        : '';

    return GestureDetector(
      onTap: widget.isSelectionMode ? widget.onToggleSelect : null,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isSelected ? AppColors.brand : Colors.white12,
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brand.withValues(alpha: 0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
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
                  RepaintBoundary(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 400,
                            cacheHeight: 600,
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return child;
                              }
                              return Container(
                                color: Colors.white10,
                                child: const Center(
                                  child: Icon(Icons.image_outlined, color: Colors.white24, size: 28),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.white10,
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white.withValues(alpha: 0.03),
                            child: const Icon(Icons.image_outlined, color: Colors.grey),
                          ),
                  ),
                  // Tint overlay if selected
                  if (widget.isSelected)
                    Container(
                      color: AppColors.brand.withValues(alpha: 0.15),
                    ),
                  // Multi-photo indicator badge
                  if (widget.design.photos.length > 1 && !widget.isSelectionMode)
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
                              '${widget.design.photos.length}',
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
                  // Selection Checkbox Badge in selection mode
                  if (widget.isSelectionMode)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isSelected ? AppColors.brand : Colors.black54,
                          border: Border.all(
                            color: widget.isSelected ? AppColors.brand : Colors.white70,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          widget.isSelected ? Icons.check : Icons.circle_outlined,
                          size: 16,
                          color: widget.isSelected ? Colors.black : Colors.transparent,
                        ),
                      ),
                    ),
                  // Edit button (when not in selection mode)
                  if (!widget.isSelectionMode)
                    Positioned(
                      top: 6,
                      right: 40,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          key: Key('edit_design_btn_${widget.design.id}'),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.brand),
                          tooltip: 'Edit Design',
                          onPressed: widget.onEdit,
                        ),
                      ),
                    ),
                  // Delete button (when not in selection mode)
                  if (!widget.isSelectionMode)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                          tooltip: 'Delete Design',
                          onPressed: widget.onDelete,
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
                  if (widget.design.categoryName != null && widget.design.categoryName!.isNotEmpty)
                    Text(
                      widget.design.categoryName!,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (widget.design.tag != null && widget.design.tag!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#${widget.design.tag}',
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
      ),
    );
  }
}
