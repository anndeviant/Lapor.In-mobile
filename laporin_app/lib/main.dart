import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_credit.dart';
import 'models/notification.dart';
import 'models/user_profile.dart';
import 'utils/hive_box.dart';
import 'services/currency_service.dart';
import 'services/notification_service.dart';
import 'views/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserCreditAdapter());
  Hive.registerAdapter(AppNotificationAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  await Hive.openBox<UserCredit>(HiveBox.userCredits);
  await Hive.openBox<AppNotification>(HiveBox.notifications);
  await Hive.openBox<Map>(HiveBox.reportStatuses);
  await Hive.openBox<UserProfile>(HiveBox.userProfiles);

  // Initialize currency exchange rates
  await CurrencyService.updateExchangeRates();

  // Initialize notification service
  await NotificationService.initialize();

  // Set transparent status bar globally
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryBlueColor = Colors.blue.shade700;

    return MaterialApp(
      title: 'Lapor.In',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlueColor,
          primary: primaryBlueColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlueColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryBlueColor, width: 2),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade800,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          iconTheme: IconThemeData(color: Colors.grey.shade800),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: primaryBlueColor,
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900,
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}
