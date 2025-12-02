import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:pet_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:pet_tracker/shared/shared.dart';

class RegisterFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool acceptedTerms;
  final bool registrationSuccess;
  final Username username;
  final Email email;
  final Name firstName;
  final Name lastName;
  final Password password;
  final Password confirmPassword;

  RegisterFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.acceptedTerms = false,
    this.registrationSuccess = false,
    this.username = const Username.pure(),
    this.email = const Email.pure(),
    this.firstName = const Name.pure(),
    this.lastName = const Name.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const Password.pure(),
  });

  RegisterFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? acceptedTerms,
    bool? registrationSuccess,
    Username? username,
    Email? email,
    Name? firstName,
    Name? lastName,
    Password? password,
    Password? confirmPassword,
  }) {
    return RegisterFormState(
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      registrationSuccess: registrationSuccess ?? this.registrationSuccess,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final Future<bool> Function(
    String username,
    String password,
    List<String> roles,
    String email,
    String firstName,
    String lastName,
  ) registerUserCallback;

  RegisterFormNotifier({required this.registerUserCallback}) : super(RegisterFormState());

  void onUsernameChanged(String value) {
    final newUsername = Username.dirty(value);
    state = state.copyWith(
      username: newUsername,
      isValid: _validateForm(newUsername, state.email, state.firstName, state.lastName, state.password, state.confirmPassword),
    );
  }

  void onEmailChanged(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: _validateForm(state.username, newEmail, state.firstName, state.lastName, state.password, state.confirmPassword),
    );
  }

  void onFirstNameChanged(String value) {
    final newFirstName = Name.dirty(value);
    state = state.copyWith(
      firstName: newFirstName,
      isValid: _validateForm(state.username, state.email, newFirstName, state.lastName, state.password, state.confirmPassword),
    );
  }

  void onLastNameChanged(String value) {
    final newLastName = Name.dirty(value);
    state = state.copyWith(
      lastName: newLastName,
      isValid: _validateForm(state.username, state.email, state.firstName, newLastName, state.password, state.confirmPassword),
    );
  }

  void onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: _validateForm(state.username, state.email, state.firstName, state.lastName, newPassword, state.confirmPassword),
    );
  }

  void onConfirmPasswordChanged(String value) {
    final newConfirmPassword = Password.dirty(value);
    state = state.copyWith(
      confirmPassword: newConfirmPassword,
      isValid: _validateForm(state.username, state.email, state.firstName, state.lastName, state.password, newConfirmPassword),
    );
  }

  void onAcceptedTermsChanged(bool value) {
    state = state.copyWith(
      acceptedTerms: value,
      isValid: _validateForm(state.username, state.email, state.firstName, state.lastName, state.password, state.confirmPassword),
    );
  }

  Future<void> onFormSubmit() async {
    _touchAllFields();
    if (!state.isValid) return;
    if (state.password.value != state.confirmPassword.value) return;
    if (!state.acceptedTerms) return;

    state = state.copyWith(isPosting: true, registrationSuccess: false);

    final success = await registerUserCallback(
      state.username.value,
      state.password.value,
      ['ROLE_USER'],
      state.email.value,
      state.firstName.value,
      state.lastName.value,
    );

    if (mounted) {
      state = state.copyWith(isPosting: false, registrationSuccess: success);
    }
  }

  void _touchAllFields() {
    final username = Username.dirty(state.username.value);
    final email = Email.dirty(state.email.value);
    final firstName = Name.dirty(state.firstName.value);
    final lastName = Name.dirty(state.lastName.value);
    final password = Password.dirty(state.password.value);
    final confirmPassword = Password.dirty(state.confirmPassword.value);

    state = state.copyWith(
      isFormPosted: true,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
      confirmPassword: confirmPassword,
      isValid: _validateForm(username, email, firstName, lastName, password, confirmPassword),
    );
  }

  bool _validateForm(
    Username username,
    Email email,
    Name firstName,
    Name lastName,
    Password password,
    Password confirmPassword,
  ) {
    final formValid = Formz.validate([username, email, firstName, lastName, password, confirmPassword]);
    final passwordsMatch = password.value == confirmPassword.value;
    return formValid && passwordsMatch && state.acceptedTerms;
  }
}

final registerFormProvider = StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return RegisterFormNotifier(
    registerUserCallback: (
      username,
      password,
      roles,
      email,
      firstName,
      lastName,
    ) =>
        authNotifier.registerUser(
          username,
          password,
          roles,
          email,
          firstName,
          lastName,
        ),
  );
});
