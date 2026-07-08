import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../map/presentation/providers/children_provider.dart';
import 'widgets/codigo_vinculacion_dialog.dart';

class CreateChildScreen extends ConsumerStatefulWidget {
  const CreateChildScreen({super.key});

  @override
  ConsumerState<CreateChildScreen> createState() => _CreateChildScreenState();
}

class _CreateChildScreenState extends ConsumerState<CreateChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(childrenRepositoryProvider);
      final child = await repository.createChild(
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      if (mounted) {
        // Refresh the children list
        ref.invalidate(childrenProvider);

        // Mostrar diálogo con código de vinculación
        await _showCodigoDialog(child);

        if (mounted) {
          context.pop(); // Go back to profile
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.notification,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showCodigoDialog(child) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CodigoVinculacionDialog(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Agregar Hijo', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crear cuenta para hijo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa los datos para crear una cuenta que tu hijo usará para iniciar sesión.',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  if (value.length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Apellido (opcional)
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido (opcional)',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 2) {
                    return 'El apellido debe tener al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Teléfono (opcional)
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 7) {
                    return 'El teléfono debe tener al menos 7 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Nota informativa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF1A237E),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Se generará automáticamente un código de 6 caracteres que tu hijo usará para iniciar sesión. El correo y contraseña se crean automáticamente.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
