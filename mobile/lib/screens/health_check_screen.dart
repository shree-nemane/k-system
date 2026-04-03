import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      _status = 'Connecting to Divine Network...\nTarget: ${ApiClient().baseUrl}';
      _failed = false;
    });

    try {
      final client = ApiClient();
      final response = await client.get('/alerts/recent').timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _handleFailure('API Unreachable: ${response.statusCode}');
      }
    } catch (e) {
      _handleFailure('Connection suspended. Check your sacred connection.');
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, size: 84, color: AppColors.secondary),
              ),
              const SizedBox(height: 40),
              Text(
                'MahaKumbh 2027',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28, letterSpacing: -1),
              ),
              const SizedBox(height: 12),
              Text(
                'Digital Sanctuary Connectivity',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 64),
              if (_isChecking)
                const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)
              else if (_failed) ...[
                const Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.alert),
                const SizedBox(height: 24),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.alert),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _checkConnectivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text('RETRY CONNECTION', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
                  child: const Text('PROCEED IN OFFLINE MEDITATION', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
