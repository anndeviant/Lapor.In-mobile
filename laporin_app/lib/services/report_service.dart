import 'package:logger/logger.dart';
import '../models/report_statistics.dart';
import 'base_network.dart';

class ReportService {
  static final Logger _logger = Logger();

  static Future<ReportStatistics> getReportStatistics() async {
    _logger.i('Fetching report statistics');

    try {
      final response = await BaseNetwork.get('/public/statistics');
      _logger.d('Report statistics response: $response');

      // Ensure response is a Map for statistics
      if (response is Map<String, dynamic>) {
        return ReportStatistics.fromJson(response);
      } else {
        throw Exception('Expected object response for statistics');
      }
    } catch (e) {
      _logger.e('Error fetching report statistics: $e');
      rethrow;
    }
  }
}
