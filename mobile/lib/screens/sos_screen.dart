import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import '../providers/isar_provider.dart';
import '../services/sos_service.dart';
import '../models/sos_request.dart';
import '../screens/safety_settings_screen.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class SOSScreen extends ConsumerStatefulWidget {
  const SOSScreen({super.key});

  @override
  ConsumerState<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends ConsumerState<SOSScreen> with TickerProviderStateMixin {
  late AnimationController _holdController;
  bool _isSending = false;
  bool _showCountdown = false;
  int _countdownSeconds = 5;
  Timer? _countdownTimer;
  Timer? _statusPollingTimer;
  
  String _statusMessage = 'Initiate Sacred Protection';
  String _currentStatus = 'none'; // none, pending, sent, received, dispatched
  String? _responderName;
  Position? _currentPosition;
  
  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _startCountdown();
        }
      });
    _startStatusPolling();
  }

  @override
  void dispose() {
    _holdController.dispose();
    _countdownTimer?.cancel();
    _statusPollingTimer?.cancel();
    super.dispose();
  }

  void _startStatusPolling() {
    _statusPollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final isar = await ref.read(isarProvider.future);
      final latestPulse = await isar.sOSRequests.where().sortByCreatedAtDesc().findFirst();
      
      if (latestPulse != null && mounted) {
        setState(() {
          _currentStatus = latestPulse.status;
          _responderName = latestPulse.responderName;
          
          if (_currentStatus == 'pending') _statusMessage = 'Connecting to Divine Shield...';
          if (_currentStatus == 'sent') _statusMessage = 'Request Sent to Authorities.';
          if (_currentStatus == 'received') _statusMessage = 'Control Center Ack.';
          if (_currentStatus == 'dispatched') _statusMessage = 'Commanders Dispatched!';
        });
      }
    });
  }

  void _startCountdown() {
    HapticFeedback.heavyImpact();
    setState(() {
      _showCountdown = true;
      _countdownSeconds = 5;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        setState(() => _countdownSeconds--);
        HapticFeedback.selectionClick();
      } else {
        _countdownTimer?.cancel();
        setState(() => _showCountdown = false);
        _executeSOS();
      }
    });
  }

  void _cancelSOS() {
    _countdownTimer?.cancel();
    _holdController.reset();
    setState(() {
      _showCountdown = false;
      _statusMessage = 'Sacred Protection Deferred';
      _currentStatus = 'none';
    });
    HapticFeedback.vibrate();
  }

  Future<void> _executeSOS() async {
    setState(() {
      _isSending = true;
      _statusMessage = 'Syncing Sacred Location...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 30),
      );

      final isar = await ref.read(isarProvider.future);
      final service = SosService(isar);
      
      await service.triggerSOS(
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
        altitude: _currentPosition?.altitude,
        category: 'GENERAL',
      );

      setState(() {
        _statusMessage = 'SOS Pulse Active.';
        _currentStatus = 'pending';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isSending = false);
    }
  }

  Widget _buildStatusFeedback() {
    if (_currentStatus == 'none') return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.sanctuaryCardDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatusIcon(label: 'SENT', isActive: _currentStatus != 'none' && _currentStatus != 'pending', icon: Icons.cloud_done_outlined),
              _StatusIcon(label: 'ACKNOWLEDGED', isActive: _currentStatus == 'received' || _currentStatus == 'dispatched', icon: Icons.check_circle_outline),
              _StatusIcon(label: 'HELP ACTIVE', isActive: _currentStatus == 'dispatched', icon: Icons.security, isPulsing: _currentStatus == 'dispatched'),
            ],
          ),
          if (_responderName != null) ...[
            const SizedBox(height: 20),
            Text(
              'Commander assigned: $_responderName',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Sacred Protection', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: AppColors.secondary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SafetySettingsScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Emergency SOS',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.alert),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'HOLD SOS ICON TO SUMMON ASSISTANCE',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 64),
                  GestureDetector(
                    onLongPressStart: (_) => _isSending ? null : _holdController.forward(),
                    onLongPressEnd: (_) => _holdController.reverse(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: AnimatedBuilder(
                            animation: _holdController,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value: _holdController.value,
                                strokeWidth: 10,
                                color: AppColors.alert,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 230,
                          height: 230,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.alert, Color(0xFF9E1B1B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: AppColors.alert.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10),
                            ],
                          ),
                          child: Center(
                            child: _isSending
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'SOS',
                                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
                  ),
                  _buildStatusFeedback(),
                ],
              ),
            ),
          ),
          if (_showCountdown)
            Container(
              color: AppColors.onSurface.withValues(alpha: 0.95),
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SHIELD ACTIVE IN',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, letterSpacing: 4),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '$_countdownSeconds',
                    style: GoogleFonts.notoSerif(color: AppColors.alert, fontSize: 160, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 300,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: _cancelSOS,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.alert,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        elevation: 20,
                      ),
                      child: const Text('CANCEL PROTECTION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData icon;
  final bool isPulsing;

  const _StatusIcon({required this.label, required this.isActive, required this.icon, this.isPulsing = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: isActive ? Colors.green : Colors.grey[400], size: 32),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.grey[400])),
      ],
    );
  }
}
