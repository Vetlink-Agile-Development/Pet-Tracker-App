import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../providers/deworming_local_provider.dart';
import '../../infrastructure/deworming_service.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'deworming_form_screen.dart';

class DewormingDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> deworming;
  final int index;
  final int petId;
  final String deviceKey;
  const DewormingDetailScreen(
      {Key? key,
      required this.deworming,
      required this.index,
      required this.petId,
      required this.deviceKey})
      : super(key: key);

  @override
  ConsumerState<DewormingDetailScreen> createState() =>
      _DewormingDetailScreenState();
}

class _DewormingDetailScreenState extends ConsumerState<DewormingDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final documentPath = widget.deworming['documentPath'];
    final bool isLocalImage =
        documentPath != null && !documentPath.toString().startsWith('http');

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.deworming['productName'] ?? 'Desparasitación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: ${widget.deworming['dateAdministered'] ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Dosis: ${widget.deworming['dose'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Lote: ${widget.deworming['batch'] ?? ''}'),
              const SizedBox(height: 8),
              Text(
                  'Próxima fecha: ${widget.deworming['nextDueDate'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Veterinario: ${widget.deworming['veterinarian'] ?? ''}'),
              const SizedBox(height: 8),
              Text(
                  'Observaciones: ${widget.deworming['observations'] ?? ''}'),
              const SizedBox(height: 16),
              if (documentPath != null) ...[
                Text('Documento:',
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
                          builder: (_) => DewormingFormScreen(
                            petId: widget.petId,
                            dewormingId: widget.deworming['id']?.toString(),
                            initialData: widget.deworming,
                            index: widget.index,
                            deviceKey: widget.deviceKey,
                          ),
                        ),
                      );
                      if (updated != null) {
                        ref
                            .read(dewormingLocalProvider(widget.deviceKey)
                                .notifier)
                            .updateDeworming(
                                widget.index, updated as Map<String, dynamic>);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Desparasitación actualizada!')),
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
                          title: const Text('Eliminar desparasitación'),
                          content: const Text(
                              '¿Está seguro de que desea eliminar este registro?'),
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
                        // Try server delete if deworming has an id
                        final id = widget.deworming['id']?.toString();
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
                          final service = DewormingService(dio);
                          if (id != null) {
                            await service.deleteDeworming(widget.deviceKey, id);
                          }
                        } catch (_) {
                          // ignore errors, we'll delete local anyway
                        }

                        ref
                            .read(dewormingLocalProvider(widget.deviceKey)
                                .notifier)
                            .deleteDeworming(widget.index);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Desparasitación eliminada!')));
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
