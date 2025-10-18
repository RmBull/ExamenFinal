import '../models/category.dart';
import 'api_client.dart';
import 'api_exception.dart';

class CategoryService {
  final ApiClient _client;

  CategoryService(this._client);

  Future<List<Category>> fetchCategories() async {
    final data = await _client.getJson('/ejemplos/category_list_rest/');
    final list = data['Listado Categorias'] ?? data['Listado'];
    if (list is List) {
      return list
          .whereType<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList();
    }
    throw ApiException(500, 'Respuesta inesperada al listar categorías');
  }

  Future<String> createCategory({
    required String name,
  }) async {
    final data = await _client.postJson(
      '/ejemplos/category_add_rest/',
      {'category_name': name},
    );
    return _extractMessage(data, 'Categoría creada');
  }

  Future<String> updateCategory(Category category) async {
    final data = await _client.postJson(
      '/ejemplos/category_edit_rest/',
      category.toEditPayload(),
    );
    return _extractMessage(data, 'Categoría actualizada');
  }

  Future<String> deleteCategory(int id) async {
    final data = await _client.postJson(
      '/ejemplos/category_del_rest/',
      {'category_id': id},
    );
    return _extractMessage(data, 'Categoría eliminada');
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
