import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:async';
import '../../models/farm.dart';
import '../../models/crop.dart';
import '../../services/farm_service.dart';
import '../../services/crop_service.dart';

class FarmDetailsScreen extends StatefulWidget {
  final String farmId;

  const FarmDetailsScreen({
    Key? key,
    required this.farmId,
  }) : super(key: key);

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  late GoogleMapController _mapController;
  bool _isMapReady = false;
  bool _isLoading = true;
  Farm? _farm;
  List<Crop> _crops = [];
  LatLng _farmLocation = const LatLng(0, 0);
  final FarmService _farmService = FarmService();
  final CropService _cropService = CropService();

  // Mock health score for demonstration
  final int _healthScore = 90;

  // Hard-coded fallback locations for common areas
  final Map<String, LatLng> _knownLocations = {
    'tharaka-nithi': LatLng(-0.3031, 38.0526),
    'tharaka nithi': LatLng(-0.3031, 38.0526),
    'nairobi': LatLng(-1.2921, 36.8219),
    'mombasa': LatLng(-4.0435, 39.6682),
    'kisumu': LatLng(-0.1022, 34.7617),
    'nakuru': LatLng(-0.3031, 36.0800),
    'eldoret': LatLng(0.5143, 35.2698),
  };

  @override
  void initState() {
    super.initState();
    _loadFarmDetails();
  }

