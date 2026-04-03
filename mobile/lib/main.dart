import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:workmanager/workmanager.dart';
import 'services/workmanager_callback.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/alerts_screen.dart';
import 'screens/sos_screen.dart';
import 'screens/health_check_screen.dart';
import 'screens/smart_hubs_screen.dart';
import 'screens/guide_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager for SOS background retries
  Workmanager().initialize(
    callbackDispatcher,
  );
  
  // 1. Initialize FMTC for Offline Mapping
  try {
    await FMTCObjectBoxBackend().initialise();
  } catch (e) {
    debugPrint('Offline Map Caching (FMTC) failed to initialize: $e');
  }

  // 2. Initialize DotEnv for API Connectivity
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Config Loaded: ${dotenv.get('API_BASE_URL', fallback: 'Not Found')}');
  } catch (e) {
    debugPrint('Error loading .env: $e');
  }

  runApp(const ProviderScope(child: MahaKumbhApp()));
}

class MahaKumbhApp extends StatelessWidget {
  const MahaKumbhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MahaKumbh 2027 Digital Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE6A85C), // Saffron accent
          primary: const Color(0xFF2E5B7F), // Deep Blue
        ),
      ),
      // Initial route starts with the spiritual onboarding
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/home': (context) => const MainScaffold(),
        '/alerts': (context) => const AlertsScreen(),
        '/sos': (context) => const SOSScreen(), // Now a ConsumerStatefulWidget
        '/health': (context) => const HealthCheckScreen(),
        '/hubs': (context) => const SmartHubsScreen(),
        '/guide': (context) => const GuideScreen(),
      },
    );
  }
}
