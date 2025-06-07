import 'dart:io';
import 'report_category.dart';
import 'government_agency.dart';

class Report {
  final int? id;
  final String title;
  final String description;
  final int categoryId;
  final String reporterName;
  final String reporterContact;
  final String location;
  final String? status;
  final int? agencyId;
  final File? imageFile;
  final File? attachmentFile;
  final String? imageUrl;
  final String? attachmentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Report({
    this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.reporterName,
    required this.reporterContact,
    required this.location,
    this.status,
    this.agencyId,
    this.imageFile,
    this.attachmentFile,
    this.imageUrl,
    this.attachmentUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? 0,
      reporterName: json['reporter_name'] as String? ?? '',
      reporterContact: json['reporter_contact'] as String? ?? '',
      location: json['location'] as String? ?? '',
      status: json['status'] as String?,
      agencyId: json['agency_id'] as int?,
      imageUrl: json['image_url'] as String?,
      attachmentUrl: json['lampiran_url'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category_id': categoryId,
      'reporter_name': reporterName,
      'reporter_contact': reporterContact,
      'location': location,
      'agency_id': agencyId,
    };
  }

  Report copyWith({
    String? title,
    String? description,
    int? categoryId,
    String? reporterName,
    String? reporterContact,
    String? location,
    int? agencyId,
    File? imageFile,
    File? attachmentFile,
    bool clearImageFile = false,
    bool clearAttachmentFile = false,
  }) {
    return Report(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      reporterName: reporterName ?? this.reporterName,
      reporterContact: reporterContact ?? this.reporterContact,
      location: location ?? this.location,
      agencyId: agencyId ?? this.agencyId,
      imageFile: clearImageFile ? null : (imageFile ?? this.imageFile),
      attachmentFile:
          clearAttachmentFile ? null : (attachmentFile ?? this.attachmentFile),
    );
  }
}

class DetailedReport extends Report {
  final ReportCategory? category;
  final GovernmentAgency? agency;

  DetailedReport({
    required super.id,
    required super.title,
    required super.description,
    required super.categoryId,
    required super.reporterName,
    required super.reporterContact,
    required super.location,
    super.status,
    super.agencyId,
    super.imageUrl,
    super.attachmentUrl,
    super.createdAt,
    super.updatedAt,
    this.category,
    this.agency,
  });

  factory DetailedReport.fromJson(Map<String, dynamic> json) {
    return DetailedReport(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? 0,
      reporterName: json['reporter_name'] as String? ?? '',
      reporterContact: json['reporter_contact'] as String? ?? '',
      location: json['location'] as String? ?? '',
      status: json['status'] as String?,
      agencyId: json['agency_id'] as int?,
      imageUrl: json['image_url'] as String?,
      attachmentUrl: json['lampiran_url'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      category:
          json['report_category'] != null
              ? ReportCategory.fromJson(json['report_category'])
              : null,
      agency:
          json['government_agency'] != null
              ? GovernmentAgency.fromJson(json['government_agency'])
              : null,
    );
  }
}
