import 'package:hive/hive.dart';

part 'user_credit.g.dart';

@HiveType(typeId: 0)
class UserCredit extends HiveObject {
  @HiveField(0)
  String phoneNumber;

  @HiveField(1)
  double creditBalance; // in IDR

  @HiveField(2)
  DateTime lastRechargeDate;

  @HiveField(3)
  String preferredCurrency; // IDR, USD, JPY, CNY

  UserCredit({
    required this.phoneNumber,
    required this.creditBalance,
    required this.lastRechargeDate,
    this.preferredCurrency = 'IDR',
  });

  UserCredit copyWith({
    String? phoneNumber,
    double? creditBalance,
    DateTime? lastRechargeDate,
    String? preferredCurrency,
  }) {
    return UserCredit(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      creditBalance: creditBalance ?? this.creditBalance,
      lastRechargeDate: lastRechargeDate ?? this.lastRechargeDate,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    );
  }
}
