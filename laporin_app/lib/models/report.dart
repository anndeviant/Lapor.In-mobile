import 'dart:io';

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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      categoryId: json['category_id'],
      reporterName: json['reporter_name'],
      reporterContact: json['reporter_contact'],
      location: json['location'],
      status: json['status'],
      agencyId: json['agency_id'],
      imageUrl: json['image_url'],
      attachmentUrl: json['lampiran_url'],
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
