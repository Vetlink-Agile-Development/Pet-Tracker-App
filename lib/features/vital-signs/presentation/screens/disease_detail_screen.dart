import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../providers/disease_local_provider.dart';
import '../../infrastructure/disease_service.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'disease_form_screen.dart';

class DiseaseDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> disease;
  final int petId;
  final int index;
  const DiseaseDetailScreen(
      {Key? key,
      required this.disease,
      required this.petId,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener la ruta de la imagen (puede ser local o URL del servidor)
    final imagePath = disease['imagePath'] ?? disease['diagnosisImagePath'];
    final bool isLocalImage =
        imagePath != null && !imagePath.toString().startsWith('http');

    return Scaffold(
      appBar: AppBar(title: Text(disease['name'] ?? 'Detalle de Enfermedad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha de Diagnóstico: ${disease['diagnosisDate'] ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Síntomas: ${disease['symptoms'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Tratamiento: ${disease['treatment'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Observaciones: ${disease['observations'] ?? ''}'),
              const SizedBox(height: 16),
              if (imagePath != null) ...[
                Text('Reporte Clínico:',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isLocalImage
                      ? Image.file(
                          File(imagePath),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Image.network(
                          imagePath,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Navegar a edición y actualizar al volver
                      final updated = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DiseaseFormScreen(
                            petId: petId,
                            diseaseId: disease['id']?.toString(),
                            initialData: disease,
                            index: index,
                          ),
                        ),
                      );
                      if (updated != null) {
                        // Obtener deviceId y actualizar el provider específico
                        final storage =
                            ref.read(keyValueStorageServiceProvider);
                        final deviceId = await storage
                            .getValue<String>('selectedDeviceRecordId');
                        if (deviceId != null) {
                          ref
                              .read(diseaseLocalProvider(deviceId).notifier)
                              .updateDisease(index, updated);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Enfermedad actualizada!')),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Editar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar enfermedad'),
                          content: const Text(
                              '¿Está seguro de que desea eliminar esta enfermedad?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        // Try server delete if disease has an id
                        final id = disease['id']?.toString();
                        final storage =
                            ref.read(keyValueStorageServiceProvider);
                        final deviceId = await storage
                            .getValue<String>('selectedDeviceRecordId');

                        if (deviceId != null) {
                          try {
                            final token =
                                await storage.getValue<String>('token');
                            final apiKey = await storage
                                .getValue<String>('selectedApiKey');
                            final dio = Dio(BaseOptions(
                              baseUrl: Environment.apiUrl,
                              headers: token != null
                                  ? {'Authorization': 'Bearer $token'}
                                  : (apiKey != null
                                      ? {'x-api-key': apiKey}
                                      : null),
                            ));
                            final service = DiseaseService(dio);
                            if (id != null) {
                              await service.deleteDisease(deviceId, id);
                            }
                          } catch (_) {
                            // ignore errors, we'll delete local anyway
                          }

                          ref
                              .read(diseaseLocalProvider(deviceId).notifier)
                              .deleteDisease(index);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Enfermedad eliminada!')),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
