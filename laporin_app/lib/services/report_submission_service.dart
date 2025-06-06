import 'dart:io';
import 'package:logger/logger.dart';
import '../models/report.dart';
import 'base_network.dart';

class ReportSubmissionService {
  static final Logger _logger = Logger();

  static Future<Map<String, dynamic>> submitReport(Report report) async {
    _logger.i('Submitting report: ${report.title}');

    if (report.imageFile == null) {
      throw Exception('Image file is required');
    }

    try {
      // Prepare form fields
      final Map<String, String> fields = {
        'title': report.title,
        'description': report.description,
        'category_id': report.categoryId.toString(),
        'reporter_name': report.reporterName,
        'reporter_contact': report.reporterContact,
        'location': report.location,
      };

      // Add optional agency_id field
      if (report.agencyId != null) {
        fields['agency_id'] = report.agencyId.toString();
      }

      // Prepare files
      final Map<String, File> files = {'image': report.imageFile!};

      if (report.attachmentFile != null) {
        files['lampiran'] = report.attachmentFile!;
      }

      final response = await BaseNetwork.postMultipart(
        '/public/reports',
        fields,
        files,
      );

      _logger.i('Report submitted successfully');
      return response;
    } catch (e) {
      _logger.e('Error submitting report: $e');
      rethrow;
    }
  }
}
