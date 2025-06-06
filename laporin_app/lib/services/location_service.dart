import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class LocationService {
  static final Logger _logger = Logger();
  static final Dio _dio = Dio();
  static String? _googleApiKey;

  static Future<String> _getGoogleApiKey() async {
    if (_googleApiKey != null) return _googleApiKey!;

    try {
      const platform = MethodChannel('com.example.laporin_app/config');
      _googleApiKey = await platform.invokeMethod('getGoogleApiKey');
      return _googleApiKey!;
    } catch (e) {
      _logger.e('Error getting Google API key from manifest: $e');
      throw Exception('Failed to get Google API key');
    }
  }

  static Future<bool> checkLocationPermission() async {
    _logger.i('Checking location permission');

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _logger.w('Location permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.w('Location permission denied forever');
      return false;
    }

    _logger.i('Location permission granted');
    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    _logger.i('Getting current location');

    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission not granted');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _logger.d(
        'Current location: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      _logger.e('Error getting current location: $e');
      rethrow;
    }
  }

  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    _logger.i(
      'Getting address from coordinates using Google Maps API: $latitude, $longitude',
    );

    try {
      final googleApiKey = await _getGoogleApiKey();
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=$latitude,$longitude'
          '&key=$googleApiKey'
          '&language=id';

      _logger.d('Google Maps API URL: $url');

      final response = await _dio.get(url);

      _logger.d('Google Maps API Response Status: ${response.statusCode}');
      _logger.d('Google Maps API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final formattedAddress = result['formatted_address'] as String;

          _logger.d('Address from Google Maps: $formattedAddress');
          return formattedAddress;
        } else {
          _logger.w('Google Maps API Error - Status: ${data['status']}');
          if (data['error_message'] != null) {
            _logger.w('Error Message: ${data['error_message']}');
          }
          return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
        }
      } else {
        _logger.e('Google Maps API HTTP error: ${response.statusCode}');
        return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
      }
    } catch (e) {
      _logger.e('Error getting address from Google Maps API: $e');
      // Return coordinates as fallback when API fails
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    }
  }

  static Future<List<Location>> getCoordinatesFromAddress(
    String address,
  ) async {
    _logger.i(
      'Getting coordinates from address using Google Maps API: $address',
    );

    try {
      final googleApiKey = await _getGoogleApiKey();
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?address=${Uri.encodeComponent(address)}'
          '&key=$googleApiKey'
          '&language=id';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final List<Location> locations = [];

          for (var result in data['results']) {
            final location = result['geometry']['location'];
            locations.add(
              Location(
                latitude: location['lat'].toDouble(),
                longitude: location['lng'].toDouble(),
                timestamp: DateTime.now(),
              ),
            );
          }

          _logger.d('Coordinates found: ${locations.length}');
          return locations;
        } else {
          _logger.w(
            'No coordinates found from Google Maps API: ${data['status']}',
          );
          if (data['error_message'] != null) {
            _logger.w('Error Message: ${data['error_message']}');
          }
          throw Exception('No coordinates found for address: $address');
        }
      } else {
        throw Exception('Google Maps API error: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error getting coordinates from Google Maps API: $e');
      rethrow;
    }
  }

  static Future<bool> isGeocodingServiceAvailable() async {
    try {
      final googleApiKey = await _getGoogleApiKey();
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=0,0'
          '&key=$googleApiKey';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        // Even if the result is empty, if status is not REQUEST_DENIED, the service is available
        return data['status'] != 'REQUEST_DENIED';
      }
      return false;
    } catch (e) {
      _logger.e('Google Maps Geocoding API not available: $e');
      return false;
    }
  }
}
