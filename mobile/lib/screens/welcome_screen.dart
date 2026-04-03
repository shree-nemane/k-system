import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isRequesting = false;

  Future<void> _getStarted() async {
    setState(() => _isRequesting = true);
    
    // Explicitly request GPS permissions at startup
    final status = await Permission.locationWhenInUse.request();
    
    if (!mounted) return;

    if (status.isGranted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required for the digital guide.')),
      );
      setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background - Sacred Horizon Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, Color(0xFFD4A017)], // Saffron to Gold
              ),
            ),
          ),
          // Subtle Texture Overlay (Optional, using Opacity for now)
          Opacity(
            opacity: 0.1,
            child: Container(color: Colors.white),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.auto_awesome, size: 80, color: Colors.white70),
                  const SizedBox(height: 40),
                  Text(
                    'MahaKumbh 2027',
                    style: GoogleFonts.notoSerif(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your sacred journey, guided by wisdom and secured by AI.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.6,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: ElevatedButton(
                      onPressed: _isRequesting ? null : _getStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                        elevation: 10,
                        shadowColor: Colors.black26,
                      ),
                      child: _isRequesting 
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : Text(
                            'BEGIN YOUR YATRA', 
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Prayagraj • The Holy Confluence',
                    style: GoogleFonts.manrope(
                      fontSize: 14, 
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
