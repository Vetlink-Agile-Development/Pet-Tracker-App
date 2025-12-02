import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

final vaccinationLocalProvider = StateNotifierProvider.family<
    VaccinationLocalNotifier,
    List<Map<String, dynamic>>,
    String>((ref, deviceKey) {
  final storage = ref.read(keyValueStorageServiceProvider);
  return VaccinationLocalNotifier(storage, deviceKey);
});

class VaccinationLocalNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final KeyValueStorageService _storage;
  final String deviceKey;

  VaccinationLocalNotifier(this._storage, this.deviceKey) : super([]) {
    _loadFromStorage();
  }

  String _storageKey() => 'vaccinations:$deviceKey';

  Future<void> _loadFromStorage() async {
    try {
      final list = await _storage.getValue<List<String>>(_storageKey());
      if (list != null) {
        state = list.map((s) => json.decode(s) as Map<String, dynamic>).toList();
      } else {
        state = [];
      }
    } catch (_) {
      state = [];
    }
  }

  Future<void> _saveToStorage() async {
    final list = state.map((m) => json.encode(m)).toList();
    await _storage.setKeyValue<List<String>>(_storageKey(), list);
  }

  void addVaccination(Map<String, dynamic> vaccination) {
    state = [...state, vaccination];
    _saveToStorage();
  }

  void updateVaccination(int index, Map<String, dynamic> vaccination) {
    final newList = [...state];
    newList[index] = vaccination;
    state = newList;
    _saveToStorage();
  }

  void deleteVaccination(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
    _saveToStorage();
  }
}