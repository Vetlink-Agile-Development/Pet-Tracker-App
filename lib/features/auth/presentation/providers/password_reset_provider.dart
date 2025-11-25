import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:pet_tracker/features/auth/infrastructure/datasources/password_reset_datasource_impl.dart';
import 'package:pet_tracker/features/auth/infrastructure/repositories/password_reset_repository_impl.dart';

// Estado para el password reset
class PasswordResetState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  PasswordResetState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  PasswordResetState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return PasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Notifier para manejar el password reset
class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  final PasswordResetRepository repository;

  PasswordResetNotifier({required this.repository})
      : super(PasswordResetState());

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      await repository.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send password reset email. Please try again.',
        isSuccess: false,
      );
    }
  }

  void resetState() {
    state = PasswordResetState();
  }
}

// Provider del repositorio
final passwordResetRepositoryProvider = Provider<PasswordResetRepository>((ref) {
  final datasource = PasswordResetDatasourceImpl();
  return PasswordResetRepositoryImpl(datasource: datasource);
});

// Provider del notifier
final passwordResetProvider =
    StateNotifierProvider<PasswordResetNotifier, PasswordResetState>((ref) {
  final repository = ref.watch(passwordResetRepositoryProvider);
  return PasswordResetNotifier(repository: repository);
});
