import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vaccination_local_provider.dart';
import 'package:pet_tracker/features/devices/presentation/providers/selected_device_provider.dart';

import 'vaccination_form_screen.dart';
import 'vaccination_detail_screen.dart';

class VaccinationListScreen extends ConsumerStatefulWidget {
  final int petId;
  const VaccinationListScreen({Key? key, required this.petId}) : super(key: key);

  @override
  ConsumerState<VaccinationListScreen> createState() => _VaccinationListScreenState();
}

class _VaccinationListScreenState extends ConsumerState<VaccinationListScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedDeviceId = ref.watch(selectedDeviceProvider);
    if (selectedDeviceId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final vaccinations = ref.watch(vaccinationLocalProvider(selectedDeviceId));
    return Scaffold(
        appBar: AppBar(title: const Text('Vacunas')),
      body: vaccinations.isEmpty
          ? const Center(child: Text('No vaccinations found.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vaccinations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final v = vaccinations[index];
                return ListTile(
                  leading: const Icon(Icons.vaccines),
                    title: Text(v['vaccineName'] ?? 'Vacuna'),
                  subtitle: Text('Date: ${v['dateAdministered'] ?? ''}', style: Theme.of(context).textTheme.bodySmall),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => VaccinationDetailScreen(vaccination: v, index: index, petId: widget.petId, deviceKey: selectedDeviceId)),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => VaccinationFormScreen(petId: widget.petId, deviceKey: selectedDeviceId)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}