import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class SmartHubsScreen extends StatelessWidget {
  const SmartHubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Smart Hubs',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(4),
            decoration: AppTheme.sanctuaryCardDecoration,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hub_outlined, color: AppColors.secondary, size: 24),
              ),
              title: Text(
                'Sacred Hub Sector ${index + 1}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'WATER • MEDICINE • ASSISTANCE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, letterSpacing: 1),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
              onTap: () {
                // Future: Show on map
              },
            ),
          );
        },
      ),
    );
  }
}
