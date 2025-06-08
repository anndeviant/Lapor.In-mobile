import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/connectivity_service.dart';
import '../../services/auth_service.dart';
import '../../services/credit_service.dart';
import '../../services/currency_service.dart';
import '../../models/user_credit.dart';
import '../widgets/connection_popup.dart';
import 'create_report_page.dart';

class LaporPage extends StatefulWidget {
  const LaporPage({super.key});

  @override
  State<LaporPage> createState() => _LaporPageState();
}

class _LaporPageState extends State<LaporPage> {
  bool _showConnectionPopup = false;
  UserCredit? _userCredit;
  bool _isLoadingCredit = true;
  String? _userPhoneNumber;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadUserCreditData();
    ConnectivityService.startMonitoring(_onConnectivityChanged);
  }

  Future<void> _loadUserCreditData() async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          _userPhoneNumber = currentUser.phoneNumber;
        });

        final userCredit = await CreditService.getUserCredit(
          currentUser.phoneNumber,
        );
        await CurrencyService.updateExchangeRates();

        setState(() {
          _userCredit = userCredit;
          _isLoadingCredit = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCredit = false;
      });
    }
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

  Future<void> _onCreateReportPressed() async {
    if (_userCredit == null || _userPhoneNumber == null) return;

    final reportCost = CreditService.getReportCost();

    if (_userCredit!.creditBalance < reportCost) {
      _showInsufficientCreditDialog();
      return;
    }

    // Navigate to create report page
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );

    if (mounted) {
      // Listen for when user returns from create report page
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  const CreateReportPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

      // Refresh credit balance when returning
      await _loadUserCreditData();
    }
  }

  void _showInsufficientCreditDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Insufficient Credit'),
            content: const Text(
              'You don\'t have enough credit to create a report. Credits will be automatically recharged at 4:00 AM daily.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _changeCurrency() async {
    if (_userCredit == null || _userPhoneNumber == null) return;

    final currencies = CurrencyService.getSupportedCurrencies();
    final selectedCurrency = await showDialog<String>(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Compact Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.currency_exchange,
                          color: Colors.blue.shade700,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Select Currency',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Compact Currency options
                  ...currencies.map((currency) {
                    final isSelected =
                        currency == _userCredit!.preferredCurrency;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(currency),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.blue.shade700
                                        : Colors.grey.shade300,
                                width: isSelected ? 1.5 : 1,
                              ),
                              color:
                                  isSelected
                                      ? Colors.blue.shade50
                                      : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                // Compact currency symbol circle
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.blue.shade100
                                            : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      CurrencyService.getCurrencySymbol(
                                        currency,
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isSelected
                                                ? Colors.blue.shade700
                                                : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Currency info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getCurrencyName(currency),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected
                                                  ? Colors.blue.shade700
                                                  : Colors.grey.shade800,
                                        ),
                                      ),
                                      Text(
                                        currency,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Selection indicator
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.blue.shade700,
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Compact Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    if (selectedCurrency != null &&
        selectedCurrency != _userCredit!.preferredCurrency) {
      await CreditService.updatePreferredCurrency(
        _userPhoneNumber!,
        selectedCurrency,
      );
      await _loadUserCreditData();
    }
  }

  String _getCurrencyName(String currency) {
    switch (currency) {
      case 'IDR':
        return 'Indonesian Rupiah';
      case 'USD':
        return 'US Dollar';
      case 'JPY':
        return 'Japanese Yen';
      case 'CNY':
        return 'Chinese Yuan';
      default:
        return currency;
    }
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
        SafeArea(
          child: SingleChildScrollView(
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

                // Credit Balance Card
                _buildCreditCard(),
                const SizedBox(height: 20),

                // Create Report Button
                _buildCreateReportButton(),
                const SizedBox(height: 20),

                // Quick Info Cards
                _buildInfoCards(),
              ],
            ),
          ),
        ),
        ConnectionPopup(isVisible: _showConnectionPopup),
      ],
    );
  }

  Widget _buildCreditCard() {
    if (_isLoadingCredit) {
      return Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade200.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_userCredit == null) {
      return const SizedBox.shrink();
    }

    final convertedBalance = CurrencyService.convertFromIDR(
      _userCredit!.creditBalance,
      _userCredit!.preferredCurrency,
    );

    final reportCost = CurrencyService.convertFromIDR(
      CreditService.getReportCost(),
      _userCredit!.preferredCurrency,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row - more compact
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Credit Balance',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _changeCurrency,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _userCredit!.preferredCurrency,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Balance amount - more compact
          Text(
            CurrencyService.formatCurrency(
              convertedBalance,
              _userCredit!.preferredCurrency,
            ),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Cost and recharge info in one row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Cost: ${CurrencyService.formatCurrency(reportCost, _userCredit!.preferredCurrency)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Daily Recharge at 4:00 AM',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateReportButton() {
    final hasEnoughCredit =
        _userCredit != null &&
        _userCredit!.creditBalance >= CreditService.getReportCost();

    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        onPressed: hasEnoughCredit ? _onCreateReportPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasEnoughCredit ? Colors.blue.shade700 : Colors.grey.shade400,
          foregroundColor: Colors.white,
          elevation: hasEnoughCredit ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasEnoughCredit ? Icons.add_circle_outline : Icons.block,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              hasEnoughCredit ? 'Create New Report' : 'Insufficient Credit',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
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
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.monetization_on_outlined,
          title: 'Credit System',
          description:
              'Each report costs credits. Your balance auto-recharges daily at 4:00 AM.',
          color: Colors.purple,
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
