import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../providers/crowd_provider.dart';

class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({super.key});

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen> {
  final MapController _mapController = MapController();
  final String _storeName = AppConstants.tileStoreName;

  List<Polygon> _polygons = [];
  List<Polyline> _polylines = [];
  List<Marker> _markers = [];
  bool _isDataLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCache();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/map_data.json');
      final data = json.decode(response);
      
      setState(() {
        _polygons = (data['sectors'] as List).map((s) {
          final points = (s['points'] as List).map((p) => LatLng(p['lat'], p['lng'])).toList();
          return Polygon(
            points: points,
            color: Color(int.parse(s['color'].substring(2), radix: 16)).withValues(alpha: 0.3),
            borderStrokeWidth: 2,
            borderColor: Color(int.parse(s['color'].substring(2), radix: 16)),
            label: s['name'],
          );
        }).toList();

        _polylines = (data['routes'] as List).map((r) {
          final path = (r['path'] as List).map((p) => LatLng(p['lat'], p['lng'])).toList();
          return Polyline(
            points: path,
            color: Color(int.parse(r['color'].substring(2), radix: 16)),
            strokeWidth: 4,
          );
        }).toList();

        _markers = (data['markers'] as List).map((m) {
          final isGhat = m['type'] == 'ghat';
          return Marker(
            point: LatLng(m['lat'], m['lng']),
            width: 40,
            height: 40,
            child: Icon(
              isGhat ? Icons.water_drop : Icons.help_center,
              color: isGhat ? Colors.blue : AppColors.primary,
              size: 30,
            ),
          );
        }).toList();
      });

      if (!mounted) return;
      setState(() {
        debugPrint('Map Data Loaded Successfuly: ${_polygons.length} polygons, ${_polylines.length} polylines');
        _isDataLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load map data: $e');
      if (mounted) {
        setState(() => _isDataLoading = false);
      }
    }
  }

  Future<void> _initializeCache() async {
    final store = FMTCStore(_storeName);
    await store.manage.create();
  }

  @override
  Widget build(BuildContext context) {
    final globalDensity = ref.watch(globalDensityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MahaKumbh Explorer',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(25.45, 81.85),
              initialZoom: 13,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mahakumbh.app',
                tileProvider: FMTCStore(_storeName).getTileProvider(),
              ),
              PolygonLayer(polygons: _polygons),
              PolylineLayer(polylines: _polylines),
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_isDataLoading)
            const Center(child: CircularProgressIndicator()),
          
          // Connection & Offline status
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'OFFLINE READY',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),

          // Crowd Density Overlay
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Text('GLOBAL DENSITY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(
                    '${(globalDensity * 100).toInt()}%',
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: _getDensityColor(globalDensity)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => Navigator.pushNamed(context, '/sos'),
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.emergency_outlined, size: 80, color: Colors.white),
      ),
    );
  }


  Color _getDensityColor(double density) {
    if (density > 0.8) return Colors.red;
    if (density > 0.5) return Colors.orange;
    return Colors.green;
  }
}
