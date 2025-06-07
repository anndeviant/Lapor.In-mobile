import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class BaseNetwork {
  static const String _baseUrl = 'http://192.168.0.108:5000';
  static final Logger _logger = Logger();

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_baseUrl$endpoint');

    _logger.d('POST Request to: $url');
    _logger.d('Request data: $data');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        try {
          final decodedResponse = jsonDecode(response.body);
          if (decodedResponse == null) {
            throw Exception('Null response from server');
          }
          return decodedResponse;
        } catch (e) {
          throw Exception('Invalid JSON response: ${response.body}');
        }
      } else {
        String errorMessage = 'Server error';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? 'Server error';
        } catch (e) {
          errorMessage = 'Server returned status ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.e('Network error: $e');
      rethrow;
    }
  }

  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');

    _logger.d('GET Request to: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        return decodedResponse; // Return dynamic to handle both Map and List
      } else if (response.statusCode == 404 &&
          endpoint.contains('/public/reports/track/')) {
        // Special handling for tracking endpoint when no reports found
        _logger.i('No reports found for tracking ID - returning empty list');
        return []; // Return empty list instead of throwing error
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? errorData['msg'] ?? 'Server error',
        );
      }
    } catch (e) {
      _logger.e('Network error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, File> files,
  ) async {
    final url = Uri.parse('$_baseUrl$endpoint');

    _logger.d('POST Multipart Request to: $url');
    _logger.d('Fields: $fields');
    _logger.d('Files: ${files.keys.toList()}');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add fields
      request.fields.addAll(fields);

      // Add files
      for (var entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        try {
          final decodedResponse = jsonDecode(response.body);
          if (decodedResponse == null) {
            throw Exception('Null response from server');
          }
          return decodedResponse;
        } catch (e) {
          throw Exception('Invalid JSON response: ${response.body}');
        }
      } else {
        String errorMessage = 'Server error';
        try {
          // Check if response body starts with HTML
          if (response.body.trim().startsWith('<!DOCTYPE') ||
              response.body.trim().startsWith('<html')) {
            errorMessage =
                'Server returned HTML error page. Status: ${response.statusCode}';
          } else {
            final errorData = jsonDecode(response.body);
            errorMessage =
                errorData['msg'] ?? errorData['message'] ?? 'Server error';
          }
        } catch (e) {
          errorMessage =
              'Server returned status ${response.statusCode}. Response: ${response.body.length > 100 ? '${response.body.substring(0, 100)}...' : response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.e('Network error: $e');
      rethrow;
    }
  }
}
