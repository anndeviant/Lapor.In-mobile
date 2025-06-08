import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class CurrencyService {
  static final Logger _logger = Logger();

  // Fallback rates if API fails
  static const Map<String, double> _fallbackRates = {
    'USD': 0.000061, 
    'JPY': 0.00888, 
    'CNY': 0.000441, 
    'IDR': 1.0, 
  };

  static Map<String, double> _currentRates = Map.from(_fallbackRates);

  static Future<void> updateExchangeRates() async {
    try {
      // Using a free API for exchange rates (you can replace with your preferred API)
      final response = await http
          .get(
            Uri.parse('https://api.exchangerate-api.com/v4/latest/IDR'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        _currentRates = {
          'IDR': 1.0,
          'USD': rates['USD']?.toDouble() ?? _fallbackRates['USD']!,
          'JPY': rates['JPY']?.toDouble() ?? _fallbackRates['JPY']!,
          'CNY': rates['CNY']?.toDouble() ?? _fallbackRates['CNY']!,
        };

        _logger.i('Exchange rates updated successfully');
      } else {
        _logger.w('Failed to fetch exchange rates, using fallback rates');
      }
    } catch (e) {
      _logger.e('Error fetching exchange rates: $e, using fallback rates');
    }
  }

  static double convertFromIDR(double idrAmount, String toCurrency) {
    final rate = _currentRates[toCurrency] ?? _fallbackRates[toCurrency]!;
    return idrAmount * rate;
  }

  static double convertToIDR(double amount, String fromCurrency) {
    final rate = _currentRates[fromCurrency] ?? _fallbackRates[fromCurrency]!;
    return amount / rate;
  }

  static String formatCurrency(double amount, String currency) {
    switch (currency) {
      case 'IDR':
        return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'JPY':
        return '¥${amount.toStringAsFixed(0)}';
      case 'CNY':
        return '¥${amount.toStringAsFixed(2)}';
      default:
        return amount.toStringAsFixed(2);
    }
  }

  static List<String> getSupportedCurrencies() {
    return ['IDR', 'USD', 'JPY', 'CNY'];
  }

  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'IDR':
        return 'Rp';
      case 'USD':
        return '\$';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      default:
        return '';
    }
  }
}
