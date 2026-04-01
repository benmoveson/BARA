import 'package:uuid/uuid.dart';
import '../models/sale.dart';
import '../services/hive_service.dart';
import '../../core/utils/formatters.dart';

class SaleRepository {
  final _uuid = const Uuid();

  List<Sale> getAll() {
    return HiveService.salesBox.values.toList();
  }

  List<Sale> getByDate(DateTime date) {
    final start = Formatters.startOfDay(date);
    final end = Formatters.endOfDay(date);
    return HiveService.salesBox.values
        .where((s) => s.createdAt.isAfter(start) && s.createdAt.isBefore(end))
        .toList();
  }

  double getTotalForDate(DateTime date) {
    return getByDate(date).fold(0.0, (sum, sale) => sum + sale.total);
  }

  int getTransactionCountForDate(DateTime date) {
    return getByDate(date).length;
  }

  Map<DateTime, double> getLast7DaysTotals() {
    final Map<DateTime, double> totals = {};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      totals[date] = getTotalForDate(date);
    }
    
    return totals;
  }

  Future<Sale> add({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
  }) async {
    final total = unitPrice * quantity;
    final sale = Sale(
      id: _uuid.v4(),
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
      createdAt: DateTime.now(),
    );
    await HiveService.salesBox.put(sale.id, sale);
    return sale;
  }

  Future<void> delete(String id) async {
    await HiveService.salesBox.delete(id);
  }
}