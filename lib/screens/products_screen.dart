import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../services/api_client.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(ProductService(ApiClient()))
        ..loadProducts(),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  Future<void> _refresh(ProductProvider provider) async {
    await provider.loadProducts();
  }

  Future<void> _showProductForm({Product? product}) async {
    final provider = context.read<ProductProvider>();
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final priceCtrl = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    final imageCtrl = TextEditingController(text: product?.imageUrl ?? '');
    String state = product?.state ?? 'Activo';

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return ChangeNotifierProvider<ProductProvider>.value(
          value: provider,
          child: AlertDialog(
          title: Text(product == null ? 'Nuevo producto' : 'Editar producto'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      prefixText: 'CLP ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el precio';
                      }
                      final parsed = double.tryParse(value.replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: imageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'URL de imagen',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa la URL de imagen';
                      }
                      return null;
                    },
                  ),
                  if (product != null) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: state,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Activo',
                          child: Text('Activo'),
                        ),
                        DropdownMenuItem(
                          value: 'Inactivo',
                          child: Text('Inactivo'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          state = value;
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancelar'),
            ),
            Consumer<ProductProvider>(
              builder: (_, notifier, __) {
                final submitting = notifier.isSubmitting;
                return FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          final parsedPrice = double.parse(
                            priceCtrl.text.replaceAll(',', '.'),
                          );
                          Navigator.pop(dialogCtx);
                          final result = product == null
                              ? await provider.addProduct(
                                  name: nameCtrl.text.trim(),
                                  price: parsedPrice,
                                  imageUrl: imageCtrl.text.trim(),
                                )
                              : await provider.updateProduct(
                                  product.copyWith(
                                    name: nameCtrl.text.trim(),
                                    price: parsedPrice,
                                    imageUrl: imageCtrl.text.trim(),
                                    state: state,
                                  ),
                                );
                          if (!mounted) return;
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(
                            SnackBar(content: Text(result.message)),
                          );
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(product == null ? 'Crear' : 'Guardar'),
                );
              },
            ),
          ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final provider = context.read<ProductProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => ChangeNotifierProvider<ProductProvider>.value(
        value: provider,
        child: AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text('¿Seguro que deseas eliminar "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            Consumer<ProductProvider>(
              builder: (_, notifier, __) {
                final submitting = notifier.isSubmitting;
                return FilledButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.pop(ctx, true),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Eliminar'),
                );
              },
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final result = await provider.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final products = provider.products;
        final isLoading = provider.isLoading;
        final error = provider.error;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de productos'),
          ),
          body: RefreshIndicator(
            onRefresh: () => _refresh(provider),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? ListView(
                          children: [
                            Text(error,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: provider.loadProducts,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        )
                      : products.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: Text('No hay productos cargados'),
                                ),
                              ],
                            )
                          : ListView.separated(
                              itemCount: products.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (_, index) {
                                final product = products[index];
                                final imageProvider = product.imageUrl.isNotEmpty
                                    ? NetworkImage(product.imageUrl)
                                    : null;

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: imageProvider,
                                    onBackgroundImageError: imageProvider != null
                                        ? (_, __) {}
                                        : null,
                                    child: imageProvider == null
                                        ? const Icon(Icons.image_not_supported)
                                        : null,
                                  ),
                                  title: Text(product.name),
                                  subtitle: Text(
                                    'Precio: ${product.price.toStringAsFixed(0)} | Estado: ${product.state}',
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(
                                          product: product,
                                        ),
                                      ),
                                    );
                                  },
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _showProductForm(product: product);
                                          break;
                                        case 'delete':
                                          _confirmDelete(product);
                                          break;
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Editar'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: provider.isSubmitting
                ? null
                : () => _showProductForm(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
          ),
        );
      },
    );
  }
}
