import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/sale.dart';

class HiveService {
  static const String productsBoxName = 'products';
  static const String salesBoxName = 'sales';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(SaleAdapter());
    await Hive.openBox<Product>(productsBoxName);
    await Hive.openBox<Sale>(salesBoxName);
  }

  static Box<Product> get productsBox => Hive.box<Product>(productsBoxName);
  static Box<Sale> get salesBox => Hive.box<Sale>(salesBoxName);

  static Future<void> close() async {
    await Hive.close();
  }
}