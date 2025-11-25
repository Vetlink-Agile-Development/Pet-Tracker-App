
abstract class PasswordResetDatasource {
  Future<void> sendPasswordResetEmail(String email);
}