import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../providers/vaccination_local_provider.dart';
import 'vaccination_form_screen.dart';
import '../../infrastructure/vaccination_service.dart';
import 'package:dio/dio.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';

class VaccinationDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> vaccination;
  final int index;
  final int petId;
  final String deviceKey;
  const VaccinationDetailScreen(
      {Key? key,
      required this.vaccination,
      required this.index,
      required this.petId,
      required this.deviceKey})
      : super(key: key);

  @override
  ConsumerState<VaccinationDetailScreen> createState() =>
      _VaccinationDetailScreenState();
}

class _VaccinationDetailScreenState
    extends ConsumerState<VaccinationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Obtener la ruta de la imagen (puede ser local o URL del servidor)
    final documentPath = widget.vaccination['documentPath'];
    final bool isLocalImage =
        documentPath != null && !documentPath.toString().startsWith('http');

    return Scaffold(
      appBar:
          AppBar(title: Text(widget.vaccination['vaccineName'] ?? 'Vacuna')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: ${widget.vaccination['dateAdministered'] ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Lote: ${widget.vaccination['batch'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Próxima fecha: ${widget.vaccination['nextDueDate'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Veterinario: ${widget.vaccination['veterinarian'] ?? ''}'),
              const SizedBox(height: 8),
              Text(
                  'Observaciones: ${widget.vaccination['observations'] ?? ''}'),
              const SizedBox(height: 16),
              if (documentPath != null) ...[
                Text('Documento de Vacunación:',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isLocalImage
                      ? Image.file(
                          File(documentPath),
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
                          documentPath,
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
                      final updated = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VaccinationFormScreen(
                            petId: widget.petId,
                            initialData: widget.vaccination,
                            index: widget.index,
                            deviceKey: widget.deviceKey,
                          ),
                        ),
                      );
                      if (updated != null) {
                        ref
                            .read(vaccinationLocalProvider(widget.deviceKey)
                                .notifier)
                            .updateVaccination(
                                widget.index, updated as Map<String, dynamic>);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vacuna actualizada!')),
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
                          title: const Text('Eliminar vacuna'),
                          content: const Text(
                              '¿Está seguro de que desea eliminar esta vacuna?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancelar')),
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Eliminar')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        // Try server delete if vaccination has an id
                        final id = widget.vaccination['id']?.toString();
                        try {
                          final token = await ref
                              .read(keyValueStorageServiceProvider)
                              .getValue<String>('token');
                          final apiKey = await ref
                              .read(keyValueStorageServiceProvider)
                              .getValue<String>('selectedApiKey');
                          final dio = Dio(BaseOptions(
                              baseUrl: Environment.apiUrl,
                              headers: token != null
                                  ? {'Authorization': 'Bearer $token'}
                                  : (apiKey != null
                                      ? {'x-api-key': apiKey}
                                      : null)));
                          final service = VaccinationService(dio);
                          if (id != null) {
                            await service.deleteVaccination(
                                widget.deviceKey, id);
                          }
                        } catch (_) {
                          // ignore errors, we'll delete local anyway
                        }

                        ref
                            .read(vaccinationLocalProvider(widget.deviceKey)
                                .notifier)
                            .deleteVaccination(widget.index);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vacuna eliminada!')));
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
