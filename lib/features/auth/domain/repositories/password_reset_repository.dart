
abstract class PasswordResetRepository {
  Future<void> sendPasswordResetEmail(String email);
}