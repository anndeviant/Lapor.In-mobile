import 'package:flutter/material.dart';
import '../../services/connectivity_service.dart';
import '../widgets/connection_popup.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
        Center(
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
                  Icons.notifications,
                  size: 64,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Notification Page',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Notifications will be displayed here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
        ConnectionPopup(isVisible: _showConnectionPopup),
      ],
    );
  }
}
