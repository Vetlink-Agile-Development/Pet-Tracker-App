import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/disease_local_provider.dart';
import 'disease_form_screen.dart';
import 'disease_detail_screen.dart';

class DiseaseListScreen extends ConsumerWidget {
  final int petId;
  const DiseaseListScreen({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // VERSIÓN LOCAL: usar provider local
    final diseases = ref.watch(diseaseLocalProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Diseases')),
      body: diseases.isEmpty
          ? const Center(child: Text('No diseases found.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: diseases.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final disease = diseases[index];
                return ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: Text(disease['name'] ?? ''),
                  subtitle: Text(
                    'Diagnosed: ${disease['diagnosisDate'] ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DiseaseDetailScreen(
                          disease: disease,
                          petId: petId,
                          index: index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegar a formulario y refrescar lista al volver
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DiseaseFormScreen(petId: petId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
