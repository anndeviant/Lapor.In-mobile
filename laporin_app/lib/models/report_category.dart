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
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      iconUrl: json['icon_url'] ?? '',
    );
  }
}