  Future<void> _loadFarmDetails() async {
    setState(() {
      _isLoading = true;
    });

    // Get farm details from the service
    final farm = await _farmService.getFarm(widget.farmId, context);

    if (farm != null) {
      setState(() {
        _farm = farm;
      });

      // Try to resolve the location
      await _resolveLocation(farm.location);

      // Load crops for this farm
      await _loadCrops();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCrops() async {
    final crops = await _cropService.getCropsByFarm(widget.farmId, context);
    setState(() {
      _crops = crops;
    });
  }

  Future<void> _resolveLocation(String locationName) async {
    if (locationName.isEmpty) {
      _setDefaultLocation('Empty location name');
      return;
    }

    final locationLower = locationName.toLowerCase().trim();

    for (final entry in _knownLocations.entries) {
      if (locationLower.contains(entry.key)) {
        setState(() {
          _farmLocation = entry.value;
        });
        print('Found location in known places: ${entry.key}');
        return;
      }
    }

    // Fallback approach 1:
    try {
      // Wrap in a timeout to avoid hanging
      await Future.delayed(const Duration(milliseconds: 100));

      await Future.any([
        _tryGeocodingService(locationName),
        Future.delayed(const Duration(seconds: 5), () {
          throw TimeoutException('Geocoding service timed out');
        })
      ]);
    } catch (e) {
      print('Location resolution failed: $e');

      // Fallback approach 2
      await _deduceLocationFromName(locationName);
    }
  }

  Future<void> _tryGeocodingService(String locationName) async {
    try {
      List<Location> locations = await locationFromAddress(locationName);

      if (locations.isNotEmpty) {
        setState(() {
          _farmLocation = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
        });
        print('Found location using geocoding service');
      } else {
        throw Exception('No locations found');
      }
    } catch (e) {
      // Let the error propagate to the caller
      throw Exception('Geocoding service failed: $e');
    }
  }

  Future<void> _deduceLocationFromName(String locationName) async {
    // Kenya-specific heuristics
    // Check if it contains county names and use a default position
    final kenyaCounties = {
      'nairobi': LatLng(-1.2921, 36.8219),
      'kiambu': LatLng(-1.1712, 36.8356),
      'nakuru': LatLng(-0.3031, 36.0800),
      'mombasa': LatLng(-4.0435, 39.6682),
      'kisumu': LatLng(-0.1022, 34.7617),
      'tharaka': LatLng(-0.3031, 38.0526),
      'nithi': LatLng(-0.3031, 38.0526),
      'uasin gishu': LatLng(0.5143, 35.2698),
      'machakos': LatLng(-1.5177, 37.2634),
      'nyeri': LatLng(-0.4246, 36.9578),
      'meru': LatLng(0.0465, 37.6583),
    };

    final locationLower = locationName.toLowerCase().trim();

    for (final entry in kenyaCounties.entries) {
      if (locationLower.contains(entry.key)) {
        setState(() {
          _farmLocation = entry.value;
        });
        print('Found location using Kenya county heuristics: ${entry.key}');
        return;
      }
    }

    // If all else fails, use a central location in Kenya
    _setDefaultLocation('County not recognized');
  }

  void _setDefaultLocation(String reason) {
    print('Using default location: $reason');
    setState(() {
      _farmLocation = const LatLng(-0.0236, 37.9062); // Central Kenya
    });

    // Show error to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not locate "${_farm?.location ?? "Unknown"}" on map. Using approximate location.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showCropsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.grass, color: Colors.green),
              SizedBox(width: 8),
              Text('Farm Crops'),
            ],
          ),
          content: _crops.isEmpty
              ? const Text('No crops planted in this farm yet.')
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _crops.map((crop) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crop.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Type: ${crop.type}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add Crop'),
              onPressed: () {
                Navigator.of(context).pop();
                // You can add navigation to crop creation screen here
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add crop feature coming soon'))
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Farm Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_farm == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Farm Details')),
        body: const Center(child: Text('Farm not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_farm!.name),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFarmDetails,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing farm details...'))
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [

            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _farmLocation,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      setState(() {
                        _isMapReady = true;
                      });


                      _mapController.setMapStyle('''
                        [
                          {
                            "elementType": "geometry",
                            "stylers": [
                              {
                                "color": "#f5f5f5"
                              }
                            ]
                          },
                          {
                            "elementType": "labels.text.fill",
                            "stylers": [
                              {
                                "color": "#616161"
                              }
                            ]
                          }
                        ]
                      ''');
                    },
                    markers: {
                      Marker(
                        markerId: MarkerId(widget.farmId),
                        position: _farmLocation,
                        infoWindow: InfoWindow(title: _farm!.name),
                      ),
                    },
                    mapType: MapType.hybrid,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: true,
                  ),

                  // Map controls overlay
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Column(
                      children: [
                        // Zoom in button
                        FloatingActionButton.small(
                          heroTag: 'zoomIn',
                          onPressed: () {
                            if (_isMapReady) {
                              _mapController.animateCamera(
                                CameraUpdate.zoomIn(),
                              );
                            }
                          },
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 8),
                        // Zoom out button
                        FloatingActionButton.small(
                          heroTag: 'zoomOut',
                          onPressed: () {
                            if (_isMapReady) {
                              _mapController.animateCamera(
                                CameraUpdate.zoomOut(),
                              );
                            }
                          },
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          child: const Icon(Icons.remove),
                        ),
                        const SizedBox(height: 8),
                        // My location button
                        FloatingActionButton.small(
                          heroTag: 'myLocation',
                          onPressed: () {
                            if (_isMapReady) {
                              _mapController.animateCamera(
                                CameraUpdate.newLatLng(_farmLocation),
                              );
                            }
                          },
                          backgroundColor: Colors.white,
                          foregroundColor: theme.primaryColor,
                          child: const Icon(Icons.my_location),
                        ),
                      ],
                    ),
                  ),


                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.crop_square,
                            color: theme.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Farm Boundary',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _farm!.totalArea,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Farm details section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Farm details header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Farm Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Updated recently',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Farm details grid
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Size info card
                      _buildInfoCard(
                        context: context,
                        title: 'Size',
                        value: _farm!.totalArea,
                        icon: Icons.crop_square,
                        color: Colors.orange,
                      ),

                      // Location info card
                      _buildInfoCard(
                        context: context,
                        title: 'Location',
                        value: _farm!.location,
                        icon: Icons.location_on,
                        color: Colors.red,
                      ),


                      _buildClickableCropsCard(context),


                      _buildHealthScoreCard(context),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildClickableCropsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: _showCropsDialog,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? theme.cardTheme.color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.grass,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Crops',
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_crops.length}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _crops.isEmpty
                        ? 'No crops'
                        : _crops.length == 1
                        ? _crops.first.name
                        : '${_crops.first.name} +${_crops.length - 1} more',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  HugeIcons.strokeRoundedCircleArrowMoveUpRight,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define health score color based on value
    Color getHealthColor(int score) {
      if (score >= 80) return Colors.green;
      if (score >= 60) return Colors.orange;
      return Colors.red;
    }

    final scoreColor = getHealthColor(_healthScore);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monitor_heart,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Health Score',
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$_healthScore',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: scoreColor,
                ),
              ),
              Text(
                '/100',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _healthScore / 100,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}