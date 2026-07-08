import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import '../domain/entities/app_user.dart';

class ChildLoginScreen extends ConsumerStatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  ConsumerState<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends ConsumerState<ChildLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String? _validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el código';
    }

    if (value.length != 6) {
      return 'El código debe tener 6 caracteres';
    }

    final regex = RegExp(r'^[A-Z0-9]{6}$');
    if (!regex.hasMatch(value)) {
      return 'Solo letras y números en mayúsculas';
    }

    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .loginWithCode(code: _codeController.text.toUpperCase());
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes
    ref.listen<AsyncValue<AppUser?>>(authControllerProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null && user.type == 'hijo') {
            context.go('/child-home');
          }
        },
        error: (error, stackTrace) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
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
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
                  onPressed: () => context.go('/login'),
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon
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
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Órbita Hijo',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: const Color(0xFF1A237E),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ingresa tu código de vinculación',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 48),

                        // Login Card
                        Container(
                          padding: const EdgeInsets.all(32),
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
                              children: [
                                // QR Icon
                                const Icon(
                                  Icons.qr_code_scanner,
                                  size: 64,
                                  color: Color(0xFF00BCD4),
                                ),
                                const SizedBox(height: 24),

                                // Code Input
                                TextFormField(
                                  controller: _codeController,
                                  decoration: InputDecoration(
                                    labelText: 'Código de vinculación',
                                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 16, letterSpacing: 0),
                                    hintText: 'A3B7K9',
                                    hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 8),
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
                                    prefixIcon: Icon(Icons.vpn_key, color: Colors.grey[400]),
                                    counterText: '',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  ),
                                  maxLength: 6,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    letterSpacing: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A237E),
                                  ),
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[A-Z0-9]'),
                                    ),
                                    UpperCaseTextFormatter(),
                                  ],
                                  validator: _validateCode,
                                  enabled: !_isLoading,
                                ),
                                const SizedBox(height: 32),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A237E),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Ingresar',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Help Text
                                Text(
                                  'Si no tienes un código, pídele a tu tutor que te registre',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
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
            ],
          ),
        ),
      ),
    );
  }
}

// Custom formatter to convert to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
