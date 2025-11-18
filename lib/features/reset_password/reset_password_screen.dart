import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Si no tienes google_fonts, quita esto y usa TextStyle normal
import 'reset_password_provider.dart';

// Función para llamar al panel desde el Login
void showResetPasswordSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permite que el panel suba con el teclado
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Ajuste para el teclado
        ),
        child: const _ResetPasswordSheetContent(),
      );
    },
  );
}

class _ResetPasswordSheetContent extends ConsumerStatefulWidget {
  const _ResetPasswordSheetContent();

  @override
  ConsumerState<_ResetPasswordSheetContent> createState() => __ResetPasswordSheetContentState();
}

class __ResetPasswordSheetContentState extends ConsumerState<_ResetPasswordSheetContent> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final email = _emailController.text.trim();
      ref.read(resetPasswordProvider.notifier).sendRecoveryEmail(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordProvider);

    ref.listen(resetPasswordProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${next.error}'.replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      } else if (next is AsyncData && !next.isLoading && previous is AsyncLoading) {
        Navigator.pop(context); // Cierra el panel
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Listo! Revisa tu correo.'), backgroundColor: Colors.green),
        );
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 25,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
        children: [
          // La "pildora" gris para indicar que se puede deslizar
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 30),
          
          // Icono y Títulos
          const Icon(Icons.lock_outline_rounded, size: 60, color: Color(0xFF34A1DE)), // Tu color secundario
          const SizedBox(height: 16),
          Text(
            'Recuperar Contraseña',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF02273A), // Tu color primario oscuro
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tu email para recibir el enlace.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          
          const SizedBox(height: 30),

          // Formulario
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100], // Fondo gris muy claro para el input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // Sin borde por defecto
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF34A1DE), width: 1.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
          ),
          
          const SizedBox(height: 30),

          // Botón
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02273A), // Color oscuro elegante
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Enviar Enlace',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}