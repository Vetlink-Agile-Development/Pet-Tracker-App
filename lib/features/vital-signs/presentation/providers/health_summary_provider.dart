import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health_summary.dart';
import 'package:pet_tracker/features/vital-signs/presentation/providers/health_summary_repository_provider.dart';

class HealthSummaryState {
  final bool isLoading;
  final String? errorMessage;
  final List<HealthSummary> summaries;
  final DateTime selectedMonth;

  HealthSummaryState({
    this.isLoading = false,
    this.errorMessage,
    this.summaries = const [],
    DateTime? selectedMonth,
  }) : selectedMonth = selectedMonth ?? DateTime.now();

  HealthSummaryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<HealthSummary>? summaries,
    DateTime? selectedMonth,
  }) {
    return HealthSummaryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      summaries: summaries ?? this.summaries,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class HealthSummaryNotifier extends StateNotifier<HealthSummaryState> {
  final HealthSummaryService service;

  HealthSummaryNotifier(this.service) : super(HealthSummaryState()) {
    loadSummaries();
  }

  Future<void> loadSummaries({DateTime? forMonth}) async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await service.getSummaries(forMonth: forMonth ?? state.selectedMonth);
      state = state.copyWith(summaries: data as List<HealthSummary>, isLoading: false, selectedMonth: forMonth ?? state.selectedMonth);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> showPreviousMonth() async {
    final prev = DateTime(state.selectedMonth.year, state.selectedMonth.month - 1, 1);
    await loadSummaries(forMonth: prev);
  }

  Future<void> showNextMonth() async {
    final next = DateTime(state.selectedMonth.year, state.selectedMonth.month + 1, 1);
    await loadSummaries(forMonth: next);
  }

  Future<void> pickMonth(DateTime picked) async {
    final month = DateTime(picked.year, picked.month, 1);
    await loadSummaries(forMonth: month);
  }
}

// Provider
final healthSummaryProvider =
    StateNotifierProvider<HealthSummaryNotifier, HealthSummaryState>((ref) {
  final service = ref.read(healthSummaryServiceProvider);
  return HealthSummaryNotifier(service);
});
