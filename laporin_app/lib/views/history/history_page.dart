import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../services/connectivity_service.dart';
import '../../services/report_service.dart';
import '../../services/auth_service.dart';
import '../../models/report.dart';
import '../widgets/connection_popup.dart';
import 'report_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _showConnectionPopup = false;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  List<Report> _reports = [];
  String? _trackingId; // Will be loaded from user's phone number

  bool _localeInitialized = false; // Tambahkan flag
  bool _timezoneInitialized = false; // Tambahkan flag untuk timezone

  @override
  void initState() {
    super.initState();
    // Inisialisasi timezone dan locale
    Future.wait([
      initializeDateFormatting('id_ID', null),
      _initializeTimezone(),
    ]).then((_) {
      setState(() {
        _localeInitialized = true;
        _timezoneInitialized = true;
      });
      _checkConnectivity();
      _loadUserAndReports();
      ConnectivityService.startMonitoring(_onConnectivityChanged);
    });
  }

  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();
    // Optionally set default location, misal Asia/Jakarta
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await ConnectivityService.hasConnection();
    setState(() {
      _showConnectionPopup = !hasConnection;
    });
  }

  void _onConnectivityChanged(bool hasConnection) {
    setState(() {
      _showConnectionPopup = !hasConnection;
    });

    if (hasConnection && _reports.isEmpty && _trackingId != null) {
      _loadReports();
    }
  }

  Future<void> _loadUserAndReports() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Get current user's phone number from SharedPreferences
      final currentUser = await AuthService.getCurrentUser();

      if (currentUser == null || currentUser.phoneNumber.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'User tidak ditemukan. Silakan login ulang.';
        });
        return;
      }

      _trackingId = currentUser.phoneNumber;

      // Load reports for this user
      await _loadReports();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Gagal memuat data user';
        });
      }
    }
  }

  Future<void> _loadReports() async {
    if (!mounted || _trackingId == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final reports = await ReportService.getReportsByTrackingId(_trackingId!);
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
          _hasError = false; // Ensure error state is cleared
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Gagal memuat riwayat laporan. Silakan coba lagi.';
        });
      }
    }
  }

  void _navigateToReportDetail(int reportId) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                ReportDetailPage(reportId: reportId),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    ConnectivityService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized || !_timezoneInitialized) {
      // Tampilkan loading sampai locale & timezone siap
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Scaffold(
          // Removed AppBar completely
          body: _buildBody(),
        ),
        ConnectionPopup(isVisible: _showConnectionPopup),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_reports.isEmpty) {
      return _buildEmptyState();
    }

    return _buildReportsList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue.shade700),
          const SizedBox(height: 16),
          Text(
            'Memuat riwayat laporan...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadReports,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Laporan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    return RefreshIndicator(
      onRefresh: _loadReports,
      color: Colors.blue.shade700,
      child: CustomScrollView(
        slivers: [
          // Header with title and refresh button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Reports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  // Simple refresh button without background
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    tooltip: 'Refresh',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _loadReports,
                  ),
                ],
              ),
            ),
          ),

          // Reports list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final report = _reports[index];
                return _buildReportCard(report);
              }, childCount: _reports.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    final statusConfig = _getStatusConfig(report.status ?? 'pending');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusConfig['color'].withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _navigateToReportDetail(report.id!),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Icon Row (top)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusConfig['color'].withOpacity(0.13),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        // Icon on the left
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          // decoration: BoxDecoration(
                          //   color: statusConfig['color'].withOpacity(0.18),
                          //   shape: BoxShape.circle,
                          // ),
                          child: Icon(
                            statusConfig['icon'],
                            color: statusConfig['color'],
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Status text on the right
                        Text(
                          statusConfig['text'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusConfig['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                report.title,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 7),
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 13,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              // Description
              Text(
                report.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Date
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (report.createdAt != null) ...[
                    Text(
                      ', ${_formatTanggal(report.createdAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              // Multi timezone card row
              if (report.createdAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _buildTimezoneCards(report.createdAt!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget row of compact timezone cards
  Widget _buildTimezoneCards(DateTime date) {
    // Konversi DateTime ke TZDateTime
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
          'text': 'Menunggu',
          'color': Colors.grey.shade700,
          'icon': Icons.hourglass_empty,
        };
      case 'verified':
        return {
          'text': 'Terverifikasi',
          'color': Colors.blue.shade700,
          'icon': Icons.verified,
        };
      case 'in_progress':
        return {
          'text': 'Diproses',
          'color': Colors.orange.shade700,
          'icon': Icons.sync,
        };
      case 'resolved':
        return {
          'text': 'Selesai',
          'color': Colors.green.shade700,
          'icon': Icons.check_circle,
        };
      case 'rejected':
        return {
          'text': 'Ditolak',
          'color': Colors.red.shade700,
          'icon': Icons.cancel,
        };
      default:
        return {
          'text': 'Unknown',
          'color': Colors.grey.shade700,
          'icon': Icons.help,
        };
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Format tanggal: 7 Juni 2025
  String _formatTanggal(DateTime date) {
    final idLocale = 'id_ID';
    final dateFormat = DateFormat('d MMMM yyyy', idLocale);
    return dateFormat.format(date);
  }
}
