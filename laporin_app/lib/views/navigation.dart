import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home/home_page.dart';
import 'lapor/lapor_page.dart';
import 'history/history_page.dart';
import 'notification/notification_page.dart';
import 'profile/profile_page.dart';
import '../services/notification_service.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _unreadNotificationCount = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const LaporPage(),
    const HistoryPage(),
    const NotificationPage(),
  ];

  final List<String> _pageTitles = [
    'Lapor Infrastruktur',
    'Lapor.In',
    'Riwayat Laporan',
    'Notification',
  ];

  @override
  void initState() {
    super.initState();
    // Set system UI overlay style with transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );
    WidgetsBinding.instance.addObserver(this);
    _startNotificationService();
    _loadUnreadCount();
  }

  Future<void> _startNotificationService() async {
    await NotificationService.startStatusPolling();
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService.getUnreadCount();
    setState(() {
      _unreadNotificationCount = count;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        NotificationService.startStatusPolling();
        _loadUnreadCount();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Keep polling in background
        break;
      case AppLifecycleState.detached:
        NotificationService.stopStatusPolling();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.stopStatusPolling();
    super.dispose();
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String label,
    required int index,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        if (index == 3) {
          // Notification page
          _loadUnreadCount();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                  size: 24,
                ),
                if (showBadge && badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        // Using light status bar icons with transparent background
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        title: Text(
          _pageTitles[_currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          const ProfilePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavigationItem(
              icon: Icons.home_outlined,
              label: 'Home',
              index: 0,
            ),
            _buildNavigationItem(
              icon: Icons.report_outlined,
              label: 'Lapor',
              index: 1,
            ),
            _buildNavigationItem(
              icon: Icons.history,
              label: 'History',
              index: 2,
            ),
            _buildNavigationItem(
              icon: Icons.notifications_outlined,
              label: 'Pesan',
              index: 3,
              showBadge: true,
              badgeCount: _unreadNotificationCount,
            ),
          ],
        ),
      ),
    );
  }
}
