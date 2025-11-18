import 'package:flutter_riverpod/flutter_riverpod.dart';

final diseaseLocalProvider = StateNotifierProvider<DiseaseLocalNotifier, List<Map<String, dynamic>>>(
  (ref) => DiseaseLocalNotifier(),
);

class DiseaseLocalNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  DiseaseLocalNotifier() : super([]);

  void addDisease(Map<String, dynamic> disease) {
    state = [...state, disease];
  }

  void updateDisease(int index, Map<String, dynamic> disease) {
    final newList = [...state];
    newList[index] = disease;
    state = newList;
  }

  void deleteDisease(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
  }
}
