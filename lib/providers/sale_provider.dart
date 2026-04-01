import 'package:flutter/foundation.dart';
import '../data/models/sale.dart';
import '../services/firestore_service.dart';

class SaleProvider extends ChangeNotifier {
  double _todayTotal = 0;
  int _todayTransactionCount = 0;
  Map<DateTime, double> _weeklyTotals = {};
  bool _isLoading = false;

  double get todayTotal => _todayTotal;
  int get todayTransactionCount => _todayTransactionCount;
  Map<DateTime, double> get weeklyTotals => _weeklyTotals;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayTotal = await FirestoreService.getTodayTotal();
      _weeklyTotals = await FirestoreService.getLast7DaysSales();
      _todayTransactionCount = _weeklyTotals[DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      )]?.toInt() ?? 0;
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  void loadSalesStream(Stream<List<Sale>> stream) {
    stream.listen((sales) {
      // Handle sales if needed
      notifyListeners();
    });
  }

  Future<bool> recordSale({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
  }) async {
    try {
      final total = unitPrice * quantity;
      await FirestoreService.addSale(
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitPrice: unitPrice,
        total: total,
      );
      await loadDashboardData();
      return true;
    } catch (e) {
      return false;
    }
  }
}