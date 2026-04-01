import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../services/hive_service.dart';

class ProductRepository {
  final _uuid = const Uuid();

  List<Product> getAll() {
    return HiveService.productsBox.values.toList();
  }

  Product? getById(String id) {
    try {
      return HiveService.productsBox.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Product> add(String name, double price) async {
    final product = Product(
      id: _uuid.v4(),
      name: name,
      price: price,
      createdAt: DateTime.now(),
    );
    await HiveService.productsBox.put(product.id, product);
    return product;
  }

  Future<void> delete(String id) async {
    await HiveService.productsBox.delete(id);
  }

  Future<void> update(Product product) async {
    await HiveService.productsBox.put(product.id, product);
  }
}