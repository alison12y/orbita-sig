import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import '../domain/entities/app_user.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFrontSide = true;

  // Controllers for Login
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Controllers for Register
  final _registerFormKey = GlobalKey<FormState>();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _animation.addListener(() {
      if (_animation.value > 0.5 && _showFrontSide) {
        setState(() => _showFrontSide = false);
      } else if (_animation.value <= 0.5 && !_showFrontSide) {
        setState(() => _showFrontSide = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _switchCard() {
    if (_showFrontSide) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleLogin() {
    if (_loginFormKey.currentState!.validate()) {
      ref
          .read(authControllerProvider.notifier)
          .login(
            email: _loginEmailController.text.trim(),
            password: _loginPasswordController.text.trim(),
          );
    }
  }

  void _handleRegister() {
    if (_registerFormKey.currentState!.validate()) {
      ref
          .read(authControllerProvider.notifier)
          .register(
            name: _registerNameController.text.trim(),
            email: _registerEmailController.text.trim(),
            password: _registerPasswordController.text.trim(),
            type: 'tutor',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes
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

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FA), // Light soft gray
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Title & Slogan (Visible above card)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_orbita.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Órbita',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF1A237E),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seguridad infantil en tiempo real',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3D Flip Card
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      // 3D Transform
                      final angle = _animation.value * math.pi;
                      final transform = Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective
                        ..rotateY(angle);

                      return Transform(
                        transform: transform,
                        alignment: Alignment.center,
                        child: _showFrontSide
                            ? _buildFrontCard(isLoading)
                            : Transform(
                                transform: Matrix4.identity()..rotateY(math.pi),
                                alignment: Alignment.center,
                                child: _buildBackCard(isLoading),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(bool isLoading) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Text(
                  'Iniciar Sesión',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          // Form
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Form(
              key: _loginFormKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _loginEmailController,
                    label: 'Correo Electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _loginPasswordController,
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Solo visual por ahora
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: const Color(0xFF00BCD4),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Ingresar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading ? null : _switchCard,
                    child: Text(
                      '¿No tienes cuenta? Regístrate',
                      style: TextStyle(
                        color: const Color(0xFF1A237E).withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Child Login Button
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => context.go('/child-login'),
                    icon: const Icon(Icons.child_care_rounded, size: 20),
                    label: const Text('Soy un Hijo', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00BCD4),
                      side: const BorderSide(color: Color(0xFF00BCD4), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(bool isLoading) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Text(
                  'Crear Cuenta',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          // Form
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Form(
              key: _registerFormKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _registerNameController,
                    label: 'Nombre Completo',
                    icon: Icons.person_outline,
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _registerEmailController,
                    label: 'Correo Electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _registerPasswordController,
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) =>
                        (v?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
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
                  TextButton(
                    onPressed: isLoading ? null : _switchCard,
                    child: Text(
                      'Volver al Login',
                      style: TextStyle(
                        color: const Color(0xFF1A237E).withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFF1A237E),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}
