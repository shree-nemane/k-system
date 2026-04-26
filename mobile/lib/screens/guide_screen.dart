import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/ritual.dart';
import '../providers/rituals_provider.dart';
import '../core/constants.dart';
import '../providers/navigation_provider.dart';
import '../providers/tab_provider.dart';
import 'package:latlong2/latlong.dart';

class GuideScreen extends ConsumerStatefulWidget {
  const GuideScreen({super.key});

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data from assets
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final syncService = ref.read(syncServiceProvider);
      if (syncService != null) {
        await syncService.loadInitialData();
      }
    });
  }

  Future<void> _handleSync() async {
    final syncService = ref.read(syncServiceProvider);
    if (syncService != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Syncing spiritual guide...')),
      );
      await syncService.syncWithBackend();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ritualsAsync = ref.watch(ritualsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'MahaKumbh Guide',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.sync, color: AppColors.secondary),
              onPressed: _handleSync,
              tooltip: 'Sync Sacred Knowledge',
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Rituals'),
              Tab(text: 'Safety'),
              Tab(text: 'Directory'),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.5),
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
        body: ritualsAsync.when(
          data: (rituals) => TabBarView(
            children: [
              _buildTimelineView(rituals),
              _buildSafetyPlaceholder(),
              _buildContactPlaceholder(),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildTimelineView(List<Ritual> rituals) {
    if (rituals.isEmpty) {
      return Center(
        child: Text(
          'No rituals scheduled.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      itemCount: rituals.length,
      itemBuilder: (context, index) {
        final ritual = rituals[index];
        final isLast = index == rituals.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Column - Spiritual Confluence Style
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getImportanceColor(ritual.importance),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _getImportanceColor(ritual.importance).withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _getImportanceColor(ritual.importance).withValues(alpha: 0.5),
                              AppColors.onSurface.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              // Content Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM dd • hh:mm a').format(ritual.startTime).toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ritual.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.temple_hindu, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Text(
                            ritual.location,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 14,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ritual.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Link to map integration
                          final lat = ritual.locationCoord[0];
                          final lng = ritual.locationCoord[1];
                          
                          // 1. Start navigation
                          ref.read(navigationProvider.notifier).startNavigation(
                            LatLng(lat, lng), 
                            ritual.title
                          );

                          // 2. Switch to Live Map Tab
                          ref.read(tabProvider.notifier).state = 1;

                          // 3. Return to Main Scaffold
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.near_me_outlined, size: 18),
                        label: const Text('PILGRIMAGE MAP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getImportanceColor(String importance) {
    switch (importance.toLowerCase()) {
      case 'critical':
        return AppColors.alert;
      case 'high':
        return Colors.orange;
      default:
        return AppColors.secondary;
    }
  }

  Widget _buildSafetyPlaceholder() {
    return Center(
      child: Text(
        'Safety context coming soon...',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildContactPlaceholder() {
    return Center(
      child: Text(
        'Sacred Contacts synced from Sangam DB.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
