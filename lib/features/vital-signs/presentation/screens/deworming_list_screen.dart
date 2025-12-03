import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/deworming_local_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'deworming_form_screen.dart';
import 'deworming_detail_screen.dart';

class DewormingListScreen extends ConsumerWidget {
  final int petId;
  const DewormingListScreen({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(keyValueStorageServiceProvider);
    return FutureBuilder<String?>(
      future: storage.getValue<String>('selectedDeviceRecordId'),
      builder: (context, snapshot) {
        final deviceId = snapshot.data;
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Desparasitaciones')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (deviceId == null || deviceId.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Desparasitaciones')),
            body: const Center(child: Text('No hay dispositivo seleccionado.')),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DewormingFormScreen(petId: petId),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        }

        // Watch the device-scoped provider
        final dewormings = ref.watch(dewormingLocalProvider(deviceId));
        return Scaffold(
          appBar: AppBar(title: const Text('Desparasitaciones')),
          body: dewormings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay registros de desparasitación.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: dewormings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final deworming = dewormings[index];
                    return ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: Text(deworming['productName'] ?? ''),
                      subtitle: Text(
                        'Administrado: ${deworming['dateAdministered'] ?? ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DewormingDetailScreen(
                              deworming: deworming,
                              index: index,
                              petId: petId,
                              deviceKey: deviceId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DewormingFormScreen(petId: petId, deviceKey: deviceId),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
