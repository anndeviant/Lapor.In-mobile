import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/report_statistics.dart';
import '../../services/report_service.dart';
import '../../services/connectivity_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  ReportStatistics? _statistics;
  bool _hasConnection = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadStatistics();
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await ConnectivityService.hasConnection();
    setState(() {
      _hasConnection = hasConnection;
    });
  }

  Future<void> _loadStatistics() async {
    if (!_hasConnection) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'No internet connection';
      });
      return;
    }

    try {
      final statistics = await ReportService.getReportStatistics();
      setState(() {
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load statistics';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure status bar is properly styled
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Lapor.In!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatisticsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return _buildStatistics();
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue.shade700),
            const SizedBox(height: 16),
            Text(
              'Loading statistics...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                'Error Loading Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_errorMessage, style: TextStyle(color: Colors.red.shade700)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _loadStatistics(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    if (_statistics == null) return const SizedBox.shrink();

    // Calculate total reports
    int totalReports = 0;
    for (var status in _statistics!.statuses) {
      totalReports += status.count;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Reports Card
        _buildSummaryCard(totalReports),
        const SizedBox(height: 16),

        // Status Statistics
        _buildStatusStatistics(),
        const SizedBox(height: 16),

        // Category Statistics
        _buildCategoryStatistics(),
      ],
    );
  }

  Widget _buildSummaryCard(int totalReports) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Report Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$totalReports',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Total Reports Submitted',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStatistics() {
    if (_statistics == null || _statistics!.statuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children:
                  _statistics!.statuses.map((status) {
                    return _buildStatusItem(status);
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(StatusStat status) {
    // Define colors for each status
    final statusColors = {
      'pending': Colors.grey,
      'verified': Colors.blue,
      'in_progress': Colors.orange,
      'resolved': Colors.green,
      'rejected': Colors.red,
    };

    final color = statusColors[status.status] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            _capitalizeStatus(status.status),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            status.count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStatistics() {
    if (_statistics == null || _statistics!.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children:
                  _statistics!.categories.map((category) {
                    return _buildCategoryItem(category);
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(CategoryStat category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.category, color: Colors.blue.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.categoryName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            category.count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeStatus(String status) {
    // Replace underscores with spaces and capitalize each word
    return status
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
