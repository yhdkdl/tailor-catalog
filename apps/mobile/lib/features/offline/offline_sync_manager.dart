import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../designs/design_repository.dart';
import '../designs/models.dart';
import 'offline_service.dart';

class SyncResult {
  const SyncResult({
    required this.succeededCount,
    required this.failedCount,
  });

  final int succeededCount;
  final int failedCount;
}

class OfflineSyncManager {
  OfflineSyncManager({
    required this.designRepository,
    OfflineStorage? storage,
    Connectivity? connectivity,
    bool listenConnectivity = true,
  })  : _storage = storage ?? InMemoryOfflineStorage(),
        _connectivity = connectivity {
    if (listenConnectivity && _connectivity != null) {
      _subscription = _connectivity!.onConnectivityChanged.listen((results) {
        final isOnline = results.any((r) => r != ConnectivityResult.none);
        if (isOnline) {
          processQueue();
        }
      });
    }
  }

  final DesignRepository designRepository;
  final OfflineStorage _storage;
  final Connectivity? _connectivity;
  StreamSubscription? _subscription;
  bool _isProcessing = false;

  void dispose() {
    _subscription?.cancel();
  }

  Future<bool> isConnected() async {
    if (_connectivity == null) return true;
    try {
      final results = await _connectivity!.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  Future<List<CategoryItem>> getCategories() async {
    try {
      final onlineCategories = await designRepository.getCategories();
      if (onlineCategories.isNotEmpty) {
        await _storage.cacheCategories(onlineCategories);
      }
      return onlineCategories;
    } catch (_) {
      final cached = await _storage.getCachedCategories();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<DesignItem>> getTailorDesigns(String tailorId) async {
    try {
      final onlineDesigns = await designRepository.getTailorDesigns(tailorId);
      await _storage.cacheDesigns(tailorId, onlineDesigns);
      return onlineDesigns;
    } catch (_) {
      final cached = await _storage.getCachedDesigns(tailorId);
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<void> enqueueOfflineUpload({
    required String tailorId,
    required String categoryId,
    required double price,
    String? tag,
    required bool isGrouped,
    required List<Uint8List> imageBytesList,
    required List<String> filenames,
    required String authUid,
  }) async {
    final base64Images = imageBytesList.map((b) => base64Encode(b)).toList();
    final item = QueuedUploadItem(
      id: 'queue_${DateTime.now().millisecondsSinceEpoch}',
      tailorId: tailorId,
      categoryId: categoryId,
      price: price,
      tag: tag,
      isGrouped: isGrouped,
      imagesBase64: base64Images,
      filenames: filenames,
      authUid: authUid,
      createdAt: DateTime.now(),
    );
    await _storage.enqueueUpload(item);
  }

  Future<List<QueuedUploadItem>> getPendingUploads() => _storage.getPendingUploads();

  Future<SyncResult> processQueue() async {
    if (_isProcessing) return const SyncResult(succeededCount: 0, failedCount: 0);
    _isProcessing = true;

    var succeeded = 0;
    var failed = 0;

    try {
      final queue = await _storage.getPendingUploads();
      for (final item in queue) {
        try {
          final imageBytesList = item.imagesBase64.map((b) => base64Decode(b)).toList();

          if (item.isGrouped) {
            await designRepository.createGroupedDesign(
              tailorId: item.tailorId,
              categoryId: item.categoryId,
              price: item.price,
              tag: item.tag,
              imageBytesList: imageBytesList,
              filenames: item.filenames,
              authUid: item.authUid,
            );
          } else {
            await designRepository.createBulkIndividualDesigns(
              tailorId: item.tailorId,
              categoryId: item.categoryId,
              price: item.price,
              tag: item.tag,
              imageBytesList: imageBytesList,
              filenames: item.filenames,
              authUid: item.authUid,
            );
          }

          await _storage.removePendingUpload(item.id);
          succeeded++;
        } catch (_) {
          failed++;
        }
      }
    } finally {
      _isProcessing = false;
    }

    return SyncResult(succeededCount: succeeded, failedCount: failed);
  }
}
