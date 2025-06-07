import 'package:logger/logger.dart';
import '../models/report_statistics.dart';
import '../models/report.dart';
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

  static Future<List<Report>> getReportsByTrackingId(String trackingId) async {
    _logger.i('Fetching reports by tracking ID: $trackingId');

    try {
      final response = await BaseNetwork.get(
        '/public/reports/track/$trackingId',
      );
      _logger.d('Reports by tracking ID response: $response');

      if (response is List) {
        List<Report> reports = [];
        for (var json in response) {
          try {
            if (json is Map<String, dynamic>) {
              _logger.d('Parsing report JSON: $json');
              reports.add(Report.fromJson(json));
            }
          } catch (e) {
            _logger.e('Error parsing individual report: $e');
            _logger.e('Problematic JSON: $json');
            // Continue processing other reports instead of failing completely
          }
        }
        _logger.i('Successfully parsed ${reports.length} reports');
        return reports;
      } else {
        _logger.w(
          'Unexpected response type for reports list, returning empty list',
        );
        return []; // Return empty list for unexpected response types
      }
    } catch (e) {
      _logger.e('Error fetching reports by tracking ID: $e');
      // If it's a "no reports found" case, return empty list instead of throwing
      if (e.toString().contains('Tidak ada aduan ditemukan') ||
          e.toString().contains('404')) {
        _logger.i('No reports found for tracking ID, returning empty list');
        return [];
      }
      rethrow;
    }
  }

  static Future<DetailedReport> getReportById(int reportId) async {
    _logger.i('Fetching report by ID: $reportId');

    try {
      final response = await BaseNetwork.get('/public/reports/$reportId');
      _logger.d('Report by ID response: $response');

      if (response is Map<String, dynamic>) {
        _logger.d('Parsing detailed report JSON: $response');
        return DetailedReport.fromJson(response);
      } else {
        throw Exception('Expected object response for report');
      }
    } catch (e) {
      _logger.e('Error fetching report by ID: $e');
      rethrow;
    }
  }
}
