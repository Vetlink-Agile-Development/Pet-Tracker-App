import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/activities/domain/entities/activity.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';

import '../../infrastructure/datasources/activity_datasource_impl.dart';
import '../../infrastructure/repositories/activity_repository_impl.dart';

class ActivityNotifier extends StateNotifier<AsyncValue<List<Activity>>> {
  final ActivityRepositoryImpl repository;

  // paging + filters
  int _currentPage = 1;
  final int _pageSize = 20;
  bool hasMore = true;
  String? currentType;
  DateTime? currentFrom;
  DateTime? currentTo;

  // Cache the full dataset returned by the backend (server may ignore filters/pagination)
  List<Activity> _allActivities = [];

  // Exposed getters for UI
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMorePages => hasMore;
  int get totalCount => _allActivities.length;
  int get filteredCount => _applyFilters(_allActivities, currentType, currentFrom, currentTo).length;

  ActivityNotifier(this.repository) : super(const AsyncLoading());

  Future<void> fetchActivities(
    String deviceRecordId, {
    String? activityType,
    DateTime? from,
    DateTime? to,
    bool reset = true,
  }) async {
    try {
      if (reset) {
        _currentPage = 1;
        hasMore = true;
        state = const AsyncLoading();
      }

      currentType = activityType;
      currentFrom = from;
      currentTo = to;

      // Fetch from repository (server may return full unfiltered dataset)
      final fetched = await repository.getActivities(
        deviceRecordId,
        // request large pageSize to try to get all items if backend ignores paging
        page: 1,
        pageSize: 10000,
      );

      _allActivities = fetched;

      // Apply client-side filtering
      final filtered = _applyFilters(_allActivities, currentType, currentFrom, currentTo);

      // Paginate client-side
      final start = 0;
      final end = (_pageSize < filtered.length) ? _pageSize : filtered.length;
      final pageItems = filtered.sublist(start, end);
      state = AsyncValue.data(pageItems);

      hasMore = filtered.length > end;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchNextPage(String deviceRecordId) async {
    if (!hasMore) return;
    _currentPage += 1;

    // compute next page from cached & filtered results
    final filtered = _applyFilters(_allActivities, currentType, currentFrom, currentTo);
    final start = (_currentPage - 1) * _pageSize;
    if (start >= filtered.length) {
      hasMore = false;
      return;
    }
    final end = (start + _pageSize) < filtered.length ? (start + _pageSize) : filtered.length;
    final nextItems = filtered.sublist(start, end);

    final prev = state.asData?.value ?? [];
    state = AsyncValue.data([...prev, ...nextItems]);

    hasMore = end < filtered.length;
  }

  List<Activity> _applyFilters(List<Activity> list, String? type, DateTime? from, DateTime? to) {
    var res = list;
    if (type != null) {
      res = res.where((a) => a.activityType.toLowerCase() == type.toLowerCase()).toList();
    }
    if (from != null) {
      res = res.where((a) => a.dateAndTime.isAfter(from) || a.dateAndTime.isAtSameMomentAs(from)).toList();
    }
    if (to != null) {
      res = res.where((a) => a.dateAndTime.isBefore(to) || a.dateAndTime.isAtSameMomentAs(to)).toList();
    }
    return res;
  }
}

final activityRepositoryProvider = Provider<ActivityRepositoryImpl>((ref) {
  final datasource = ActivityDatasourceImpl(
    storageService: ref.watch(keyValueStorageServiceProvider),
  );
  return ActivityRepositoryImpl(datasource);
});

final activityProvider = StateNotifierProvider.family<ActivityNotifier,
    AsyncValue<List<Activity>>, String>((ref, deviceId) {
  final repo = ref.watch(activityRepositoryProvider);
  final notifier = ActivityNotifier(repo);
  notifier.fetchActivities(deviceId);
  return notifier;
});
