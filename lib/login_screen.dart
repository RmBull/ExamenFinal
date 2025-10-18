import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // false = Ingresar, true = Crear cuenta
  bool _isRegister = false;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (_isRegister) {
        // Crear cuenta
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text,
        );

        await cred.user!.updateDisplayName(_name.text.trim());

        final uid = cred.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'displayName': _name.text.trim(),
          'email': _email.text.trim(),
          'city': '',
          'comuna': '',
          'address': '',
          'phone': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada. ¡Bienvenido!')),
        );
        // AuthGate escuchará y enviará al Home
      } else {
        // Ingresar
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text,
        );
        // AuthGate te lleva al Home
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = _mapAuthError(e.code);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    } finally {
      // ❌ sin return dentro de finally
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Correo inválido';
      case 'user-not-found':
      case 'wrong-password':
        return 'Credenciales incorrectas';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'network-request-failed':
        return 'Revisa tu conexión a internet';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'No fue posible procesar tu solicitud ($code)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primaryContainer.withValues(alpha: 0.6),
                  scheme.secondaryContainer.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Burbujas decorativas
          ..._buildBubbles(scheme),
          // Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      scheme.primary,
                                      scheme.primaryContainer,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.store_rounded,
                                  size: 32,
                                  color: scheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gestión',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                      color: scheme.primary,
                                      height: 1.0,
                                    ),
                                  ),
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        scheme.primary,
                                        scheme.secondary,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Comercial',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: scheme.primary.withValues(alpha: 0.4),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isRegister
                                ? 'Crea tu cuenta para comprar'
                                : 'Inicia sesión para continuar',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),

                          // SegmentedButton correcto (requiere value:)
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(
                                value: false,
                                label: Text('Ingresar'),
                              ),
                              ButtonSegment<bool>(
                                value: true,
                                label: Text('Crear cuenta'),
                              ),
                            ],
                            selected: {_isRegister},
                            onSelectionChanged: (selection) {
                              setState(() => _isRegister = selection.first);
                            },
                            showSelectedIcon: false,
                          ),
                          const SizedBox(height: 18),

                          if (_isRegister) ...[
                            TextFormField(
                              controller: _name,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Nombre para mostrar',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Requerido'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                          ],

                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Ingresa tu correo'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _pass,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _obscure = !_obscure,
                                ),
                                icon: Icon(_obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingresa tu contraseña';
                              }
                              if (_isRegister && v.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          if (_isRegister) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pass2,
                              obscureText: _obscure2,
                              decoration: InputDecoration(
                                labelText: 'Repite contraseña',
                                border: const OutlineInputBorder(),
                                prefixIcon:
                                    const Icon(Icons.lock_person_outlined),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure2 = !_obscure2),
                                  icon: Icon(_obscure2
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                              ),
                              validator: (v) {
                                if (!_isRegister) return null;
                                if (v == null || v.isEmpty) {
                                  return 'Confirma tu contraseña';
                                }
                                if (v != _pass.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isLoading ? null : _submit,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Icon(_isRegister
                                      ? Icons.person_add_alt_1
                                      : Icons.login_rounded),
                              label: Text(_isLoading
                                  ? (_isRegister
                                      ? 'Creando...'
                                      : 'Ingresando...')
                                  : (_isRegister
                                      ? 'Crear cuenta'
                                      : 'Ingresar')),
                            ),
                          ),

                          if (!_isRegister) ...[
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: () async {
                                // Capturamos el messenger ANTES del await
                                final messenger = ScaffoldMessenger.of(context);

                                if (_email.text.trim().isEmpty) {
                                  messenger.showSnackBar(const SnackBar(
                                      content: Text(
                                          'Escribe tu correo para recuperar')));
                                  return;
                                }
                                try {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                          email: _email.text.trim());

                                  // ya no usamos context; usamos messenger
                                  messenger.showSnackBar(const SnackBar(
                                      content: Text(
                                          'Te enviamos un correo de recuperación')));
                                } catch (e) {
                                  messenger.showSnackBar(SnackBar(
                                      content: Text('No se pudo enviar: $e')));
                                }
                              },
                              icon: const Icon(Icons.mail_outline, size: 18),
                              label: const Text('Olvidé mi contraseña'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBubbles(ColorScheme scheme) {
    return [
      Positioned(
        top: 50,
        left: 30,
        child: _Bubble(size: 80, color: scheme.primary.withValues(alpha: 0.15)),
      ),
      Positioned(
        top: 120,
        right: 50,
        child: _Bubble(size: 60, color: scheme.secondary.withValues(alpha: 0.12)),
      ),
      Positioned(
        top: 300,
        left: 60,
        child: _Bubble(size: 100, color: scheme.tertiary.withValues(alpha: 0.1)),
      ),
      Positioned(
        bottom: 150,
        right: 40,
        child: _Bubble(size: 70, color: scheme.primary.withValues(alpha: 0.18)),
      ),
      Positioned(
        bottom: 80,
        left: 80,
        child: _Bubble(size: 50, color: scheme.secondary.withValues(alpha: 0.15)),
      ),
      Positioned(
        top: 450,
        right: 100,
        child: _Bubble(size: 90, color: scheme.primaryContainer.withValues(alpha: 0.2)),
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
