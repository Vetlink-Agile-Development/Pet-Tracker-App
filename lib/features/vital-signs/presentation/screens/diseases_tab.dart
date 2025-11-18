import 'package:flutter/material.dart';
import 'disease_list_screen.dart';

class DiseasesTab extends StatelessWidget {
  final int petId;
  const DiseasesTab({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DiseaseListScreen(petId: petId);
  }
}
