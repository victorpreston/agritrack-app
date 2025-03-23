import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FarmDetailsScreen extends StatefulWidget {
  final String farmId;
  final String farmName;
  final LatLng farmLocation;

  const FarmDetailsScreen({
    Key? key,
    required this.farmId,
    required this.farmName,
    required this.farmLocation,
  }) : super(key: key);

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  late GoogleMapController _mapController;
  bool _isMapReady = false;

  // Mock farm data - Replace with actual data from your API
  final Map<String, dynamic> _farmData = {
    'size': '120 acres',
    'crops': ['Corn', 'Wheat', 'Soybeans'],
    'soil_type': 'Loamy',
    'last_updated': '2 hours ago',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farmName),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshing farm data...'))
              );
            },
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
      // Make the entire body scrollable
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Map container - Fixed height
            SizedBox(
              height: 300, // Fixed height for the map
              width: double.infinity,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.farmLocation,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      setState(() {
                        _isMapReady = true;
                      });

                      // Apply custom map style
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
                        position: widget.farmLocation,
                        infoWindow: InfoWindow(title: widget.farmName),
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
                                CameraUpdate.newLatLng(widget.farmLocation),
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

                  // Farm boundary indicator
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
                              _farmData['size'],
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
                        child: Text(
                          'Updated ${_farmData['last_updated']}',
                          style: TextStyle(
                            color: theme.primaryColor,
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
                        value: _farmData['size'],
                        icon: Icons.crop_square,
                        color: Colors.orange,
                      ),

                      // Soil type info card
                      _buildInfoCard(
                        context: context,
                        title: 'Soil Type',
                        value: _farmData['soil_type'],
                        icon: Icons.landscape,
                        color: Colors.brown,
                      ),

                      // Crops info card
                      _buildInfoCard(
                        context: context,
                        title: 'Main Crops',
                        value: (_farmData['crops'] as List).join(', '),
                        icon: Icons.grass,
                        color: Colors.green,
                      ),

                      // Health score info card
                      _buildInfoCard(
                        context: context,
                        title: 'Health Score',
                        value: '87/100',
                        icon: Icons.monitor_heart,
                        color: Colors.blue,
                      ),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}