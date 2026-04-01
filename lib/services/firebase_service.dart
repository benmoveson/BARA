import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/product.dart';
import '../data/models/sale.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    await Firebase.initializeApp();

    // Register Hive adapters
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(SaleAdapter());

    await Hive.openBox<Product>('products');
    await Hive.openBox<Sale>('sales');
    await Hive.openBox('settings');
    await Hive.openBox('user');

    _isInitialized = true;
  }

  static bool get isInitialized => _isInitialized;
}
