import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/ritual.dart';
import '../providers/rituals_provider.dart';
import '../core/constants.dart';

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
        appBar: AppBar(
          title: Text(
            'MahaKumbh Guide',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _handleSync,
              tooltip: 'Sync with Backend',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_month), text: 'Rituals'),
              Tab(icon: Icon(Icons.security), text: 'Safety'),
              Tab(icon: Icon(Icons.phone), text: 'Emergency'),
            ],
            indicatorColor: AppColors.secondary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildTimelineView(List<Ritual> rituals) {
    if (rituals.isEmpty) {
      return const Center(child: Text('No rituals scheduled.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: rituals.length,
      itemBuilder: (context, index) {
        final ritual = rituals[index];
        final isLast = index == rituals.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Column
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _getImportanceColor(ritual.importance),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.grey[300],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Content Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(ritual.startTime),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ritual.title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ritual.location,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE6A85C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ritual.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              // Link to map integration (D-26)
                              debugPrint('Navigate to map: ${ritual.locationCoord}');
                            },
                            icon: const Icon(Icons.map, size: 16),
                            label: const Text('See on Map'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              side: const BorderSide(color: AppColors.secondary),
                              foregroundColor: AppColors.secondary,
                            ),
                          ),
                        ],
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
        return Colors.red;
      case 'high':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildSafetyPlaceholder() {
    return const Center(child: Text('Safety context coming soon...'));
  }

  Widget _buildContactPlaceholder() {
    return const Center(child: Text('Emergency contacts synced from local DB.'));
  }
}
