import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WalletService {
  final _storage = const FlutterSecureStorage();
  static const _balanceKey = 'wallet_balance';

  Future<double> getBalance() async {
    final balanceStr = await _storage.read(key: _balanceKey);
    return balanceStr != null ? double.tryParse(balanceStr) ?? 0.0 : 0.0;
  }

  Future<void> setBalance(double balance) async {
    await _storage.write(key: _balanceKey, value: balance.toString());
  }

  Future<bool> payWithWallet(double amount) async {
    double balance = await getBalance();
    if (balance >= amount) {
      balance -= amount;
      await setBalance(balance);
      return true;
    }
    return false;
  }
}
