import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import 'qr_service.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({
    required this.profile,
    this.qrService = const QrService(),
    super.key,
  });

  final TailorProfile profile;
  final QrService qrService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogUrl = QrService.buildCatalogUrl(profile.shopSlug);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.storeQrCode),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Printable QR sheet card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.shopName,
                      key: const Key('qr_shop_name'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.shopSlug,
                      key: const Key('qr_shop_slug'),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // QR Code widget
                    Container(
                      key: const Key('qr_image_container'),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: QrImageView(
                        data: catalogUrl,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 16, color: Colors.grey.shade800),
                        const SizedBox(width: 6),
                        Text(
                          l10n.pointCameraToScan,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      catalogUrl,
                      key: const Key('qr_catalog_url'),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Share button
              FilledButton.icon(
                key: const Key('share_qr_btn'),
                onPressed: () async {
                  await SharePlus.instance.share(
                    ShareParams(
                      text: 'Browse our full tailoring catalog and designs online at: $catalogUrl',
                      subject: '${profile.shopName} Catalog',
                    ),
                  );
                },
                icon: const Icon(Icons.share_outlined),
                label: Text(
                  l10n.shareCatalogLink,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),

              // Copy link button
              OutlinedButton.icon(
                key: const Key('copy_link_btn'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: catalogUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.catalogUrlCopied),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_outlined),
                label: Text(l10n.copyCatalogLink),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
