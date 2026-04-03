import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/live_alert_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MahaKumbh 2027',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: const [
          CircleAvatar(
            backgroundColor: Color(0xFFFFB74D),
            radius: 18,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Spiritual Greeting
            _buildGreeting(context),
            const SizedBox(height: 24),

            // 2. Divine Guidance Card (Replaces Status Card)
            _buildGuidanceCard(context),
            const SizedBox(height: 32),
            
            // 3. Sacred Service Grid (Simplified)
            _buildActionGrid(context),
            const SizedBox(height: 32),
            
            // 4. Divine Protection (Live Alerts)
            _buildSectionHeader(context, 'Divine Protection Alerts'),
            const SizedBox(height: 16),
            _buildAlertList(context, ref),
            const SizedBox(height: 32),

            // 5. Ancient Wisdom Section (New Content)
            _buildWisdomSection(context),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jay Gange, Pilgrim',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          'Your spiritual journey continues at Prayagraj.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildGuidanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.saffronGradientDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('SPIRITUAL GUIDANCE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 20),
          Text(
            'Daily Ritual Insight',
            style: GoogleFonts.manrope(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'The early morning Snaan at Sangam is uniquely auspicious today.',
            style: GoogleFonts.notoSerif(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Auspicious time: 04:30 AM - 06:15 AM',
                style: GoogleFonts.manrope(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            'Smart Hubs',
            Icons.hub_outlined,
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary,
            '/hubs',
            'Find essential services',
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildActionCard(
            context,
            'Ritual Guide',
            Icons.menu_book_outlined,
            Colors.orange.withValues(alpha: 0.1),
            Colors.orange,
            '/guide',
            'Explore the timeline',
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color bg, Color tint, String route, String subtitle) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.sanctuaryCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: tint, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWisdomSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Ancient Wisdom'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.sanctuaryCardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Legend of the Sangam',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                'During the "Samudra Manthan" (Churning of the Ocean), drops of the nectar of immortality (Amrit) fell at four sacred places. Prayagraj is the king of these holy sites, where the invisible Saraswati meets the Ganga and Yamuna.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 16),
              Text(
                'The 2027 MahaKumbh marks a celestial alignment that occurs only once every 144 years, offering a unique opportunity for spiritual liberation (Moksha) through the sacred bath.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.secondary),
      ],
    );
  }

  Widget _buildAlertList(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(liveAlertProvider);

    return alertsAsync.when(
      data: (alerts) {
        if (alerts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.sanctuaryCardDecoration,
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Colors.green),
                const SizedBox(width: 16),
                Text('All systems are stable', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          );
        }
        
        final latest = alerts.first;
        return Container(
          decoration: AppTheme.sanctuaryCardDecoration,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (latest.severity == 'critical' ? AppColors.alert : Colors.orange).withValues(alpha: 0.1), 
                shape: BoxShape.circle
              ),
              child: Icon(
                latest.severity == 'critical' ? Icons.security : Icons.notification_important_outlined, 
                color: latest.severity == 'critical' ? AppColors.alert : Colors.orange, 
                size: 24
              ),
            ),
            title: Text(
              latest.eventType.replaceAll('_', ' ').toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            subtitle: Text(
              'Security updated just now',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.secondary),
            onTap: () => Navigator.pushNamed(context, '/alerts'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => const Text('Unable to connect to security feed'),
    );
  }
}
