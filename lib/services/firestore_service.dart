import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../data/models/product.dart';
import '../data/models/sale.dart';
import '../data/models/auth/debt_model.dart';
import '../data/models/auth/activity_model.dart';
import '../services/auth_service.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _uuid = Uuid();

  static String get userId => AuthService.currentUser?.uid ?? '';

  // ============== PRODUCTS ==============

  static Future<void> addProduct({
    required String name,
    required double price,
    String? imageUrl,
    required int quantity,
  }) async {
    final now = DateTime.now();
    final product = Product(
      id: _uuid.v4(),
      name: name,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity,
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore
        .collection('products')
        .doc(product.id)
        .set(product.toMap());

    await _addActivity(
      type: ActivityType.productAdded,
      description: 'Added product: $name',
      amount: price,
      relatedId: product.id,
    );
  }

  static Future<void> updateProduct(Product product) async {
    final updated = product.copyWith(updatedAt: DateTime.now());
    await _firestore
        .collection('products')
        .doc(product.id)
        .set(updated.toMap());

    await _addActivity(
      type: ActivityType.productUpdated,
      description: 'Updated product: ${product.name}',
      amount: product.price,
      relatedId: product.id,
    );
  }

  static Future<void> deleteProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    final product = Product.fromMap(doc.data()!);

    await _firestore.collection('products').doc(productId).delete();

    await _addActivity(
      type: ActivityType.productDeleted,
      description: 'Deleted product: ${product.name}',
      amount: product.price,
      relatedId: productId,
    );
  }

  static Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList());
  }

  // ============== SALES ==============

  static Future<void> addSale({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double total,
  }) async {
    final sale = Sale(
      id: _uuid.v4(),
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('sales').doc(sale.id).set(sale.toMap());

    // Update product quantity
    final productDoc =
        await _firestore.collection('products').doc(productId).get();
    if (productDoc.exists) {
      final product = Product.fromMap(productDoc.data()!);
      final newQuantity = product.quantity - quantity;
      await _firestore.collection('products').doc(productId).update({
        'quantity': newQuantity,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    await _addActivity(
      type: ActivityType.sale,
      description: 'Sold $quantity x $productName',
      amount: total,
      relatedId: sale.id,
    );
  }

  static Stream<List<Sale>> getTodaySales() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('sales')
        .where('createdAt', isGreaterThan: startOfDay.toIso8601String())
        .where('createdAt', isLessThan: endOfDay.toIso8601String())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sale.fromMap(doc.data())).toList());
  }

  static Future<double> getTodayTotal() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('sales')
        .where('createdAt', isGreaterThan: startOfDay.toIso8601String())
        .where('createdAt', isLessThan: endOfDay.toIso8601String())
        .get();

    return snapshot.docs
        .fold<double>(0.0, (sum, doc) => sum + (doc.data()['total'] ?? 0.0));
  }

  static Future<Map<DateTime, double>> getLast7DaysSales() async {
    final Map<DateTime, double> totals = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final startOfDay = date;
      final endOfDay = date.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('sales')
          .where('createdAt', isGreaterThan: startOfDay.toIso8601String())
          .where('createdAt', isLessThan: endOfDay.toIso8601String())
          .get();

      totals[date] = snapshot.docs
          .fold<double>(0.0, (sum, doc) => sum + (doc.data()['total'] ?? 0.0));
    }

    return totals;
  }

  // ============== DEBTS ==============

  static Future<void> addDebt({
    required String debtorName,
    String? debtorPhone,
    required double amount,
  }) async {
    final now = DateTime.now();
    final debt = DebtModel(
      id: _uuid.v4(),
      debtorName: debtorName,
      debtorPhone: debtorPhone,
      totalAmount: amount,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('debts').doc(debt.id).set(debt.toMap());

    await _addActivity(
      type: ActivityType.debt,
      description: 'Debt added for $debtorName',
      amount: amount,
      relatedId: debt.id,
    );
  }

  static Future<void> addDebtPayment({
    required String debtId,
    required double amount,
    String? note,
  }) async {
    final doc = await _firestore.collection('debts').doc(debtId).get();
    if (!doc.exists) return;

    final debt = DebtModel.fromMap(doc.data()!);
    final payment = DebtPayment(
      id: _uuid.v4(),
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );

    final updatedDebt = debt.copyWith(
      paidAmount: debt.paidAmount + amount,
      payments: [...debt.payments, payment],
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('debts').doc(debtId).set(updatedDebt.toMap());

    await _addActivity(
      type: ActivityType.debtPayment,
      description:
          'Payment of ${amount.toStringAsFixed(2)} for ${debt.debtorName}',
      amount: amount,
      relatedId: debtId,
    );
  }

  static Future<void> deleteDebt(String debtId) async {
    await _firestore.collection('debts').doc(debtId).delete();
  }

  static Stream<List<DebtModel>> getDebts() {
    return _firestore
        .collection('debts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DebtModel.fromMap(doc.data())).toList());
  }

  static Future<double> getTotalDebts() async {
    final snapshot = await _firestore.collection('debts').get();
    return snapshot.docs.fold<double>(0.0, (sum, doc) {
      final debt = DebtModel.fromMap(doc.data());
      return sum + debt.remainingAmount;
    });
  }

  // ============== ACTIVITIES ==============

  static Future<void> _addActivity({
    required ActivityType type,
    required String description,
    double? amount,
    String? relatedId,
  }) async {
    final activity = ActivityModel(
      id: _uuid.v4(),
      type: type,
      description: description,
      amount: amount,
      relatedId: relatedId,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('activities')
        .doc(activity.id)
        .set(activity.toMap());
  }

  static Stream<List<ActivityModel>> getActivities() {
    return _firestore
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromMap(doc.data()))
            .toList());
  }
}
