import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../services/api_exception.dart';

/// Clase base genérica para providers que siguen el mismo patrón
/// Reduce código duplicado entre CategoryProvider, ProductProvider y SupplierProvider
abstract class BaseProvider<T> extends ChangeNotifier {
  List<T> _items = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<T> get items => _items;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  /// Carga los items desde el servicio
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await fetchItemsFromService();
    } catch (e) {
      _error = _mapError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ejecuta una operación (crear, actualizar o eliminar) y recarga los items
  Future<({bool ok, String message})> executeOperation(
    Future<String> Function() operation,
  ) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final message = await operation();
      await loadItems();
      return (ok: true, message: message);
    } catch (e) {
      final message = _mapError(e);
      _error = message;
      return (ok: false, message: message);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Mapea errores a mensajes legibles
  String _mapError(Object error) {
    if (error is ApiException) {
      return 'Error ${error.statusCode}: ${error.message}';
    }
    return 'Ocurrió un error inesperado: $error';
  }

  /// Método abstracto que debe implementar cada provider
  Future<List<T>> fetchItemsFromService();
}
