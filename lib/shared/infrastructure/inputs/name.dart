import 'package:formz/formz.dart';

enum NameError { empty, tooShort }

class Name extends FormzInput<String, NameError> {
  const Name.pure() : super.pure('');
  const Name.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == NameError.empty) return 'El campo es requerido';
    if (displayError == NameError.tooShort) return 'Mínimo 2 caracteres';
    return null;
  }

  @override
  NameError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return NameError.empty;
    if (value.length < 2) return NameError.tooShort;
    return null;
  }
}
