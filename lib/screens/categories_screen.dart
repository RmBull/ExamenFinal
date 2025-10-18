import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/category_provider.dart';
import '../services/api_client.dart';
import '../services/category_service.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryProvider(CategoryService(ApiClient()))
        ..loadCategories(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  const _CategoriesView();

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  Future<void> _refresh(CategoryProvider provider) async {
    await provider.loadCategories();
  }

  Future<void> _showCategoryForm({Category? category}) async {
    final provider = context.read<CategoryProvider>();
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    String state = category?.state ?? 'Activa';

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => ChangeNotifierProvider<CategoryProvider>.value(
        value: provider,
        child: AlertDialog(
          title:
              Text(category == null ? 'Nueva categoría' : 'Editar categoría'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                  if (category != null) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: state,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Activa',
                          child: Text('Activa'),
                        ),
                        DropdownMenuItem(
                          value: 'Inactiva',
                          child: Text('Inactiva'),
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
            Consumer<CategoryProvider>(
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
                          final result = category == null
                              ? await provider.addCategory(
                                  name: nameCtrl.text.trim(),
                                )
                              : await provider.updateCategory(
                                  category.copyWith(
                                    name: nameCtrl.text.trim(),
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
                      : Text(category == null ? 'Crear' : 'Guardar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Category category) async {
    final provider = context.read<CategoryProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => ChangeNotifierProvider<CategoryProvider>.value(
        value: provider,
        child: AlertDialog(
          title: const Text('Eliminar categoría'),
          content: Text('¿Eliminar "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            Consumer<CategoryProvider>(
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
      final result = await provider.deleteCategory(category.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;
        final isLoading = provider.isLoading;
        final error = provider.error;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de categorías'),
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
                              onPressed: provider.loadCategories,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        )
                      : categories.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: Text('No hay categorías'),
                                ),
                              ],
                            )
                          : ListView.separated(
                              itemCount: categories.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (_, index) {
                                final category = categories[index];
                                return ListTile(
                                  leading: Icon(
                                    category.isActive
                                        ? Icons.label
                                        : Icons.label_off,
                                    color: category.isActive
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                  title: Text(category.name),
                                  subtitle:
                                      Text('Estado: ${category.state}'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CategoryDetailScreen(
                                          category: category,
                                        ),
                                      ),
                                    );
                                  },
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _showCategoryForm(
                                            category: category,
                                          );
                                          break;
                                        case 'delete':
                                          _confirmDelete(category);
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
                : () => _showCategoryForm(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
          ),
        );
      },
    );
  }
}
