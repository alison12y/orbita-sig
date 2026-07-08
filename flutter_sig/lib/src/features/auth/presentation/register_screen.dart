import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'widgets/auth_text_field.dart';
import '../domain/entities/app_user.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<AppUser?>>(authControllerProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            context.go('/map');
          }
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FA), // Light soft gray
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo_orbita.png',
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Crear Cuenta',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF1A237E),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Únete a ÓÓrbita',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Register Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthTextField(
                            controller: _nameController,
                            label: 'Nombre Completo',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu nombre';
                              }
                              return null;
                            },
                            hint: 'Ej. Juan Pérez',
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _emailController,
                            label: 'Correo Electrónico',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu correo';
                              }
                              if (!value.contains('@')) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
                            hint: 'Ej. juan@email.com',
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                            hint: '******',
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirmar Contraseña',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                            hint: '******',
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        ref
                                            .read(authControllerProvider.notifier)
                                            .register(
                                              name: _nameController.text.trim(),
                                              email: _emailController.text.trim(),
                                              password: _passwordController.text.trim(),
                                              type: 'tutor', // Default type
                                            );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿Ya tienes cuenta?',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: () => context.pop(),
                                child: Text(
                                  'Inicia Sesión',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF1A237E),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
