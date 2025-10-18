import '../models/category.dart';
import '../services/category_service.dart';
import 'base_provider.dart';

class CategoryProvider extends BaseProvider<Category> {
  final CategoryService _service;

  CategoryProvider(this._service);

  // Alias para mantener compatibilidad con el código existente
  List<Category> get categories => items;
  Future<void> loadCategories() => loadItems();

  @override
  Future<List<Category>> fetchItemsFromService() => _service.fetchCategories();

  Future<({bool ok, String message})> addCategory({required String name}) {
    return executeOperation(() => _service.createCategory(name: name));
  }

  Future<({bool ok, String message})> updateCategory(Category category) {
    return executeOperation(() => _service.updateCategory(category));
  }

  Future<({bool ok, String message})> deleteCategory(int id) {
    return executeOperation(() => _service.deleteCategory(id));
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
