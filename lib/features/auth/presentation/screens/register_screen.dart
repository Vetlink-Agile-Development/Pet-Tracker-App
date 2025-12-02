import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_tracker/features/auth/presentation/providers/register_form_provider.dart';
import 'package:pet_tracker/shared/widgets/widgets.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);
    final registerNotifier = ref.read(registerFormProvider.notifier);

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
                          "Crea tu cuenta",
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
                      CustomTextFormField(
                        label: 'Nombre de usuario',
                        onChanged: registerNotifier.onUsernameChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.username.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'Correo electrónico',
                        onChanged: registerNotifier.onEmailChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.email.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'Nombre',
                        onChanged: registerNotifier.onFirstNameChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.firstName.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'Apellido',
                        onChanged: registerNotifier.onLastNameChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.lastName.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'Contraseña',
                        obscureText: true,
                        onChanged: registerNotifier.onPasswordChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.password.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'Confirmar Contraseña',
                        obscureText: true,
                        onChanged: registerNotifier.onConfirmPasswordChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.confirmPassword.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: registerForm.acceptedTerms,
                            onChanged: (value) {
                              registerNotifier.onAcceptedTermsChanged(value ?? false);
                            },
                            activeColor: const Color(0xFF08273A),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                registerNotifier.onAcceptedTermsChanged(!registerForm.acceptedTerms);
                              },
                              child: const Text(
                                'Acepto los términos y condiciones y las políticas de privacidad de PetTracker',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (registerForm.isFormPosted && !registerForm.acceptedTerms)
                        const Padding(
                          padding: EdgeInsets.only(left: 12, top: 4),
                          child: Text(
                            'Debes aceptar los términos y condiciones para continuar',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: CustomFilledButton(
                          text: 'Registrarse',
                          buttonColor: const Color(0xFF08273A),
                          onPressed: registerForm.isPosting
                              ? null
                              : () async {
                                  if (!registerForm.acceptedTerms) {
                                    showSnackBar(context, 'Debes aceptar los términos y condiciones');
                                    return;
                                  }
                                  if (registerForm.password.value != registerForm.confirmPassword.value) {
                                    showSnackBar(context, 'Las contraseñas no coinciden');
                                    return;
                                  }
                                  await registerNotifier.onFormSubmit();
                                  final updatedForm = ref.read(registerFormProvider);
                                  if (updatedForm.registrationSuccess) {
                                    if (context.mounted) {
                                      showSnackBar(context, 'Usuario registrado exitosamente');
                                      context.go('/login');
                                    }
                                  }
                                },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "¿Ya tienes una cuenta?",
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/login');
                            },
                            child: const Text(
                              'Inicia sesión aquí',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
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
}
