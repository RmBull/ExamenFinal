import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/supplier.dart';
import '../providers/supplier_provider.dart';
import '../services/api_client.dart';
import '../services/supplier_service.dart';
import 'supplier_detail_screen.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupplierProvider(SupplierService(ApiClient()))
        ..loadSuppliers(),
      child: const _SuppliersView(),
    );
  }
}

class _SuppliersView extends StatefulWidget {
  const _SuppliersView();

  @override
  State<_SuppliersView> createState() => _SuppliersViewState();
}

class _SuppliersViewState extends State<_SuppliersView> {
  Future<void> _refresh(SupplierProvider provider) async {
    await provider.loadSuppliers();
  }

  Future<void> _showSupplierForm({Supplier? supplier}) async {
    final provider = context.read<SupplierProvider>();
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final lastNameCtrl =
        TextEditingController(text: supplier?.lastName ?? '');
    final mailCtrl = TextEditingController(text: supplier?.mail ?? '');
    String state = supplier?.state ?? 'Activo';
    final emailRegex =
        RegExp(r"^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}");

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => ChangeNotifierProvider<SupplierProvider>.value(
        value: provider,
        child: AlertDialog(
          title:
              Text(supplier == null ? 'Nuevo proveedor' : 'Editar proveedor'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lastNameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Apellido'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el apellido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: mailCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Correo'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el correo';
                      }
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: state,
                    decoration: const InputDecoration(labelText: 'Estado'),
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
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancelar'),
            ),
            Consumer<SupplierProvider>(
              builder: (_, notifier, __) {
                final submitting = notifier.isSubmitting;
                return FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          Navigator.pop(dialogCtx);
                          final result = supplier == null
                              ? await provider.addSupplier(
                                  name: nameCtrl.text.trim(),
                                  lastName: lastNameCtrl.text.trim(),
                                  mail: mailCtrl.text.trim(),
                                  state: state,
                                )
                              : await provider.updateSupplier(
                                  supplier.copyWith(
                                    name: nameCtrl.text.trim(),
                                    lastName: lastNameCtrl.text.trim(),
                                    mail: mailCtrl.text.trim(),
                                    state: state,
                                  ),
                                );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.message)),
                          );
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(supplier == null ? 'Crear' : 'Guardar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Supplier supplier) async {
    final provider = context.read<SupplierProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => ChangeNotifierProvider<SupplierProvider>.value(
        value: provider,
        child: AlertDialog(
          title: const Text('Eliminar proveedor'),
          content: Text('¿Eliminar a ${supplier.name} ${supplier.lastName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            Consumer<SupplierProvider>(
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
      final result = await provider.deleteSupplier(supplier.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierProvider>(
      builder: (context, provider, _) {
        final suppliers = provider.suppliers;
        final isLoading = provider.isLoading;
        final error = provider.error;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de proveedores'),
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
                              onPressed: provider.loadSuppliers,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        )
                      : suppliers.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: Text('No hay proveedores'),
                                ),
                              ],
                            )
                          : ListView.separated(
                              itemCount: suppliers.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (_, index) {
                                final supplier = suppliers[index];
                                final initial = supplier.name.trim().isEmpty
                                    ? '?'
                                    : supplier.name.trim()[0].toUpperCase();
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(initial),
                                  ),
                                  title:
                                      Text('${supplier.name} ${supplier.lastName}'),
                                  subtitle: Text(
                                      '${supplier.mail} | Estado: ${supplier.state}'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SupplierDetailScreen(
                                          supplier: supplier,
                                        ),
                                      ),
                                    );
                                  },
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _showSupplierForm(
                                            supplier: supplier,
                                          );
                                          break;
                                        case 'delete':
                                          _confirmDelete(supplier);
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
                : () => _showSupplierForm(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
          ),
        );
      },
    );
  }
}
