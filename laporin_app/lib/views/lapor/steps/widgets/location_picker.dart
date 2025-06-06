import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../services/location_service.dart';

class LocationPicker extends StatefulWidget {
  final String initialLocation;
  final Function(String) onLocationSelected;

  const LocationPicker({
    super.key,
    required this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final _manualLocationController = TextEditingController();
  bool _isLoading = false;
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(
    -6.175392,
    106.827153,
  ); // Default to Jakarta
  Set<Marker> _markers = {};
  bool _isMapReady = false;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _manualLocationController.text = widget.initialLocation;

    // Try to parse initial location if it's in coordinates format
    if (widget.initialLocation.contains('Lat:') &&
        widget.initialLocation.contains('Lng:')) {
      try {
        final parts = widget.initialLocation.split(', ');
        if (parts.length == 2) {
          final lat = double.parse(parts[0].replaceAll('Lat: ', ''));
          final lng = double.parse(parts[1].replaceAll('Lng: ', ''));
          _selectedLocation = LatLng(lat, lng);
        }
      } catch (e) {
        // Use default location if parsing fails
      }
    }

    // Initialize map marker
    _updateMarker();

    // Get current location if initial is empty
    if (widget.initialLocation.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
      });
    }
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          draggable: true,
          onDragEnd: (LatLng position) {
            _handleMapLocationChange(position);
          },
        ),
      };
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        // Update map position
        _updateMapLocation(LatLng(position.latitude, position.longitude));

        // Always try to get address, service will return coordinates as fallback
        final locationText = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _manualLocationController.text = locationText;
        });

        // Show info if we got coordinates instead of address
        if (locationText.startsWith('Lat:') && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Google Maps address lookup unavailable. Showing coordinates instead.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMapLocation(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _updateMarker();

      if (_isMapReady && _mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(position));
      }
    });
  }

  // Fixed bug: Make sure marker updates when map is clicked
  Future<void> _handleMapLocationChange(LatLng position) async {
    setState(() {
      _isLoading = true;
      _selectedLocation = position;
      _updateMarker(); // Add this to fix the bug - update marker when map is clicked
    });

    try {
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _manualLocationController.text = address;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get address: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal
              ? MapType.satellite
              : MapType.normal;
    });
  }

  Future<void> _searchLocation() async {
    if (_manualLocationController.text.isEmpty) return;

    final FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final locations = await LocationService.getCoordinatesFromAddress(
        _manualLocationController.text,
      );

      if (locations.isNotEmpty) {
        final location = locations.first;
        final position = LatLng(location.latitude, location.longitude);
        _updateMapLocation(position);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location not found: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmLocation() {
    if (_manualLocationController.text.isNotEmpty) {
      widget.onLocationSelected(_manualLocationController.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map view with enhanced controls
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 15,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: _currentMapType,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) {
                    setState(() {
                      _mapController = controller;
                      _isMapReady = true;
                    });
                  },
                  onTap: _handleMapLocationChange,
                ),

                // Map controls overlay
                Positioned(
                  right: 16,
                  top: 16,
                  child: Column(
                    children: [
                      // Map type toggle button
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: _toggleMapType,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _currentMapType == MapType.normal
                                  ? Icons.satellite_alt
                                  : Icons.map,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Zoom in button
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            _mapController?.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.add, color: Colors.blue.shade700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Zoom out button
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            _mapController?.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.remove,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // // Central marker hint
                // if (!_isLoading)
                //   Positioned(
                //     bottom: 90,
                //     left: 0,
                //     right: 0,
                //     child: Center(
                //       child: Card(
                //         color: Colors.black.withOpacity(0.7),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(20),
                //         ),
                //         child: const Padding(
                //           padding: EdgeInsets.symmetric(
                //             horizontal: 12,
                //             vertical: 6,
                //           ),
                //           child: Text(
                //             'Tap or drag to select location',
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 13,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),

                // Loading indicator - improved
                if (_isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 12),
                              Text(
                                'Loading location...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Location selection panel - redesigned for professional look
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panel header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            'Choose or search a location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Current location button - redesigned
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getCurrentLocation,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.my_location, size: 20),
                    label: Text(
                      _isLoading
                          ? 'Getting Location...'
                          : 'Use Current Location',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Search location field with button - enhanced
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search for a location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    InkWell(
                      onTap: _isLoading ? null : _searchLocation,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Icon(
                          Icons.search,
                          color: Colors.blue.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Search',
                          style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          ),
                        ),
                        ],
                      ),
                      ),
                    ),
                    ],
                  ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _manualLocationController,
                    decoration: InputDecoration(
                      hintText: 'Enter address or place name',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.blue.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 2,
                  ),
                ),

                const SizedBox(height: 20),

                // Confirm Button - enhanced
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _confirmLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.green.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirm Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _manualLocationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
