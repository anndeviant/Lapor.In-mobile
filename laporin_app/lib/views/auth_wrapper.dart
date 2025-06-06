import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import 'widgets/connection_popup.dart';
import 'auth/landing_page.dart';
import 'navigation.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _hasConnection = true;
  bool _showConnectionPopup = false;

  @override
  void initState() {
    super.initState();
    // Ensure consistent transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // First check connectivity
    await _checkConnectivity();

    // If connected, check login status
    if (_hasConnection) {
      await _checkLoginStatus();
    }

    // Start monitoring connectivity changes
    ConnectivityService.startMonitoring(_onConnectivityChanged);
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await ConnectivityService.hasConnection();
    setState(() {
      _hasConnection = hasConnection;
      _showConnectionPopup = !hasConnection;
      if (!hasConnection) {
        _isLoading = false;
      }
    });
  }

  void _onConnectivityChanged(bool hasConnection) {
    setState(() {
      _hasConnection = hasConnection;
      _showConnectionPopup = !hasConnection;
    });

    if (hasConnection && _isLoading) {
      // Connection restored, check login status
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    setState(() => _isLoading = true);

    try {
      final isLoggedIn = await AuthService.checkSession();
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    ConnectivityService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Checking connection...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            _isLoggedIn ? const NavigationPage() : const LandingPage(),
          // Connection popup
          ConnectionPopup(isVisible: _showConnectionPopup),
        ],
      ),
    );
  }
}
