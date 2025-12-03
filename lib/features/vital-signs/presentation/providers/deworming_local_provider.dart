import 'package:flutter_riverpod/flutter_riverpod.dart';

class DewormingLocalNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  DewormingLocalNotifier() : super([]);

  void setDewormings(List<Map<String, dynamic>> dewormings) {
    state = dewormings;
  }

  void addDeworming(Map<String, dynamic> deworming) {
    state = [...state, deworming];
  }

  void updateDeworming(int index, Map<String, dynamic> deworming) {
    final newList = [...state];
    newList[index] = deworming;
    state = newList;
  }

  void deleteDeworming(int index) {
    final newList = [...state];
    newList.removeAt(index);
    state = newList;
  }

  void clear() {
    state = [];
  }
}

final dewormingLocalProvider = StateNotifierProvider.family<
    DewormingLocalNotifier, List<Map<String, dynamic>>, String>(
  (ref, deviceKey) => DewormingLocalNotifier(),
);
