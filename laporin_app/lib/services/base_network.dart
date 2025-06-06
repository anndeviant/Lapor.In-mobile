import 'dart:convert';
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

  static Future<Map<String, dynamic>> get(String endpoint) async {
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
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Server error');
      }
    } catch (e) {
      _logger.e('Network error: $e');
      rethrow;
    }
  }
}
