import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';  // <-- AÑADIDO
import 'package:pet_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:pet_tracker/features/auth/presentation/providers/providers.dart';
import 'package:pet_tracker/shared/widgets/widgets.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.listen(authProvider, (previous, current) {
      if (current.errorMessage.isNotEmpty) {
        showSnackBar(context, current.errorMessage);
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_img.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Iniciar sesión en",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "PetTracker",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _UsernameInput(),
                      const SizedBox(height: 20),
                      _PasswordInput(),
                      const SizedBox(height: 30),
                      _LoginButton(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "¿No tienes una cuenta?",
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push('/register');
                            },
                            child: const Text(
                              'Regístrate aquí',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          showForgotPasswordDialog(context, ref);
                        },
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(color: Colors.blue),
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
    );
  }

  void showForgotPasswordDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final passwordResetState = ref.watch(passwordResetProvider);

            // Escuchar cambios de estado para mostrar mensajes
            ref.listen(passwordResetProvider, (previous, current) {
              if (current.isSuccess) {
                Navigator.of(dialogContext).pop();
                showSnackBar(
                  context,
                  'Correo de restablecimiento enviado exitosamente. Por favor revisa tu bandeja de entrada.',
                );
                ref.read(passwordResetProvider.notifier).resetState();
              } else if (current.errorMessage != null) {
                showSnackBar(context, current.errorMessage!);
              }
            });

            return AlertDialog(
              title: const Text(
                'Restablecer Contraseña',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ingresa tu dirección de correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Por favor ingresa un correo válido';
                        }
                        return null;
                      },
                      enabled: !passwordResetState.isLoading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: passwordResetState.isLoading
                      ? null
                      : () {
                          emailController.dispose();
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: passwordResetState.isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            ref
                                .read(passwordResetProvider.notifier)
                                .sendPasswordResetEmail(emailController.text.trim());
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08273A),
                    foregroundColor: Colors.white,
                  ),
                  child: passwordResetState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Enviar Enlace'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _UsernameInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);

    return CustomTextFormField(
      label: 'Nombre de usuario',
      keyboardType: TextInputType.text,
      onChanged: ref.read(loginFormProvider.notifier).onUsernameChanged,
      errorMessage:
          loginForm.isFormPosted ? loginForm.username.errorMessage : null,
    );
  }
}

class _PasswordInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);

    return CustomTextFormField(
      label: 'Contraseña',
      obscureText: true,
      onChanged: ref.read(loginFormProvider.notifier).onPasswordChanged,
      errorMessage:
          loginForm.isFormPosted ? loginForm.password.errorMessage : null,
    );
  }
}

class _LoginButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);

    return SizedBox(
      width: double.infinity,
      child: CustomFilledButton(
        text: 'Iniciar sesión',
        buttonColor: const Color(0xFF08273A),
        onPressed: loginForm.isPosting
            ? null
            : ref.read(loginFormProvider.notifier).onFormSubmit,
      ),
    );
  }
}
