import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/connectivity_service.dart';
import '../widgets/connection_popup.dart';
import 'login_page.dart';
import 'landing_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _hasConnection = true;
  bool _showConnectionPopup = false;
  bool _obscurePassword = true;

  // Track current step (1 or 2)
  int _currentStep = 1;

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

  void _proceedToStep2() {
    if (_step1FormKey.currentState!.validate()) {
      setState(() {
        _currentStep = 2;
      });
    }
  }

  void _backToStep1() {
    setState(() {
      _currentStep = 1;
    });
  }

  Future<void> _register() async {
    if (!_step2FormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.register(
        fullname: _fullnameController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const LoginPage(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    ConnectivityService.stopMonitoring();
    _fullnameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Back button
                GestureDetector(
                  onTap:
                      _currentStep == 1
                          ? () {
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const LandingPage(),
                                transitionDuration: Duration.zero,
                              ),
                            );
                          }
                          : _backToStep1,
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
                    'assets/icon/laporinlogo.png',
                    height: 100,
                    width: 100,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    _currentStep == 1 ? 'Create Account' : 'Set Password',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _currentStep == 1
                        ? 'Enter your details to get started'
                        : 'Create a secure password!',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Conditional content based on step
                _currentStep == 1 ? _buildStep1() : _buildStep2(),
              ],
            ),
          ),
          ConnectionPopup(isVisible: _showConnectionPopup),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Expanded(
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name Field
            Text(
              'Full Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullnameController,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: Icon(
                  Icons.person_outline,
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
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
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
                prefixIcon: Icon(Icons.phone, color: Colors.blue.shade700),
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
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            // const Spacer(),
            const SizedBox(height: 40),

            // Next Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: !_hasConnection ? null : _proceedToStep2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.blue.shade200,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Login Link
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              const LoginPage(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: Colors.grey.shade700),
                    children: [
                      TextSpan(
                        text: 'Login',
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Expanded(
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display phone number (read-only)
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
              initialValue: _phoneController.text,
              enabled: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone, color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            // Password Field
            Text(
              'Create Password',
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
                hintText: 'Enter a secure password',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Colors.blue.shade700,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              '* Password must be at least 6 characters.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            // const Spacer(),
            const SizedBox(height: 40),
            // Register Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isLoading || !_hasConnection) ? null : _register,
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
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
