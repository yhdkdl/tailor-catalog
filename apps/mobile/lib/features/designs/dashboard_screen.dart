import 'package:flutter/material.dart';

import '../../core/errors/error_utils.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/locale/language_toggle.dart';
import '../../core/locale/locale_provider.dart';
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
    this.localeProvider,
    this.syncManager,
    required this.onSignOut,
    super.key,
  });

  final TailorProfile profile;
  final DesignRepository designRepository;
  final LocaleProvider? localeProvider;
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
  List<CategoryItem> _categories = [];
  String? _selectedCategoryId;
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
      List<CategoryItem> cats = _categories;
      try {
        cats = await widget.designRepository.getCategories();
      } catch (catErr) {
        debugPrint('[DASHBOARD] Could not load categories: $catErr');
      }
      if (mounted) {
        setState(() {
          _designs = list;
          _pendingQueue = queue;
          _categories = cats;
          _loading = false;
          // Clean up any selected ids no longer in the list
          _selectedIds.retainWhere((id) => list.any((d) => d.id == id));
          if (_designs.isEmpty) {
            _isSelectionMode = false;
          }
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final friendly = ErrorUtils.getFriendlyErrorMessage(
          e,
          stackTrace: stackTrace,
          contextTag: 'DASHBOARD_LOAD',
          l10n: l10n,
        );
        setState(() {
          _loading = false;
          _error = friendly;
        });
      }
    }
  }

  Future<void> _syncPendingUploads() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSyncing = true);
    final res = await _syncManager.processQueue();
    if (mounted) {
      setState(() => _isSyncing = false);
      if (res.succeededCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.successfullySynced(res.succeededCount)), backgroundColor: Colors.green),
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
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.deleteDesign),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
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
            SnackBar(content: Text(l10n.designRemoved)),
          );
        }
      } catch (e, stackTrace) {
        if (mounted) {
          final friendly = ErrorUtils.getFriendlyErrorMessage(
            e,
            stackTrace: stackTrace,
            contextTag: 'DASHBOARD_DELETE',
            l10n: l10n,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.failedToDeleteDesign}: $friendly')),
          );
        }
      }
    }
  }

  Future<void> _deleteSelectedDesigns() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedIds.isEmpty) return;

    final count = _selectedIds.length;
    final isAll = count == _designs.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(isAll ? l10n.deleteEntireCatalog : l10n.deleteCountDesigns(count)),
        content: Text(
          isAll
              ? 'Are you sure you want to delete ALL $count designs from your catalog? This action cannot be undone.'
              : 'Are you sure you want to delete the $count selected designs from your catalog? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('confirm_batch_delete_dialog_btn'),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteCount(count)),
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

      final l10n = AppLocalizations.of(context);
      if (failedIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAll
                  ? l10n.allDesignsDeleted(count)
                  : l10n.successfullyDeletedCount(successCount),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.deletedWithFailures(successCount, failedIds.length),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _editDesign(DesignItem design) async {
    final l10n = AppLocalizations.of(context);
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
        SnackBar(
          content: Text(l10n.designUpdatedSuccessfully),
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
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.brand),
                title: Text(l10n.singlePhotoDesign, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(l10n.singlePhotoSubtitle),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _navigateToSingleUpload();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.brand),
                title: Text(l10n.bulkUpload, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(l10n.bulkUploadSubtitle),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _navigateToBulkUpload();
                },
              ),
            ],
          ),
        );
      },
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _isSelectionMode
            ? IconButton(
                key: const Key('cancel_selection_btn'),
                icon: const Icon(Icons.close),
                tooltip: l10n.cancel,
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
                l10n.countSelected(_selectedIds.length),
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
                          child: Text(
                            l10n.approved,
                            style: const TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.w600),
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
                        ? l10n.deselectAll
                        : l10n.selectAll,
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
                  tooltip: l10n.deleteSelected,
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
                    tooltip: l10n.selectDesignsToDelete,
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
                if (widget.localeProvider != null)
                  LanguageToggle(provider: widget.localeProvider!),
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
                            ? l10n.selectDesignsToDeleteBottom
                            : l10n.countOfTotalSelected(_selectedIds.length, _designs.length),
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
                      label: Text(l10n.deleteCount(_selectedIds.length)),
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
              label: Text(l10n.uploadDesign, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
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
                    l10n.uploadsPending(_pendingQueue.length),
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
                        child: Text(l10n.syncNow, style: const TextStyle(fontSize: 12, color: Colors.amberAccent)),
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

  Widget _buildSkeletonGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 640 ? 3 : 2;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.04),
                      child: const Center(
                        child: Icon(Icons.image_outlined, color: Colors.white12, size: 28),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 10,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context);
    if (_loading) {
      return _buildSkeletonGrid();
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
                label: Text(l10n.tryAgainBtn),
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
                label: Text(l10n.uploadFirstDesign),
              ),
            ],
          ),
        ),
      );
    }

    final filteredDesigns = _selectedCategoryId == null
        ? _designs
        : _designs.where((d) => d.categoryId == _selectedCategoryId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_categories.isNotEmpty)
          _buildCategoryFilterBar(Localizations.localeOf(context).languageCode),
        Expanded(
          child: filteredDesigns.isEmpty
              ? _buildEmptyCategoryView(l10n)
              : GridView.builder(
                  addAutomaticKeepAlives: true,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: filteredDesigns.length,
                  itemBuilder: (context, index) {
                    final design = filteredDesigns[index];
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
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterBar(String langCode) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(
            key: const Key('filter_chip_all'),
            label: l10n.allCategories,
            count: _designs.length,
            isSelected: _selectedCategoryId == null,
            onTap: () => setState(() => _selectedCategoryId = null),
          ),
          const SizedBox(width: 8),
          ..._categories.map((cat) {
            final isSelected = _selectedCategoryId == cat.id;
            final count = _designs.where((d) => d.categoryId == cat.id).length;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                key: Key('filter_chip_${cat.id}'),
                label: cat.nameForLocale(langCode),
                count: count,
                isSelected: isSelected,
                onTap: () => setState(() {
                  _selectedCategoryId = isSelected ? null : cat.id;
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    Key? key,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB87D0E) : const Color(0xFF242427),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF333338),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF333338),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCategoryView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_alt_off_outlined, size: 48, color: Color(0xFF71717A)),
            const SizedBox(height: 14),
            Text(
              l10n.noDesignsInCategory,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () => setState(() => _selectedCategoryId = null),
              icon: const Icon(Icons.clear_all),
              label: Text(l10n.showAll),
            ),
          ],
        ),
      ),
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
