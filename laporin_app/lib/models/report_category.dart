class ReportCategory {
  final int id;
  final String name;
  final String description;
  final String iconUrl;

  ReportCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl = '',
  });

  factory ReportCategory.fromJson(Map<String, dynamic> json) {
    return ReportCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
    );
  }
}
