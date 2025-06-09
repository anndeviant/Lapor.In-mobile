import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/report_statistics.dart';
import '../../models/report.dart';
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

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<PublicReport> _searchResults = [];
  String _lastSearchQuery = '';

  bool _localeInitialized = false;
  bool _timezoneInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize timezone and locale
    Future.wait([
      initializeDateFormatting('id_ID', null),
      _initializeTimezone(),
    ]).then((_) {
      setState(() {
        _localeInitialized = true;
        _timezoneInitialized = true;
      });
      _checkConnectivity();
      _loadStatistics();
    });
  }

  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
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

  Future<void> _performSearch(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _lastSearchQuery = '';
      });
      return;
    }

    if (query == _lastSearchQuery) return;

    setState(() {
      _isSearching = true;
      _lastSearchQuery = query;
    });

    try {
      final results = await ReportService.searchPublicReports(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });

        // Show error message to user if it's not a "no results" case
        if (!e.toString().contains('No reports found') &&
            !e.toString().contains('Tidak ada aduan ditemukan')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error searching reports: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
      _lastSearchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure status bar is properly styled
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );

    if (!_localeInitialized || !_timezoneInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Lapor.In!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 15),

            // Search Results or Statistics
            _searchResults.isNotEmpty ||
                    _isSearching ||
                    _lastSearchQuery.isNotEmpty
                ? _buildSearchSection()
                : _buildStatisticsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search reports...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 3), // Lebih pendek
            child: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: _clearSearch,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 10,
          ),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.trim().isEmpty) {
            _clearSearch();
          } else {
            // Debounce search
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value && mounted) {
                _performSearch(value);
              }
            });
          }
        },
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildSearchSection() {
    if (_isSearching) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: Colors.blue.shade700),
              const SizedBox(height: 16),
              Text(
                'Searching reports...',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty && _lastSearchQuery.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No reports found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try searching with different keywords',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Search Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_searchResults.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._searchResults.map((report) => _buildPublicReportCard(report)),
      ],
    );
  }

  Widget _buildPublicReportCard(PublicReport report) {
    final statusConfig = _getStatusConfig(report.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and Status row at the top
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category on the left with icon
                if (report.category != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report.category!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),

                // Status on the right with background
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusConfig['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusConfig['icon'],
                        color: statusConfig['color'],
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusConfig['text'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusConfig['color'],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Image section
          if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(0)),
              child: Image.network(
                report.imageUrl!,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade100,
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.shade100,
              child: Icon(Icons.image, size: 48, color: Colors.grey.shade400),
            ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  report.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),

                // Description (full text, no truncation)
                Text(
                  report.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Location
                Row(
                  children: [
                    // Icon(
                    //   Icons.location_on,
                    //   size: 16,
                    //   color: Colors.grey.shade600,
                    // ),
                    // const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Time ago and formatted date
                if (report.createdAt != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(report.createdAt!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        ', ${_formatTanggal(report.createdAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Timezone cards
                  _buildTimezoneCards(report.createdAt!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget row of compact timezone cards
  Widget _buildTimezoneCards(DateTime date) {
    // Convert DateTime to TZDateTime
    final jakarta = tz.getLocation('Asia/Jakarta');
    final makassar = tz.getLocation('Asia/Makassar');
    final jayapura = tz.getLocation('Asia/Jayapura');
    final london = tz.getLocation('Europe/London');

    final wib = tz.TZDateTime.from(date, jakarta);
    final wita = tz.TZDateTime.from(date, makassar);
    final wit = tz.TZDateTime.from(date, jayapura);
    final londonTime = tz.TZDateTime.from(date, london);

    final List<Map<String, dynamic>> zones = [
      {'label': 'WIB', 'time': wib},
      {'label': 'WITA', 'time': wita},
      {'label': 'WIT', 'time': wit},
      {'label': 'London', 'time': londonTime},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children:
          zones.map((zone) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200, width: 0.7),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      zone['label'],
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      DateFormat('HH:mm').format(zone['time']),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {
          'text': 'Pending',
          'color': Colors.grey.shade600,
          'icon': Icons.hourglass_empty,
        };
      case 'verified':
        return {
          'text': 'Terverifikasi',
          'color': Colors.blue.shade600,
          'icon': Icons.verified,
        };
      case 'in_progress':
        return {
          'text': 'Sedang Diproses',
          'color': Colors.orange.shade600,
          'icon': Icons.sync,
        };
      case 'resolved':
        return {
          'text': 'Selesai',
          'color': Colors.green.shade600,
          'icon': Icons.check_circle,
        };
      default:
        return {
          'text': 'Unknown',
          'color': Colors.grey.shade600,
          'icon': Icons.help,
        };
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Format tanggal: 7 Juni 2025
  String _formatTanggal(DateTime date) {
    final idLocale = 'id_ID';
    final dateFormat = DateFormat('d MMMM yyyy', idLocale);
    return dateFormat.format(date);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      child: Row(
        children: [
          // Left: Texts
          Expanded(
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
                const SizedBox(height: 4),
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
          ),
          // Right: Centered Icon
          Image.asset(
            'assets/icon/laporinlogo.png',
            height: 80,
            width: 80,
            color: Colors.white,
            colorBlendMode: BlendMode.srcIn,
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
          'Statistik Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children:
                _statistics!.statuses.map((status) {
                  return _buildStatusItem(status);
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(StatusStat status) {
    // Define colors for each status
    final statusColors = {
      'pending': Colors.grey.shade600,
      'verified': Colors.blue.shade600,
      'in_progress': Colors.orange.shade600,
      'resolved': Colors.green.shade600,
      'rejected': Colors.red.shade600,
    };

    final statusIcons = {
      'pending': Icons.hourglass_empty,
      'verified': Icons.verified,
      'in_progress': Icons.sync,
      'resolved': Icons.check_circle,
      'rejected': Icons.cancel,
    };

    final color =
        statusColors[status.status.toLowerCase()] ?? Colors.grey.shade600;
    final icon = statusIcons[status.status.toLowerCase()] ?? Icons.help_outline;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {}, // Could navigate to filtered list in the future
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                // Smaller icon container
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 12),
                Text(
                  _capitalizeStatus(status.status),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                // Smaller count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  // decoration: BoxDecoration(
                  //   color: color.withValues(alpha: 0.1),
                  //   borderRadius: BorderRadius.circular(10),
                  // ),
                  child: Text(
                    status.count.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children:
                _statistics!.categories.map((category) {
                  return _buildCategoryItem(category);
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(CategoryStat category) {
    // Use a consistent blue color for all categories
    final color = Colors.blue.shade700;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {}, // Could navigate to filtered list in the future
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                // Smaller icon container
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.category, color: color, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.categoryName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
                // Smaller count badge with consistent blue color
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  // decoration: BoxDecoration(
                  //   color: Colors.blue.shade50,
                  //   borderRadius: BorderRadius.circular(10),
                  // ),
                  child: Text(
                    category.count.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
