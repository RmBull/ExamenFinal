import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'products_screen.dart';
import 'categories_screen.dart';
import 'suppliers_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar la sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar sesión')),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión cerrada')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de gestión'),
      ),
      body: Stack(
        children: [
          // Burbujas decorativas de fondo (primero para que queden atrás)
          ..._buildBubbles(scheme),
          // Contenido principal (después para que quede adelante)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            if (email.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Hola, $email',
                    style: Theme.of(context).textTheme.labelLarge),
              ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _MenuCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Productos',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProductsScreen()),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.category_outlined,
                    label: 'Categorías',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CategoriesScreen()),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.store_outlined,
                    label: 'Proveedores',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SuppliersScreen()),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.logout,
                    label: 'Cerrar sesión',
                    onTap: () => _confirmLogout(context),
                    color: Theme.of(context).colorScheme.errorContainer,
                    foreground: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ],
              ),
            ),
          ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBubbles(ColorScheme scheme) {
    return [
      Positioned(
        bottom: 350,
        right: 30,
        child: _Bubble(size: 70, color: scheme.secondary.withValues(alpha: 0.01)),
      ),
      Positioned(
        bottom: 200,
        left: 50,
        child: _Bubble(size: 100, color: scheme.tertiary.withValues(alpha: 0.01)),
      ),
      Positioned(
        bottom: 100,
        right: 60,
        child: _Bubble(size: 80, color: scheme.primary.withValues(alpha: 0.01)),
      ),
      Positioned(
        bottom: 50,
        left: 70,
        child: _Bubble(size: 60, color: scheme.secondary.withValues(alpha: 0.01)),
      ),
    ];
  }
}

class _Bubble extends StatelessWidget {
  final double size;
  final Color color;

  const _Bubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? foreground;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = color ?? scheme.primaryContainer.withValues(alpha: 0.35);
    final fg = foreground ?? scheme.onPrimaryContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: fg),
              const SizedBox(height: 10),
              Text(label,
                  style: TextStyle(fontWeight: FontWeight.w600, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
