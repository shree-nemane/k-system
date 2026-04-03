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
  
  String _statusMessage = 'Emergency Assistance';
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
          
          if (_currentStatus == 'pending') _statusMessage = 'Queuing SOS Pulse...';
          if (_currentStatus == 'sent') _statusMessage = 'Sent. Waiting for Authority Ack.';
          if (_currentStatus == 'received') _statusMessage = 'Received by Control Center.';
          if (_currentStatus == 'dispatched') _statusMessage = 'Help Dispatched!';
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
      _statusMessage = 'SOS Cancelled';
      _currentStatus = 'none';
    });
    HapticFeedback.vibrate();
  }

  Future<void> _executeSOS() async {
    setState(() {
      _isSending = true;
      _statusMessage = 'Capturing Location...';
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
        _statusMessage = 'SOS Pulse Initiated.';
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
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatusIcon(label: 'SENT', isActive: _currentStatus != 'none' && _currentStatus != 'pending', icon: Icons.cloud_upload),
              _StatusIcon(label: 'RECEIVED', isActive: _currentStatus == 'received' || _currentStatus == 'dispatched', icon: Icons.assignment_turned_in),
              _StatusIcon(label: 'HELP ON WAY', isActive: _currentStatus == 'dispatched', icon: Icons.local_police, isPulsing: _currentStatus == 'dispatched'),
            ],
          ),
          if (_responderName != null) ...[
            const SizedBox(height: 16),
            Text(
              'Responder: $_responderName',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Safety'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Emergency SOS',
                    style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'HOLD SOS BUTTON TO ALERT AUTHORITIES',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 64),
                  GestureDetector(
                    onLongPressStart: (_) => _isSending ? null : _holdController.forward(),
                    onLongPressEnd: (_) => _holdController.reverse(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: AnimatedBuilder(
                            animation: _holdController,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value: _holdController.value,
                                strokeWidth: 12,
                                color: Colors.redAccent,
                                backgroundColor: Colors.grey[200],
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: _isSending ? Colors.grey : Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.redAccent.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 10),
                            ],
                          ),
                          child: Center(
                            child: _isSending
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'SOS',
                                    style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white),
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
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                  ),
                  _buildStatusFeedback(),
                ],
              ),
            ),
          ),
          if (_showCountdown)
            Container(
              color: Colors.black.withValues(alpha: 0.9),
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SOS TRIGGERING IN',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 20, letterSpacing: 2),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$_countdownSeconds',
                    style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 120, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 280,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: _cancelSOS,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CANCEL SOS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
