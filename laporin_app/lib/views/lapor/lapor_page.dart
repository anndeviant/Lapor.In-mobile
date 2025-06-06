import 'package:flutter/material.dart';
import '../../services/connectivity_service.dart';
import '../widgets/connection_popup.dart';
import 'create_report_page.dart';

class LaporPage extends StatefulWidget {
  const LaporPage({super.key});

  @override
  State<LaporPage> createState() => _LaporPageState();
}

class _LaporPageState extends State<LaporPage> {
  bool _showConnectionPopup = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
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

  @override
  void dispose() {
    ConnectivityService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Report an Issue',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Help us improve infrastructure by reporting issues in your area.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // Create Report Button
              SizedBox(
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                const CreateReportPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 32,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Create New Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quick Info Cards
              _buildInfoCards(),
            ],
          ),
        ),
        ConnectionPopup(isVisible: _showConnectionPopup),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.info_outline,
          title: 'How to Report',
          description:
              'Follow our 4-step process to submit a complete report with evidence.',
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.camera_alt_outlined,
          title: 'Evidence Required',
          description:
              'Take clear photos of the issue to help authorities understand the problem.',
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.track_changes_outlined,
          title: 'Track Progress',
          description:
              'Monitor your report status and receive updates on resolution progress.',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
