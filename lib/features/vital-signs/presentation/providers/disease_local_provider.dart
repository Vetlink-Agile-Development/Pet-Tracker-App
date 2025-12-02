import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';

final diseaseLocalProvider = StateNotifierProvider.family<
    DiseaseLocalNotifier,
    List<Map<String, dynamic>>,
    String>((ref, deviceId) {
  return DiseaseLocalNotifier(ref, deviceId);
});

class DiseaseLocalNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final Ref _ref;
  final String deviceId;
  late final dynamic _storage;

  DiseaseLocalNotifier(this._ref, this.deviceId) : super([]) {
    _storage = _ref.read(keyValueStorageServiceProvider);
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    try {
      final raw = await _storage.getValue<String>('diseases_$deviceId');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        state = decoded
            .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
            .toList();
      } else {
        state = [];
      }
    } catch (_) {
      state = [];
    }
  }

  Future<void> _persist() async {
    try {
      await _storage.setKeyValue<String>('diseases_$deviceId', jsonEncode(state));
    } catch (_) {
      // ignore persistence errors for now
    }
  }

  void addDisease(Map<String, dynamic> disease) {
    state = [...state, disease];
    _persist();
  }

  void updateDisease(int index, Map<String, dynamic> disease) {
    final newList = [...state];
    if (index < 0 || index >= newList.length) return;
    newList[index] = disease;
    state = newList;
    _persist();
  }

  void deleteDisease(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
    _persist();
  }
}
