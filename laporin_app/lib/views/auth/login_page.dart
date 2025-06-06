import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/connectivity_service.dart';
import '../widgets/connection_popup.dart';
import 'register_page.dart';
import '../navigation.dart';
import 'landing_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _hasConnection = true;
  bool _showConnectionPopup = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Set dark status bar icons for light background
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
    _checkConnectivity();
    ConnectivityService.startMonitoring(_onConnectivityChanged);
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await ConnectivityService.hasConnection();
    setState(() {
      _hasConnection = hasConnection;
      _showConnectionPopup = !hasConnection;
    });
  }

  void _onConnectivityChanged(bool hasConnection) {
    setState(() {
      _hasConnection = hasConnection;
      _showConnectionPopup = !hasConnection;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.login(
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const NavigationPage(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    ConnectivityService.stopMonitoring();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Back button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const LandingPage(),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/icon/laporinlogo.png', // Adjust path as needed
                        height: 100,
                        width: 100,
                      ),
                    ),
                    // Center(
                    //   child: ColorFiltered(
                    //     colorFilter: const ColorFilter.mode(
                    //       Colors.white,
                    //       BlendMode.srcIn,
                    //     ),
                    //     child: Image.asset(
                    //       'assets/icon/laporinlogo.png', // Adjust path as needed
                    //       height: 120,
                    //       width: 120,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Sign in to continue using Lapor.In',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Phone Number Field
                    Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        hintText: 'Enter your phone number',
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.blue.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.shade700,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Password Field
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.blue.shade700,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.shade700,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            (_isLoading || !_hasConnection) ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.blue.shade200,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Register Link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const RegisterPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.grey.shade700),
                            children: [
                              TextSpan(
                                text: 'Register',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ConnectionPopup(isVisible: _showConnectionPopup),
        ],
      ),
    );
  }
}
