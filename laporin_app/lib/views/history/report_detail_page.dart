import 'package:flutter/material.dart';
import '../../services/report_service.dart';
import '../../models/report.dart';

class ReportDetailPage extends StatefulWidget {
  final int reportId;

  const ReportDetailPage({super.key, required this.reportId});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  DetailedReport? _report;

  @override
  void initState() {
    super.initState();
    _loadReportDetail();
  }

  Future<void> _loadReportDetail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final report = await ReportService.getReportById(widget.reportId);
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Gagal memuat detail laporan';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Laporan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white, // <-- this ensures back icon is white
        elevation: 2,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // <-- explicitly set icon color to white
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue.shade700),
            const SizedBox(height: 16),
            Text(
              'Memuat detail laporan...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
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
                onPressed: _loadReportDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_report == null) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildDetailCard(),
          const SizedBox(height: 16),
          if (_report!.imageUrl != null) _buildImageCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusConfig = _getStatusConfig(_report!.status ?? 'pending');

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Text(
              'Status Laporan',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusConfig['color'].withOpacity(0.13),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  // Icon on the left
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    // Use a professional, modern card style similar to _buildStatusCard
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _report!.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222B45),
                letterSpacing: 0.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            // Location, Reporter, Contact, Category, Agency, Date
            _buildDetailRow(Icons.location_on, 'Lokasi', _report!.location),
            _buildDetailRow(Icons.person, 'Pelapor', _report!.reporterName),
            _buildDetailRow(Icons.phone, 'Kontak', _report!.reporterContact),
            if (_report!.category != null)
              _buildDetailRow(
                Icons.category,
                'Kategori',
                _report!.category!.name,
              ),
            if (_report!.agency != null)
              _buildDetailRow(
                Icons.business,
                'Instansi',
                _report!.agency!.name,
              ),
            _buildDetailRow(
              Icons.access_time,
              'Tanggal',
              _formatFullDate(_report!.createdAt),
            ),
            const SizedBox(height: 16),
            // Description Section
            Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _report!.description,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align icon and text vertically center
        children: [
          Container(
            height: 28, // Ensure consistent height for vertical alignment
            width: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: Colors.blueGrey.shade400),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF222B45)),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    // Modern card style for image
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto Bukti',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                _report!.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Center(
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
                            'Gagal memuat gambar',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {
          'text': 'Menunggu Verifikasi',
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
          'text': 'Sedang Diproses',
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
          'text': 'Status Tidak Diketahui',
          'color': Colors.grey.shade700,
          'icon': Icons.help,
        };
    }
  }

  String _formatFullDate(DateTime? date) {
    if (date == null) return '-';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
