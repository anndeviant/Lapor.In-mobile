import 'package:logger/logger.dart';
import '../models/government_agency.dart';
import 'base_network.dart';

class AgencyService {
  static final Logger _logger = Logger();

  static Future<List<GovernmentAgency>> getAgencies() async {
    _logger.i('Fetching government agencies');

    try {
      final response = await BaseNetwork.get('/public/agencies');
      _logger.d('Agencies response: $response');

      // Handle both array and object responses
      List<dynamic> agenciesData;

      if (response is List) {
        agenciesData = response;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          final data = response['data'];
          if (data is List) {
            agenciesData = data;
          } else if (data is Map) {
            agenciesData = [data];
          } else {
            throw Exception('Unexpected data format');
          }
        } else if (response.containsKey('agencies')) {
          final agencies = response['agencies'];
          if (agencies is List) {
            agenciesData = agencies;
          } else if (agencies is Map) {
            agenciesData = [agencies];
          } else {
            throw Exception('Unexpected agencies format');
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Unexpected response format');
      }

      return agenciesData
          .map((json) => GovernmentAgency.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error fetching agencies: $e');
      rethrow;
    }
  }
}
