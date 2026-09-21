import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
import 'design_repository.dart';
import 'edit_design_screen.dart';
import 'models.dart';

/// Global RouteObserver — register this in MaterialApp.navigatorObservers
/// so DashboardScreen can detect when it becomes active again after a pop.
final RouteObserver<ModalRoute<void>> dashboardRouteObserver =
    RouteObserver<ModalRoute<void>>();

// ─────────────────────────────────────────────────────────────
// Design constants
// ─────────────────────────────────────────────────────────────
const _kCardRadius = 20.0;
const _kHeaderGradientStart = Color(0xFF0A0F1A);
const _kHeaderGradientEnd = Color(0xFF05080F);
const _kSurfaceElevated = Color(0xFF0F1623);
const _kBorderSubtle = Color(0xFF1E293B);
const _kBrandGlow = Color(0xFFD4A847);

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

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  late final OfflineSyncManager _syncManager;
  List<DesignItem> _designs = [];
  List<QueuedUploadItem> _pendingQueue = [];
  List<CategoryItem> _categories = [];
  String? _selectedCategoryId;
  bool _loading = true;
  bool _isSyncing = false;
  String? _error;

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

  @override
  void didPopNext() {}

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
          _selectedIds.retainWhere((id) => list.any((d) => d.id == id));
          if (_designs.isEmpty) _isSelectionMode = false;
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
          SnackBar(
            content: Text(l10n.successfullySynced(res.succeededCount)),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadDesigns();
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedIds.clear();
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
        backgroundColor: _kSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            SnackBar(
                content:
                    Text('${l10n.failedToDeleteDesign}: $friendly')),
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
        backgroundColor: _kSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
            isAll ? l10n.deleteEntireCatalog : l10n.deleteCountDesigns(count)),
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
        _designs.removeWhere(
            (d) => toDelete.contains(d.id) && !failedIds.contains(d.id));
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
            content:
                Text(l10n.deletedWithFailures(successCount, failedIds.length)),
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
        if (index != -1) _designs[index] = updated;
      });
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.designUpdatedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDesignViewer(DesignItem design) {
    final photos = design.photos;
    if (photos.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _DesignViewerScreen(design: design),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return Container(
          decoration: const BoxDecoration(
            color: _kSurfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Add to Catalog',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _UploadOptionTile(
                    icon: Icons.photo_library_outlined,
                    title: l10n.bulkUpload,
                    subtitle: l10n.bulkUploadSubtitle,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _navigateToBulkUpload();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: _buildAppBar(l10n),
        body: RefreshIndicator(
          color: AppColors.brand,
          backgroundColor: _kSurfaceElevated,
          onRefresh: _loadDesigns,
          child: _buildBody(),
        ),
        bottomNavigationBar: _isSelectionMode && _designs.isNotEmpty
            ? _buildSelectionBar(l10n)
            : null,
        floatingActionButton:
            _isSelectionMode ? null : _buildFab(l10n),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kHeaderGradientStart, _kHeaderGradientEnd],
          ),
          border: const Border(
            bottom: BorderSide(color: _kBorderSubtle, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: kToolbarHeight + 8,
          leading: _isSelectionMode
              ? IconButton(
                  key: const Key('cancel_selection_btn'),
                  icon: const Icon(Icons.close_rounded, size: 22),
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
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                )
              : _buildAppBarTitle(),
          actions: _isSelectionMode
              ? _buildSelectionActions(l10n)
              : _buildNormalActions(l10n),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFD4A847), Color(0xFF8A6A2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _kBrandGlow.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.profile.shopName.isNotEmpty
                  ? widget.profile.shopName[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                color: Color(0xFF1A0F00),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.profile.shopName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF22C55E),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Approved',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4ADE80),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSelectionActions(AppLocalizations l10n) {
    return [
      TextButton.icon(
        key: const Key('select_all_btn'),
        onPressed: _designs.isEmpty ? null : _toggleSelectAll,
        icon: Icon(
          _selectedIds.length == _designs.length && _designs.isNotEmpty
              ? Icons.deselect_rounded
              : Icons.select_all_rounded,
          size: 19,
          color: _kBrandGlow,
        ),
        label: Text(
          _selectedIds.length == _designs.length && _designs.isNotEmpty
              ? l10n.deselectAll
              : l10n.selectAll,
          style: const TextStyle(
            color: _kBrandGlow,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
      ),
      IconButton(
        key: const Key('delete_selected_btn'),
        icon: _isDeletingBatch
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.redAccent),
              )
            : const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 21),
        tooltip: l10n.deleteSelected,
        onPressed:
            _selectedIds.isEmpty || _isDeletingBatch ? null : _deleteSelectedDesigns,
      ),
    ];
  }

  List<Widget> _buildNormalActions(AppLocalizations l10n) {
    return [
      if (_designs.isNotEmpty)
        IconButton(
          key: const Key('enter_selection_btn'),
          icon: const Icon(Icons.checklist_rounded, size: 21),
          tooltip: l10n.selectDesignsToDelete,
          onPressed: _toggleSelectionMode,
        ),
      IconButton(
        key: const Key('qr_icon_btn'),
        icon: const Icon(Icons.qr_code_2_rounded, size: 21),
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
        icon: const Icon(Icons.logout_rounded, size: 21),
        tooltip: 'Sign out',
        onPressed: widget.onSignOut,
      ),
    ];
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (!_loading && _error == null && _designs.isNotEmpty)
          _buildStatsStrip(),
        if (_pendingQueue.isNotEmpty) _buildPendingBanner(l10n),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildStatsStrip() {
    final filtered = _selectedCategoryId == null
        ? _designs
        : _designs.where((d) => d.categoryId == _selectedCategoryId).toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _kSurfaceElevated,
        border: const Border(
          bottom: BorderSide(color: _kBorderSubtle, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.inventory_2_rounded,
            label:
                '${_designs.length} ${_designs.length == 1 ? 'design' : 'designs'}',
          ),
          if (_selectedCategoryId != null) ...[
            const SizedBox(width: 8),
            _StatChip(
              icon: Icons.filter_list_rounded,
              label: '${filtered.length} shown',
              accent: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingBanner(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1C1600),
            Color(0xFF2A1F00),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF78350F).withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF78350F).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.cloud_upload_rounded,
                size: 18, color: Color(0xFFFBBF24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.uploadsPending(_pendingQueue.length),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFDE68A),
                letterSpacing: 0.2,
              ),
            ),
          ),
          _isSyncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFBBF24),
                  ),
                )
              : GestureDetector(
                  onTap: _syncPendingUploads,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF78350F).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      l10n.syncNow,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFBBF24),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kSurfaceElevated,
        border: const Border(top: BorderSide(color: _kBorderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedIds.isEmpty
                    ? l10n.selectDesignsToDeleteBottom
                    : l10n.countOfTotalSelected(
                        _selectedIds.length, _designs.length),
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13.5, letterSpacing: 0.2),
              ),
            ),
            FilledButton.icon(
              key: const Key('bottom_delete_selected_btn'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _selectedIds.isEmpty || _isDeletingBatch
                  ? null
                  : _deleteSelectedDesigns,
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: Text(l10n.deleteCount(_selectedIds.length)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFD4A847), Color(0xFF8A6A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _kBrandGlow.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        key: const Key('upload_fab'),
        onPressed: _showUploadOptions,
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        icon: const Icon(Icons.add_photo_alternate_rounded,
            color: Color(0xFF1A0F00), size: 22),
        label: Text(
          l10n.uploadDesign,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A0F00),
            letterSpacing: 0.4,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Content builders
  // ─────────────────────────────────────────────────────────────

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context);
    if (_loading) return _buildSkeletonGrid();
    if (_error != null) return _buildErrorView(l10n);
    if (_designs.isEmpty) return _buildEmptyState(l10n);
    final filteredDesigns = _selectedCategoryId == null
        ? _designs
        : _designs.where((d) => d.categoryId == _selectedCategoryId).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_categories.isNotEmpty)
          _buildCategoryFilterBar(
              Localizations.localeOf(context).languageCode),
        Expanded(
          child: filteredDesigns.isEmpty
              ? _buildEmptyCategoryView(l10n)
              : _buildGrid(filteredDesigns),
        ),
      ],
    );
  }

  Widget _buildGrid(List<DesignItem> designs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 640 ? 3 : 2;
        return GridView.builder(
          addAutomaticKeepAlives: true,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.68,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: designs.length,
          itemBuilder: (context, index) {
            final design = designs[index];
            final isSelected = _selectedIds.contains(design.id);
            return _DesignCard(
              key: ValueKey('design_card_${design.id}'),
              design: design,
              isSelectionMode: _isSelectionMode,
              isSelected: isSelected,
              onToggleSelect: () => _toggleItemSelection(design.id),
              onTap: () => _showDesignViewer(design),
              onLongPress: () {
                if (!_isSelectionMode) {
                  HapticFeedback.mediumImpact();
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
      },
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
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _SkeletonCard(
                delay: Duration(milliseconds: index * 80));
          },
        );
      },
    );
  }

  Widget _buildErrorView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.cloud_off_outlined,
                  size: 40, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _kSurfaceElevated,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loadDesigns,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgainBtn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brand.withValues(alpha: 0.06),
                  ),
                ),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brand.withValues(alpha: 0.12),
                    border: Border.all(
                        color: AppColors.brand.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.checkroom_outlined,
                      size: 36, color: AppColors.brand),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Your catalog is empty',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              'Upload photos of your tailoring work to\nshowcase them to customers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: const Color(0xFF1A0F00),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _showUploadOptions,
              icon: const Icon(Icons.add),
              label: Text(
                l10n.uploadFirstDesign,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterBar(String langCode) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _kSurfaceElevated,
        border: const Border(
          bottom: BorderSide(color: _kBorderSubtle, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            final count =
                _designs.where((d) => d.categoryId == cat.id).length;
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
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFD4A847), Color(0xFF8A6A2A)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF1A2235),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? _kBrandGlow.withValues(alpha: 0.8)
                : const Color(0xFF243047),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _kBrandGlow.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF1A0F00)
                    : const Color(0xFFCBD5E1),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black.withValues(alpha: 0.2)
                    : const Color(0xFF243047),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1A0F00)
                      : const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2235),
                shape: BoxShape.circle,
                border: Border.all(color: _kBorderSubtle),
              ),
              child: const Icon(Icons.filter_alt_off_outlined,
                  size: 36, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDesignsInCategory,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.muted, fontSize: 15),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _selectedCategoryId = null),
              icon: const Icon(Icons.clear_all, size: 18),
              label: Text(l10n.showAll),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Supporting widgets
// ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    this.accent = false,
  });
  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent
            ? _kBrandGlow.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent
              ? _kBrandGlow.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: accent ? _kBrandGlow : AppColors.muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: accent ? _kBrandGlow : AppColors.muted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadOptionTile extends StatelessWidget {
  const _UploadOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2235),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorderSubtle, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _kBrandGlow.withValues(alpha: 0.15),
                    _kBrandGlow.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _kBrandGlow.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: _kBrandGlow, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Animated skeleton card
// ─────────────────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard({required this.delay});
  final Duration delay;

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0.04, end: 0.09).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: _kSurfaceElevated,
            borderRadius: BorderRadius.circular(_kCardRadius),
            border: Border.all(color: _kBorderSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  color: Colors.white.withValues(alpha: _anim.value),
                  child: const Center(
                    child: Icon(Icons.image_outlined,
                        color: Colors.white12, size: 28),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 11,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: _anim.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      height: 9,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: _anim.value * 0.7),
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
  }
}

// ─────────────────────────────────────────────────────────────
// Design Card
// ─────────────────────────────────────────────────────────────

class _DesignCard extends StatefulWidget {
  const _DesignCard({
    required this.design,
    required this.onEdit,
    required this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelect,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final DesignItem design;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onTap;
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
    final photo = widget.design.photos.isNotEmpty
        ? widget.design.photos.first
        : null;
    final imageUrl = photo != null
        ? (photo.thumbnailOptimizedUrl.isNotEmpty
            ? photo.thumbnailOptimizedUrl
            : photo.cloudinaryUrl)
        : '';

    return GestureDetector(
      onTap: widget.isSelectionMode ? widget.onToggleSelect : widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _kSurfaceElevated,
          borderRadius: BorderRadius.circular(_kCardRadius),
          border: Border.all(
            color: widget.isSelected ? _kBrandGlow : _kBorderSubtle,
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? _kBrandGlow.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.25),
              blurRadius: widget.isSelected ? 16 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
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
                            frameBuilder: (context, child, frame,
                                wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded ||
                                  frame != null) {
                                return child;
                              }
                              return Container(
                                color: Colors.white.withValues(alpha: 0.04),
                                child: const Center(
                                  child: Icon(Icons.image_outlined,
                                      color: Colors.white24, size: 32),
                                ),
                              );
                            },
                            errorBuilder: (context, error,
                                    stackTrace) =>
                                Container(
                              color: Colors.white.withValues(alpha: 0.04),
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: AppColors.muted, size: 32),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white.withValues(alpha: 0.03),
                            child: const Center(
                              child: Icon(Icons.checkroom_outlined,
                                  color: AppColors.muted, size: 36),
                            ),
                          ),
                  ),
                  // Bottom gradient overlay
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 70,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.75),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Selection tint
                  if (widget.isSelected)
                    Container(
                        color: _kBrandGlow.withValues(alpha: 0.2)),
                  // Multi-photo badge
                  if (widget.design.photos.length > 1 &&
                      !widget.isSelectionMode)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.collections_rounded,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.design.photos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Selection checkbox
                  if (widget.isSelectionMode)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isSelected
                              ? _kBrandGlow
                              : Colors.black.withValues(alpha: 0.6),
                          border: Border.all(
                            color: widget.isSelected
                                ? _kBrandGlow
                                : Colors.white.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: widget.isSelected
                              ? [
                                  BoxShadow(
                                    color: _kBrandGlow.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: widget.isSelected
                            ? const Icon(Icons.check_rounded,
                                size: 15, color: Color(0xFF1A0F00))
                            : null,
                      ),
                    ),
                  // Edit button
                  if (!widget.isSelectionMode)
                    Positioned(
                      top: 10,
                      right: 48,
                      child: _CardActionButton(
                        key: Key('edit_design_btn_${widget.design.id}'),
                        icon: Icons.edit_rounded,
                        iconColor: _kBrandGlow,
                        onTap: widget.onEdit,
                        tooltip: 'Edit Design',
                      ),
                    ),
                  // Delete button
                  if (!widget.isSelectionMode)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _CardActionButton(
                        icon: Icons.delete_rounded,
                        iconColor: Colors.white,
                        onTap: widget.onDelete,
                        tooltip: 'Delete Design',
                      ),
                    ),
                ],
              ),
            ),
            // Info strip
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.design.categoryName != null &&
                      widget.design.categoryName!.isNotEmpty)
                    Text(
                      widget.design.categoryName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _kBrandGlow,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (widget.design.tag != null &&
                      widget.design.tag!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${widget.design.tag}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.muted,
                          letterSpacing: 0.3,
                        ),
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

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.tooltip,
    super.key,
  });
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Design Viewer Screen
// ─────────────────────────────────────────────────────────────

class _DesignViewerScreen extends StatefulWidget {
  const _DesignViewerScreen({
    required this.design,
  });

  final DesignItem design;

  @override
  State<_DesignViewerScreen> createState() => _DesignViewerScreenState();
}

class _DesignViewerScreenState extends State<_DesignViewerScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.design.photos;
    if (photos.isEmpty) {
      Navigator.of(context).pop();
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.design.categoryName != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    widget.design.categoryName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Image viewer
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              final imageUrl = photo.thumbnailOptimizedUrl.isNotEmpty
                  ? photo.cloudinaryUrl // Use full image for viewer
                  : photo.cloudinaryUrl;

              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          // Photo indicator
          if (photos.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_currentPage + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ' / ${photos.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Tag display
          if (widget.design.tag != null && widget.design.tag!.isNotEmpty)
            Positioned(
              bottom: photos.length > 1 ? 90 : 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#${widget.design.tag}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
