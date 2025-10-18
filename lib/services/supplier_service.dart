import '../models/supplier.dart';
import 'api_client.dart';
import 'api_exception.dart';

class SupplierService {
  final ApiClient _client;

  SupplierService(this._client);

  Future<List<Supplier>> fetchSuppliers() async {
    final data = await _client.getJson('/ejemplos/provider_list_rest/');
    final list = data['Proveedores Listado'] ?? data['Listado'];
    if (list is List) {
      return list
          .whereType<Map<String, dynamic>>()
          .map(Supplier.fromJson)
          .toList();
    }
    throw ApiException(500, 'Respuesta inesperada al listar proveedores');
  }

  Future<String> createSupplier({
    required String name,
    required String lastName,
    required String mail,
    required String state,
  }) async {
    final data = await _client.postJson(
      '/ejemplos/provider_add_rest/',
      {
        'provider_name': name,
        'provider_last_name': lastName,
        'provider_mail': mail,
        'provider_state': state,
      },
    );
    return _extractMessage(data, 'Proveedor creado');
  }

  Future<String> updateSupplier(Supplier supplier) async {
    final data = await _client.postJson(
      '/ejemplos/provider_edit_rest/',
      supplier.toEditPayload(),
    );
    return _extractMessage(data, 'Proveedor actualizado');
  }

  Future<String> deleteSupplier(int id) async {
    final data = await _client.postJson(
      '/ejemplos/provider_del_rest/',
      {'provider_id': id},
    );
    return _extractMessage(data, 'Proveedor eliminado');
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
