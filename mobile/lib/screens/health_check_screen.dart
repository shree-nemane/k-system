import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/api_client.dart';

class HealthCheckScreen extends ConsumerStatefulWidget {
  const HealthCheckScreen({super.key});

  @override
  ConsumerState<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends ConsumerState<HealthCheckScreen> {
  bool _isChecking = true;
  String _status = 'Initializing...';
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    setState(() {
      _isChecking = true;
      _status = 'Checking API Connectivity...\nTarget: ${ApiClient().baseUrl}';
      _failed = false;
    });

    try {
      final client = ApiClient();
      final response = await client.get('/alerts/recent').timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _handleFailure('API error: ${response.statusCode}');
      }
    } catch (e) {
      _handleFailure('Connection failed. Backend may be offline.');
    }
  }

  void _handleFailure(String message) {
    setState(() {
      _isChecking = false;
      _status = message;
      _failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'MahaKumbh 2027',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Smart Guide & Safety System',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              if (_isChecking)
                const CircularProgressIndicator(color: AppColors.secondary)
              else if (_failed) ...[
                const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(_status, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.redAccent)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _checkConnectivity,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Retry Connection'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                  child: const Text('Proceed in Offline Mode'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
