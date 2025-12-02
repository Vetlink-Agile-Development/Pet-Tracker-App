import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class SelectedDeviceNotifier extends StateNotifier<String?> {
  final KeyValueStorageService _storage;

  SelectedDeviceNotifier(this._storage) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final v = await _storage.getValue<String>('selectedDeviceRecordId');
    state = v;
  }

  Future<void> setSelected(String? deviceId) async {
    state = deviceId;
    if (deviceId == null) {
      await _storage.removeKey('selectedDeviceRecordId');
    } else {
      await _storage.setKeyValue<String>('selectedDeviceRecordId', deviceId);
    }
  }
}

final selectedDeviceProvider = StateNotifierProvider<SelectedDeviceNotifier, String?>((ref) {
  final storage = ref.watch(keyValueStorageServiceProvider);
  return SelectedDeviceNotifier(storage);
});
