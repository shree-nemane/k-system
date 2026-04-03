import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

class SmartHubsScreen extends StatelessWidget {
  const SmartHubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Information Hubs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: AppColors.primary),
              ),
              title: Text(
                'Smart Hub Sector ${index + 1}',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Available: Water, First Aid, Lost & Found'),
              trailing: const Icon(Icons.chevron_right),
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
