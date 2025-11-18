import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reset_password_repository.dart';

final resetPasswordRepositoryProvider = Provider<ResetPasswordRepository>((ref) {
  return ResetPasswordRepository();
});

class ResetPasswordNotifier extends StateNotifier<AsyncValue<void>> {
  final ResetPasswordRepository _repository;

  ResetPasswordNotifier(this._repository) : super(const AsyncData(null));

  Future<void> sendRecoveryEmail(String email) async {
    state = const AsyncLoading();
    try {
      await _repository.requestPasswordReset(email);
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

final resetPasswordProvider = StateNotifierProvider<ResetPasswordNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(resetPasswordRepositoryProvider);
  return ResetPasswordNotifier(repository);
});