import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';

class BootstrapScreen extends StatelessWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.brand.withValues(alpha: 0.35)),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  size: 40,
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tailor Catalog',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your design catalog, ready to share',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
              const SizedBox(height: 32),
              _StatusCard(
                label: 'Supabase',
                ready: AppConfig.hasSupabase,
              ),
              const SizedBox(height: 10),
              _StatusCard(
                label: 'Cloudinary',
                ready: AppConfig.hasCloudinary,
              ),
              const Spacer(flex: 3),
              Text(
                'Tailor app',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.label, required this.ready});

  final String label;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final color = ready ? AppColors.forest : AppColors.brand;
    final status = ready ? 'Configured' : 'Missing dart-define';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            ready ? Icons.check_circle_outline : Icons.info_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            status,
            style: TextStyle(color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
