import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import '../models/user_credit.dart';
import '../utils/hive_box.dart';

class CreditService {
  static final Logger _logger = Logger();
  static const double defaultCreditAmount = 50000.0; // Rp 30,000
  static const double reportCost = 10000.0; // Rp 10,000 per report

  static const int rechargeHour = 4;
  static const int rechargeMinute = 0;
  static const int rechargeSecond = 0;

  static Future<UserCredit> getUserCredit(String phoneNumber) async {
    try {
      final box = await Hive.openBox<UserCredit>(HiveBox.userCredits);
      UserCredit? userCredit = box.get(phoneNumber);

      if (userCredit == null) {
        // Create new user credit
        userCredit = UserCredit(
          phoneNumber: phoneNumber,
          creditBalance: defaultCreditAmount,
          lastRechargeDate: DateTime.now(),
          preferredCurrency: 'IDR',
        );
        await box.put(phoneNumber, userCredit);
        _logger.i('Created new user credit for $phoneNumber');
      } else {
        // Check for auto recharge
        await _checkAndAutoRecharge(userCredit);
      }

      return userCredit;
    } catch (e) {
      _logger.e('Error getting user credit: $e');
      rethrow;
    }
  }

  static Future<void> _checkAndAutoRecharge(UserCredit userCredit) async {
    try {
      final now = DateTime.now();
      final lastRecharge = userCredit.lastRechargeDate;

      // Check if it's past the configured recharge time and should auto recharge
      if (_shouldAutoRecharge(now, lastRecharge)) {
        userCredit.creditBalance = defaultCreditAmount;
        userCredit.lastRechargeDate = now;
        await userCredit.save();
        _logger.i('Auto recharged credit for ${userCredit.phoneNumber}');
      }
    } catch (e) {
      _logger.e('Error in auto recharge: $e');
    }
  }

  static bool _shouldAutoRecharge(DateTime now, DateTime lastRecharge) {
    // Get the configured recharge time for today
    final todayRechargeTime = DateTime(
      now.year,
      now.month,
      now.day,
      rechargeHour,
      rechargeMinute,
      rechargeSecond,
    );

    // Check if current time is past the configured recharge time
    if (now.isBefore(todayRechargeTime)) {
      return false; // Not yet recharge time today
    }

    // Check if last recharge was before today's recharge time
    return lastRecharge.isBefore(todayRechargeTime);
  }

  static Future<bool> deductCredit(String phoneNumber, double amount) async {
    try {
      final userCredit = await getUserCredit(phoneNumber);

      if (userCredit.creditBalance >= amount) {
        userCredit.creditBalance -= amount;
        await userCredit.save();
        _logger.i('Deducted $amount credit from $phoneNumber');
        return true;
      } else {
        _logger.w('Insufficient credit for $phoneNumber');
        return false;
      }
    } catch (e) {
      _logger.e('Error deducting credit: $e');
      return false;
    }
  }

  static Future<void> updatePreferredCurrency(
    String phoneNumber,
    String currency,
  ) async {
    try {
      final userCredit = await getUserCredit(phoneNumber);
      userCredit.preferredCurrency = currency;
      await userCredit.save();
      _logger.i('Updated preferred currency for $phoneNumber to $currency');
    } catch (e) {
      _logger.e('Error updating preferred currency: $e');
    }
  }

  static Future<void> addCredit(String phoneNumber, double amount) async {
    try {
      final userCredit = await getUserCredit(phoneNumber);
      userCredit.creditBalance += amount;
      await userCredit.save();
      _logger.i('Added $amount credit to $phoneNumber');
    } catch (e) {
      _logger.e('Error adding credit: $e');
    }
  }

  static double getReportCost() {
    return reportCost;
  }

  static double getDefaultCreditAmount() {
    return defaultCreditAmount;
  }
}
