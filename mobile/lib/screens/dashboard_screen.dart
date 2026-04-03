import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/live_alert_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6), // Digital Sanctuary Ivory
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Prashasan AI',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF2E5B7F), // Deep Blue
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.blueGrey),
            onPressed: () => Navigator.pushNamed(context, '/alerts'),
          ),
          const CircleAvatar(
            backgroundColor: Color(0xFFFFB74D),
            radius: 18,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Status Card
            _buildStatusCard(context),
            const SizedBox(height: 24),
            
            // Core Actions Grid
            _buildActionGrid(context),
            const SizedBox(height: 24),
            
            // Live Alerts Preview
            _buildSectionHeader('Live Security Alerts'),
            const SizedBox(height: 12),
            _buildAlertList(context, ref),
            
            const SizedBox(height: 24),
            // Information Centers Preview
            _buildSectionHeader('Nearby Smart Hubs'),
            const SizedBox(height: 12),
            _buildHubPreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E5B7F), Color(0xFF1A3A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E5B7F).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Colors.greenAccent),
                    SizedBox(width: 6),
                    Text('SYSTEM STABLE', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              const Text('Prayagraj Zone', style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Safety Status',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Crowd Level: Optimal',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: 0.3,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildActionCard(
          context,
          'Live Map',
          Icons.map_outlined,
          const Color(0xFFE6A85C).withValues(alpha: 0.1),
          const Color(0xFFE6A85C),
          '/map',
        ),
        _buildActionCard(
          context,
          'SOS',
          Icons.emergency_outlined,
          Colors.red.withValues(alpha: 0.1),
          Colors.red,
          '/sos',
        ),
        _buildActionCard(
          context,
          'Smart Hubs',
          Icons.info_outline,
          Colors.blue.withValues(alpha: 0.1),
          Colors.blue,
          '/hubs',
        ),
        _buildActionCard(
          context,
          'Ritual Guide',
          Icons.menu_book_outlined,
          Colors.orange.withValues(alpha: 0.1),
          Colors.orange,
          '/guide',
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color bg, Color tint, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: tint, size: 20),
            ),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF2E5B7F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A3A5F),
          ),
        ),
        const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
      ],
    );
  }

  Widget _buildAlertList(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(liveAlertProvider);

    return alertsAsync.when(
      data: (alerts) {
        if (alerts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green),
                SizedBox(width: 12),
                Text('All systems normal'),
              ],
            ),
          );
        }
        
        final latest = alerts.first;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (latest.severity == 'critical' ? Colors.red : Colors.orange).withValues(alpha: 0.1), 
                shape: BoxShape.circle
              ),
              child: Icon(
                latest.severity == 'critical' ? Icons.error_outline : Icons.warning_amber_rounded, 
                color: latest.severity == 'critical' ? Colors.red : Colors.orange, 
                size: 20
              ),
            ),
            title: Text(latest.eventType.replaceAll('_', ' ').toUpperCase()),
            subtitle: const Text('Updated just now • Safety notice'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/alerts'),
          ),
        );
      },
      loading: () => const Center(child: LinearProgressIndicator()),
      error: (_, __) => const Text('Unable to connect to security feed'),
    );
  }

  Widget _buildHubPreview(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E5B7F).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.help_center_outlined, color: Color(0xFF2E5B7F), size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Smart Hub ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('200m away', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
