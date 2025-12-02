import 'package:flutter/material.dart';
import 'vaccination_list_screen.dart';

class VaccinationsTab extends StatelessWidget {
  final int petId;
  const VaccinationsTab({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VaccinationListScreen(petId: petId);
  }
}