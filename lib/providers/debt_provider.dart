import 'package:flutter/foundation.dart';
import '../data/models/auth/debt_model.dart';
import '../services/firestore_service.dart';

class DebtProvider extends ChangeNotifier {
  List<DebtModel> _debts = [];
  double _totalDebts = 0;
  bool _isLoading = false;
  String? _error;

  List<DebtModel> get debts => _debts;
  double get totalDebts => _totalDebts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<DebtModel>> get debtsStream => FirestoreService.getDebts();

  List<DebtModel> get unpaidDebts => _debts.where((d) => !d.isFullyPaid).toList();
  List<DebtModel> get paidDebts => _debts.where((d) => d.isFullyPaid).toList();

  void loadDebtsStream(Stream<List<DebtModel>> stream) {
    stream.listen(
      (debts) {
        _debts = debts;
        _totalDebts = debts.fold(0.0, (sum, debt) => sum + debt.remainingAmount);
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addDebt({
    required String debtorName,
    String? debtorPhone,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirestoreService.addDebt(
        debtorName: debtorName,
        debtorPhone: debtorPhone,
        amount: amount,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPayment({
    required String debtId,
    required double amount,
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirestoreService.addDebtPayment(
        debtId: debtId,
        amount: amount,
        note: note,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDebt(String debtId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirestoreService.deleteDebt(debtId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}