import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../services/connectivity_service.dart';
import '../../services/notification_service.dart';
import '../../models/notification.dart';
import '../widgets/connection_popup.dart';
import '../history/report_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _showConnectionPopup = false;
  bool _isLoading = true;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadNotifications();
    ConnectivityService.startMonitoring(_onConnectivityChanged);
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
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final notifications = await NotificationService.getAllNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (!notification.isRead) {
      await NotificationService.markAsRead(notification.id);
      await _loadNotifications();
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Semua Notifikasi'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus semua notifikasi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await NotificationService.clearAllNotifications();
      await _loadNotifications();
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
    return Stack(
      children: [
        Scaffold(body: _buildBody()),
        ConnectionPopup(isVisible: _showConnectionPopup),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return _buildNotificationsList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue.shade700),
          const SizedBox(height: 16),
          Text(
            'Memuat notifikasi...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
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
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 64,
                color: Colors.blue.shade300,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Notifikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi perubahan status laporan akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: Colors.blue.shade700,
      child: CustomScrollView(
        slivers: [
          // Header with title and clear button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (_notifications.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearAllNotifications,
                      icon: Icon(
                        Icons.clear_all_outlined,
                        size: 18,
                        color: Colors.red.shade600,
                      ),
                      label: Text(
                        'Clear All',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Notifications list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              }, childCount: _notifications.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final statusConfig = _getStatusConfig(notification.newStatus);
    final timeAgo = NotificationService.formatTimeWithTimezone(
      notification.timestamp,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              notification.isRead
                  ? Colors.grey.withValues(alpha: 0.13)
                  : Colors.blue.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _markAsRead(notification);
          _navigateToReportDetail(notification.reportId);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with status badge and time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusConfig['color'].withOpacity(0.13),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusConfig['icon'],
                          size: 14,
                          color: statusConfig['color'],
                        ),
                        const SizedBox(width: 4),
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
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    timeAgo,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Notification title
              Text(
                notification.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),

              // Report title
              Text(
                notification.reportTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Status change info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatStatusText(notification.oldStatus),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusConfig['color'].withOpacity(0.13),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatStatusText(notification.newStatus),
                      style: TextStyle(
                        fontSize: 11,
                        color: statusConfig['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Detailed timestamp
              Text(
                _formatDetailedTime(notification.timestamp),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
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

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'verified':
        return 'Terverifikasi';
      case 'in_progress':
        return 'Sedang Diproses';
      case 'resolved':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  String _formatDetailedTime(DateTime dateTime) {
    final jakarta = tz.getLocation('Asia/Jakarta');
    final localTime = tz.TZDateTime.from(dateTime, jakarta);

    final formatter = DateFormat('EEEE, d MMMM yyyy HH:mm', 'id_ID');
    return '${formatter.format(localTime)} WIB';
  }
}
