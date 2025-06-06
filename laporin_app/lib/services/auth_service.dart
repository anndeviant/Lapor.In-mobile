import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';
import '../utils/device_info_helper.dart';
import 'base_network.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _fullnameKey = 'fullname';
  static const String _phoneNumberKey = 'phone_number';
  static final Logger _logger = Logger();

  // Register new user
  static Future<Map<String, dynamic>> register({
    required String fullname,
    required String phoneNumber,
    required String password,
  }) async {
    _logger.i('Starting user registration for phone: $phoneNumber');

    final data = {
      'fullname': fullname,
      'phone_number': phoneNumber,
      'password': password,
    };

    try {
      final response = await BaseNetwork.post('/users/register', data);
      _logger.i('User registration successful for phone: $phoneNumber');
      return response;
    } catch (e) {
      _logger.e('User registration failed for phone: $phoneNumber - Error: $e');
      rethrow;
    }
  }

  // Login user
  static Future<User> login({
    required String phoneNumber,
    required String password,
  }) async {
    _logger.i('Starting user login for phone: $phoneNumber');

    try {
      final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
      _logger.d('Device info: $deviceInfo');

      final data = {
        'phone_number': phoneNumber,
        'password': password,
        'device_info': deviceInfo,
      };

      final response = await BaseNetwork.post('/users/login', data);
      _logger.d('Login response: $response');

      // Handle different response structures
      Map<String, dynamic> userData;
      if (response.containsKey('user') && response['user'] != null) {
        userData = response['user'];
      } else if (response.containsKey('data') && response['data'] != null) {
        userData = response['data'];
      } else {
        // If response itself contains user data
        userData = response;
      }

      final user = User.fromJson(userData);

      // Save login info locally
      await _saveLoginInfo(user);
      _logger.i(
        'User login successful for phone: $phoneNumber, User ID: ${user.id}',
      );

      return user;
    } catch (e) {
      _logger.e('User login failed for phone: $phoneNumber - Error: $e');
      rethrow;
    }
  }

  // Check session
  static Future<bool> checkSession() async {
    _logger.i('Checking user session');

    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString(_phoneNumberKey);

    if (phoneNumber == null) {
      _logger.w('No phone number found in local storage');
      return false;
    }

    _logger.d('Checking session for phone: $phoneNumber');

    try {
      final response = await BaseNetwork.post('/users/check-session', {
        'phone_number': phoneNumber,
      });
      final isLoggedIn = response['isLoggedIn'] ?? false;
      _logger.i(
        'Session check result for phone: $phoneNumber - isLoggedIn: $isLoggedIn',
      );
      return isLoggedIn;
    } catch (e) {
      _logger.e('Session check failed for phone: $phoneNumber - Error: $e');
      return false;
    }
  }

  // Logout user
  static Future<void> logout() async {
    _logger.i('Starting user logout');

    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString(_phoneNumberKey);

    if (phoneNumber != null) {
      _logger.d('Logging out user with phone: $phoneNumber');
      try {
        await BaseNetwork.post('/users/logout', {'phone_number': phoneNumber});
        _logger.i('Server logout successful for phone: $phoneNumber');
      } catch (e) {
        _logger.w(
          'Server logout failed for phone: $phoneNumber - Error: $e, continuing with local logout',
        );
      }
    } else {
      _logger.w(
        'No phone number found for logout, proceeding with local logout only',
      );
    }

    await _clearLoginInfo();
    _logger.i('User logout completed');
  }

  // Get current user info from local storage
  static Future<User?> getCurrentUser() async {
    _logger.d('Getting current user from local storage');

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    final fullname = prefs.getString(_fullnameKey);
    final phoneNumber = prefs.getString(_phoneNumberKey);

    if (userId != null && fullname != null && phoneNumber != null) {
      _logger.d('Current user found - ID: $userId, Phone: $phoneNumber');
      return User(id: userId, fullname: fullname, phoneNumber: phoneNumber);
    }

    _logger.w('No current user found in local storage');
    return null;
  }

  // Save login info to local storage
  static Future<void> _saveLoginInfo(User user) async {
    _logger.d('Saving login info to local storage for user ID: ${user.id}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, user.id!);
    await prefs.setString(_fullnameKey, user.fullname);
    await prefs.setString(_phoneNumberKey, user.phoneNumber);

    _logger.d('Login info saved successfully');
  }

  // Clear login info from local storage
  static Future<void> _clearLoginInfo() async {
    _logger.d('Clearing login info from local storage');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_fullnameKey);
    await prefs.remove(_phoneNumberKey);

    _logger.d('Login info cleared successfully');
  }
}
