import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectionPopup extends StatefulWidget {
  final bool isVisible;

  const ConnectionPopup({super.key, required this.isVisible});

  @override
  State<ConnectionPopup> createState() => _ConnectionPopupState();
}

class _ConnectionPopupState extends State<ConnectionPopup>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(ConnectionPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _fadeController.forward();
      _slideController.forward();
      // When popup shows (dark overlay), ensure status bar icons are light
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      );
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _slideController.reverse();
      _fadeController.reverse();
      // Return to default style based on background when popup hides
      _restoreStatusBarStyle();
    }
  }

  void _restoreStatusBarStyle() {
    // Get the app's current theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final style =
        isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    SystemChrome.setSystemUIOverlayStyle(
      style.copyWith(statusBarColor: Colors.transparent),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _fadeController]),
      builder: (context, child) {
        if (!widget.isVisible &&
            _slideController.isDismissed &&
            _fadeController.isDismissed) {
          return const SizedBox.shrink();
        }

        return Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Dark overlay background
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                  ),
                ),
                // Bottom sheet popup
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                        minHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle bar
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wifi_off,
                              color: Colors.blue.shade700,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Message
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                Text(
                                  'Connection Issue',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No internet connection',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Please check your internet connection and try again.',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      // The app will handle reconnection automatically
                                      // This button is just for user reassurance
                                    },
                                    icon: Icon(
                                      Icons.refresh,
                                      color: Colors.blue.shade700,
                                    ),
                                    label: Text(
                                      'Retry Connection',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
