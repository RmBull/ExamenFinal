import '../models/supplier.dart';
import '../services/supplier_service.dart';
import 'base_provider.dart';

class SupplierProvider extends BaseProvider<Supplier> {
  final SupplierService _service;

  SupplierProvider(this._service);

  // Alias para mantener compatibilidad con el código existente
  List<Supplier> get suppliers => items;
  Future<void> loadSuppliers() => loadItems();

  @override
  Future<List<Supplier>> fetchItemsFromService() => _service.fetchSuppliers();

  Future<({bool ok, String message})> addSupplier({
    required String name,
    required String lastName,
    required String mail,
    required String state,
  }) {
    return executeOperation(() => _service.createSupplier(
          name: name,
          lastName: lastName,
          mail: mail,
          state: state,
        ));
  }

  Future<({bool ok, String message})> updateSupplier(Supplier supplier) {
    return executeOperation(() => _service.updateSupplier(supplier));
  }

  Future<({bool ok, String message})> deleteSupplier(int id) {
    return executeOperation(() => _service.deleteSupplier(id));
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
