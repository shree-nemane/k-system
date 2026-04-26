import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../services/location_service.dart';
import '../providers/navigation_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

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
  bool _showRoutes = false;
  LatLng? _userPosition;
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCache();
    _loadMapData();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _startLocationTracking() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    _locationSubscription = _locationService.locationStream.listen((position) {
      if (mounted) {
        setState(() {
          _userPosition = LatLng(position.latitude, position.longitude);
        });
      }
    });

    final initial = await _locationService.getCurrentLocation();
    if (initial != null && mounted) {
      setState(() {
        _userPosition = LatLng(initial.latitude, initial.longitude);
      });
    }
  }

  void _centerOnUser() {
    if (_userPosition != null) {
      _mapController.move(_userPosition!, 16);
    }
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
          final type = m['type'] as String;
          final isGhat = type == 'ghat';
          final point = LatLng(m['lat'], m['lng']);
          final name = m['name'];
          
          return Marker(
            point: point,
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showMarkerDetails(name, point),
              child: Icon(
                isGhat 
                    ? Icons.water_drop 
                    : type == 'hub' 
                        ? Icons.temple_hindu 
                        : Icons.place,
                color: isGhat ? Colors.blue : AppColors.primary,
                size: 30,
              ),
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

  void _showMarkerDetails(String name, LatLng point) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Point of Interest', style: GoogleFonts.inter(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  
                  // Find predefined route that contains this point or is close to it
                  List<LatLng> bestRoute = [];
                  for (var poly in _polylines) {
                    if (poly.points.any((p) => (p.latitude - point.latitude).abs() < 0.0001 && (p.longitude - point.longitude).abs() < 0.0001)) {
                      bestRoute = poly.points;
                      break;
                    }
                  }
                  
                  ref.read(navigationProvider.notifier).startNavigation(point, name, routePoints: bestRoute);
                },
                icon: const Icon(Icons.navigation, color: Colors.white),
                label: const Text('NAVIGATE HERE', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeCache() async {
    final store = FMTCStore(_storeName);
    try {
      if (!await store.manage.ready) {
        await store.manage.create();
      }
    } catch (e) {
      debugPrint('FMTC Store creation non-fatal error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              initialCenter: LatLng(20.0075, 73.7925),
              initialZoom: 14,
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
              if (_showRoutes) PolylineLayer(polylines: _polylines),
              Consumer(
                builder: (context, ref, child) {
                  final navState = ref.watch(navigationProvider);
                  if (navState.isNavigating && _userPosition != null && navState.destination != null) {
                    final points = navState.routePoints.isNotEmpty 
                        ? [_userPosition!, ...navState.routePoints] 
                        : [_userPosition!, navState.destination!];
                        
                    return PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          color: AppColors.primary,
                          strokeWidth: 4,
                          pattern: StrokePattern.dashed(segments: const [10, 5]),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              MarkerLayer(
                markers: [
                  ..._markers,
                  if (_userPosition != null)
                    Marker(
                      point: _userPosition!,
                      width: 50,
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
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

          // Layer & Location Controls
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'toggle_routes',
                  onPressed: () => setState(() => _showRoutes = !_showRoutes),
                  backgroundColor: _showRoutes ? AppColors.primary : Colors.white,
                  child: Icon(Icons.route, color: _showRoutes ? Colors.white : AppColors.primary),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'center_me',
                  onPressed: _centerOnUser,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),

          // Simple Navigation Banner
          Consumer(
            builder: (context, ref, child) {
              final navState = ref.watch(navigationProvider);
              if (!navState.isNavigating) return const SizedBox.shrink();
              
              return Positioned(
                top: 80,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.navigation, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          navState.instruction ?? '',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => ref.read(navigationProvider.notifier).stopNavigation(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
