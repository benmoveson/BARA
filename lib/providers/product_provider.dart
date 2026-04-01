import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/product.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<Product>> get productsStream => FirestoreService.getProducts();

  List<Product> get inStockProducts =>
      _products.where((p) => p.isInStock).toList();
  List<Product> get outOfStockProducts =>
      _products.where((p) => p.isOutOfStock).toList();

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      FirestoreService.getProducts().listen(
        (products) {
          _products = products;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadProducts(Stream<List<Product>> stream) {
    stream.listen(
      (products) {
        _products = products;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required int quantity,
    File? image,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? imageUrl;

      if (image != null) {
        imageUrl = await _uploadImage(image);
      }

      await FirestoreService.addProduct(
        name: name,
        price: price,
        imageUrl: imageUrl,
        quantity: quantity,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirestoreService.updateProduct(product);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirestoreService.deleteProduct(productId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('products')
          .child(DateTime.now().millisecondsSinceEpoch.toString());

      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
