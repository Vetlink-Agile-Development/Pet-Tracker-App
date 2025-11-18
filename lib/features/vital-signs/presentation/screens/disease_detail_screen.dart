import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/disease_local_provider.dart';
import 'disease_form_screen.dart';

class DiseaseDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> disease;
  final int petId;
  final int index;
  const DiseaseDetailScreen({Key? key, required this.disease, required this.petId, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(disease['name'] ?? 'Disease Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diagnosis Date: ${disease['diagnosisDate'] ?? ''}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Symptoms: ${disease['symptoms'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Treatment: ${disease['treatment'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Observations: ${disease['observations'] ?? ''}'),
            const Spacer(),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Navegar a edición y actualizar al volver
                    final updated = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DiseaseFormScreen(
                          petId: petId,
                          diseaseId: null,
                          initialData: disease,
                          index: index,
                        ),
                      ),
                    );
                    if (updated != null) {
                      ref.read(diseaseLocalProvider.notifier).updateDisease(index, updated);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Disease updated!')),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Disease'),
                        content: const Text('Are you sure you want to delete this disease?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      ref.read(diseaseLocalProvider.notifier).deleteDisease(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Disease deleted!')),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
