import 'package:flutter/material.dart';
import 'deworming_list_screen.dart';

class DewormingsTab extends StatelessWidget {
  final int petId;
  const DewormingsTab({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DewormingListScreen(petId: petId);
  }
}
