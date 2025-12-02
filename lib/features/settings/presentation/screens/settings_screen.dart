import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:pet_tracker/features/settings/presentation/widgets/save_change_modal.dart';
import 'package:pet_tracker/shared/infrastructure/inputs/inputs.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = ref.watch(authProvider);
    final userProfile = authState.userProfile;

    if (userProfile != null) {
      _emailController.text = userProfile.email;
      _nameController.text = userProfile.firstName;
      _surnameController.text = userProfile.lastName;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _validateAndSave() {
    final email = Email.dirty(_emailController.text);
    final name = Name.dirty(_nameController.text);
    final surname = Name.dirty(_surnameController.text);
    
    // Validar email
    if (email.error == EmailError.empty) {
      _showSnackBar(context, 'El correo electrónico es requerido');
      return;
    }
    if (email.error == EmailError.format) {
      _showSnackBar(context, 'El formato del correo es inválido');
      return;
    }
    
    // Validar nombre
    if (name.error == NameError.empty) {
      _showSnackBar(context, 'El nombre es requerido');
      return;
    }
    if (name.error == NameError.tooShort) {
      _showSnackBar(context, 'El nombre debe tener al menos 2 caracteres');
      return;
    }
    
    // Validar apellido
    if (surname.error == NameError.empty) {
      _showSnackBar(context, 'El apellido es requerido');
      return;
    }
    if (surname.error == NameError.tooShort) {
      _showSnackBar(context, 'El apellido debe tener al menos 2 caracteres');
      return;
    }

    // Validar contraseña solo si se ingresó una nueva
    String? newPassword;
    if (_newPasswordController.text.isNotEmpty) {
      final password = Password.dirty(_newPasswordController.text);
      final confirmPassword = _confirmPasswordController.text;

      if (password.error == PasswordError.length) {
        _showSnackBar(context, 'La contraseña debe tener al menos 6 caracteres');
        return;
      }
      if (password.error == PasswordError.format) {
        _showSnackBar(context,
            'La contraseña debe contener mayúscula, minúscula y un número');
        return;
      }

      if (password.value != confirmPassword) {
        _showSnackBar(context, 'Las contraseñas no coinciden');
        return;
      }
      
      newPassword = password.value;
    }

    _showSaveChangesModal(context, newPassword);
  }

  void _showSaveChangesModal(BuildContext context, String? newPassword) {
    showDialog(
      context: context,
      builder: (_) => SaveChangesModal(
        onCancel: () {
          _resetFields();
        },
        onSave: () async {
          try {
            final authState = ref.read(authProvider);
            final userId = authState.userProfile!.id;
            
            await ref.read(authProvider.notifier).updateUserProfile(
              userId: userId,
              email: _emailController.text,
              firstName: _nameController.text,
              lastName: _surnameController.text,
              newPassword: newPassword,
            );
            
            if (mounted) {
              context.pop();
              _showSnackBar(context, 'Perfil actualizado exitosamente');
              _resetPasswordFields();
            }
          } catch (e) {
            if (mounted) {
              context.pop();
              _showSnackBar(context, 'Error al actualizar el perfil: $e');
            }
          }
        },
      ),
    );
  }

  void _resetFields() {
    final authState = ref.read(authProvider);
    final userProfile = authState.userProfile;

    if (userProfile != null) {
      _emailController.text = userProfile.email;
      _nameController.text = userProfile.firstName;
      _surnameController.text = userProfile.lastName;
    }
    _resetPasswordFields();
  }
  
  void _resetPasswordFields() {
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userProfile = authState.userProfile;

    if (userProfile == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configuración',
              style: TextStyle(
                  color: Color(0xFF08273A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Selector de imagen de perfil
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE8F7FF),
                      radius: 60,
                      child: SvgPicture.asset(
                        'assets/images/user.svg',
                        width: 80,
                        height: 80,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF08273A),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   child: InkWell(
                    //     onTap: () {
                    //       // Implementar selección de imagen
                    //     },
                    //     child: Container(
                    //       padding: const EdgeInsets.all(6),
                    //       decoration: BoxDecoration(
                    //         color: Colors.black54,
                    //         borderRadius: BorderRadius.circular(50),
                    //       ),
                    //       child: const Text(
                    //         'SELECCIONAR IMAGEN',
                    //         style: TextStyle(color: Colors.white, fontSize: 12),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: 'Correo electrónico',
                  controller: _emailController,
                  icon: Icons.email,
                  isObscure: false,
                  isEnabled: true,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'Nombre',
                  controller: _nameController,
                  icon: Icons.person,
                  isObscure: false,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'Apellidos',
                  controller: _surnameController,
                  icon: Icons.person_outline,
                  isObscure: false,
                ),
                const SizedBox(height: 20),
                
                // Sección de cambio de contraseña (opcional)
                const Divider(),
                const Text(
                  'Cambiar Contraseña (Opcional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF08273A),
                  ),
                ),
                const SizedBox(height: 10),
                _buildPasswordField(
                  label: 'Nueva Contraseña',
                  controller: _newPasswordController,
                  isObscure: _obscureNewPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildPasswordField(
                  label: 'Confirmar Nueva Contraseña',
                  controller: _confirmPasswordController,
                  isObscure: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _validateAndSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08273A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isObscure,
    bool isEnabled = true,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      enabled: isEnabled,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }
}
