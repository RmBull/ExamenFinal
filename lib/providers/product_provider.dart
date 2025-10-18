import '../models/product.dart';
import '../services/product_service.dart';
import 'base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  final ProductService _service;

  ProductProvider(this._service);

  // Alias para mantener compatibilidad con el código existente
  List<Product> get products => items;
  Future<void> loadProducts() => loadItems();

  @override
  Future<List<Product>> fetchItemsFromService() => _service.fetchProducts();

  Future<({bool ok, String message})> addProduct({
    required String name,
    required double price,
    required String imageUrl,
  }) {
    return executeOperation(() => _service.createProduct(
          name: name,
          price: price,
          imageUrl: imageUrl,
        ));
  }

  Future<({bool ok, String message})> updateProduct(Product product) {
    return executeOperation(() => _service.updateProduct(product));
  }

  Future<({bool ok, String message})> deleteProduct(int id) {
    return executeOperation(() => _service.deleteProduct(id));
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
