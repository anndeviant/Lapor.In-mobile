import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/report.dart';

class ReportStorage {
  static const String _reportDraftKey = 'report_draft';
  static const String _reportImagePathKey = 'report_image_path';
  static const String _reportAttachmentPathKey = 'report_attachment_path';
  static final Logger _logger = Logger();

  static Future<void> saveDraft(Report report) async {
    _logger.d('Saving report draft');

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save report data
      await prefs.setString(_reportDraftKey, jsonEncode(report.toJson()));

      // Handle image file
      if (report.imageFile != null) {
        await prefs.setString(_reportImagePathKey, report.imageFile!.path);
      } else {
        // Clear image path if no image file
        await prefs.remove(_reportImagePathKey);
      }

      // Handle attachment file
      if (report.attachmentFile != null) {
        await prefs.setString(
          _reportAttachmentPathKey,
          report.attachmentFile!.path,
        );
      } else {
        // Clear attachment path if no attachment file
        await prefs.remove(_reportAttachmentPathKey);
      }

      _logger.d('Report draft saved successfully');
    } catch (e) {
      _logger.e('Error saving report draft: $e');
    }
  }

  static Future<Report?> loadDraft() async {
    _logger.d('Loading report draft');

    try {
      final prefs = await SharedPreferences.getInstance();
      final reportData = prefs.getString(_reportDraftKey);

      if (reportData == null) {
        _logger.d('No report draft found');
        return null;
      }

      final reportJson = jsonDecode(reportData);
      var report = Report(
        title: reportJson['title'] ?? '',
        description: reportJson['description'] ?? '',
        categoryId: reportJson['category_id'] ?? 0,
        reporterName: reportJson['reporter_name'] ?? '',
        reporterContact: reportJson['reporter_contact'] ?? '',
        location: reportJson['location'] ?? '',
        agencyId: reportJson['agency_id'],
      );

      // Load file paths if exist
      final imagePath = prefs.getString(_reportImagePathKey);
      final attachmentPath = prefs.getString(_reportAttachmentPathKey);

      if (imagePath != null && File(imagePath).existsSync()) {
        report = report.copyWith(imageFile: File(imagePath));
      }

      if (attachmentPath != null && File(attachmentPath).existsSync()) {
        report = report.copyWith(attachmentFile: File(attachmentPath));
      }

      _logger.d('Report draft loaded successfully');
      return report;
    } catch (e) {
      _logger.e('Error loading report draft: $e');
      return null;
    }
  }

  static Future<void> clearDraft() async {
    _logger.d('Clearing report draft');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_reportDraftKey);
      await prefs.remove(_reportImagePathKey);
      await prefs.remove(_reportAttachmentPathKey);

      _logger.d('Report draft cleared successfully');
    } catch (e) {
      _logger.e('Error clearing report draft: $e');
    }
  }
}
