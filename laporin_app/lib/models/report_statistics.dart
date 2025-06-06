class ReportStatistics {
  final List<CategoryStat> categories;
  final List<StatusStat> statuses;

  ReportStatistics({required this.categories, required this.statuses});

  factory ReportStatistics.fromJson(Map<String, dynamic> json) {
    List<CategoryStat> categories = [];
    List<StatusStat> statuses = [];

    if (json['categories'] != null) {
      categories = List<CategoryStat>.from(
        json['categories'].map((x) => CategoryStat.fromJson(x)),
      );
    }

    if (json['statuses'] != null) {
      statuses = List<StatusStat>.from(
        json['statuses'].map((x) => StatusStat.fromJson(x)),
      );
    }

    return ReportStatistics(categories: categories, statuses: statuses);
  }
}

class CategoryStat {
  final int categoryId;
  final String categoryName;
  final int count;

  CategoryStat({
    required this.categoryId,
    required this.categoryName,
    required this.count,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      categoryId: json['category_id'],
      categoryName: json['report_category.name'],
      count: json['count'],
    );
  }
}

class StatusStat {
  final String status;
  final int count;

  StatusStat({required this.status, required this.count});

  factory StatusStat.fromJson(Map<String, dynamic> json) {
    return StatusStat(
      status: json['status'],
      count: int.parse(json['count'].toString()),
    );
  }
}
