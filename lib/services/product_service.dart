import '../models/product.dart';
import 'api_client.dart';
import 'api_exception.dart';

class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  Future<List<Product>> fetchProducts() async {
    final data = await _client.getJson('/ejemplos/product_list_rest/');
    final list = data['Listado'] ?? data['listado'];
    if (list is List) {
      return list
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
    }
    throw ApiException(500, 'Respuesta inesperada al listar productos');
  }

  Future<String> createProduct({
    required String name,
    required double price,
    required String imageUrl,
  }) async {
    final payload = {
      'product_name': name,
      'product_price': price.round(),
      'product_image': imageUrl,
    };

    final data = await _client.postJson(
      '/ejemplos/product_add_rest/',
      payload,
    );

    return _extractMessage(data, 'Producto creado correctamente');
  }

  Future<String> updateProduct(Product product) async {
    final data = await _client.postJson(
      '/ejemplos/product_edit_rest/',
      product.toEditPayload(),
    );

    return _extractMessage(data, 'Producto actualizado');
  }

  Future<String> deleteProduct(int id) async {
    final data = await _client.postJson(
      '/ejemplos/product_del_rest/',
      {'product_id': id},
    );

    return _extractMessage(data, 'Producto eliminado');
  }

  String _extractMessage(Map<String, dynamic> data, String fallback) {
    final candidates = [
      data['message'],
      data['detalle'],
      data['detail'],
      data['status'],
      data['resultado'],
      data['response'],
    ];
    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate;
      }
    }
    return fallback;
  }

  void dispose() {
    _client.dispose();
  }
}
