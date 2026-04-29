import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/live_alert_provider.dart';
import '../providers/alert_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(liveAlertProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Divine Protection Feed',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user, size: 80, color: Colors.green),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'All Sectors Secure',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Divine protection is active across all sectors.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: alerts.length,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemBuilder: (ctx, index) {
              final alert = alerts[index];
              final severityColor = _getSeverityColor(alert.severity);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: AppTheme.sanctuaryCardDecoration,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Severity Indicator Strip
                        Container(width: 8, color: severityColor),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: severityColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        alert.severity.toUpperCase(),
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: severityColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${DateTime.now().difference(alert.firedAt).inMinutes}m ago',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  alert.message ?? alert.eventType.replaceAll('_', ' ').toUpperCase(),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold,
                                    color: alert.severity == 'high' || alert.severity == 'critical' ? AppColors.alert : null,
                                  ),
                                ),
                                if (alert.recommendation != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: severityColor.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: severityColor.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.security, size: 16, color: severityColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            alert.recommendation!,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: severityColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.location_pin, size: 16, color: AppColors.secondary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Prayagraj • Uttar Pradesh', 
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_outlined, size: 64, color: AppColors.alert),
              const SizedBox(height: 24),
              Text(
                'Safety Feed Offline',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.refresh(alertProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('RECONNECT TO FEED'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return AppColors.alert;
      case 'high': return Colors.orange;
      case 'medium': return AppColors.primary;
      default: return AppColors.secondary;
    }
  }
}
