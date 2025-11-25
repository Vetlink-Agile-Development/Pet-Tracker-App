
import 'package:pet_tracker/features/auth/domain/datasources/password_reset_datasource.dart';
import 'package:pet_tracker/features/auth/domain/repositories/password_reset_repository.dart';

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  final PasswordResetDatasource datasource;

  PasswordResetRepositoryImpl({required this.datasource});

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return datasource.sendPasswordResetEmail(email);
  }
}