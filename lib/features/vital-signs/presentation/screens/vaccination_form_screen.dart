import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
// device selection is global; do not fetch devices here
import '../../infrastructure/vaccination_service.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/vaccination_local_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class VaccinationFormScreen extends ConsumerStatefulWidget {
  final int petId;
  final String? vaccinationId;
  final Map<String, dynamic>? initialData;
  final int? index;
  final String? deviceKey;
  const VaccinationFormScreen({Key? key, required this.petId, this.vaccinationId, this.initialData, this.index, this.deviceKey}) : super(key: key);
  @override
  ConsumerState<VaccinationFormScreen> createState() => _VaccinationFormScreenState();
}

class _VaccinationFormScreenState extends ConsumerState<VaccinationFormScreen> {
  late KeyValueStorageService _storageService;
  File? _documentImage;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vaccineController;
  late TextEditingController _dateController;
  late TextEditingController _batchController;
  late TextEditingController _nextDueController;
  late TextEditingController _vetController;
  late TextEditingController _observationsController;

  @override
  void initState() {
    super.initState();
    _vaccineController = TextEditingController(text: widget.initialData?['vaccineName'] ?? '');
    _dateController = TextEditingController(text: widget.initialData?['dateAdministered'] ?? '');
    _batchController = TextEditingController(text: widget.initialData?['batch'] ?? '');
    _nextDueController = TextEditingController(text: widget.initialData?['nextDueDate'] ?? '');
    _vetController = TextEditingController(text: widget.initialData?['veterinarian'] ?? '');
    _observationsController = TextEditingController(text: widget.initialData?['observations'] ?? '');

    // read storage service via Riverpod ref
    _storageService = ref.read(keyValueStorageServiceProvider);
  }

  @override
  void dispose() {
    _vaccineController.dispose();
    _dateController.dispose();
    _batchController.dispose();
    _nextDueController.dispose();
    _vetController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _documentImage = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final localId = widget.initialData?['localId'] ?? DateTime.now().millisecondsSinceEpoch.toString();

      final newVaccination = {
        'localId': localId,
        'vaccineName': _vaccineController.text,
        'dateAdministered': _dateController.text,
        'batch': _batchController.text,
        'nextDueDate': _nextDueController.text,
        'veterinarian': _vetController.text,
        'observations': _observationsController.text,
        'documentPath': _documentImage?.path,
        // device is taken from global selection when syncing
        'synced': false,
      };

      final deviceKey = widget.deviceKey ?? await _storageService.getValue<String>('selectedDeviceRecordId') ?? 'default';

      final notifier = ref.read(vaccinationLocalProvider(deviceKey).notifier);

      if (widget.index != null) {
        notifier.updateVaccination(widget.index!, newVaccination);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacuna actualizada.')));
      } else {
        notifier.addVaccination(newVaccination);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacuna guardada.')));
      }

      // Attempt to sync with API in background and update local item with server id when available
      try {
        final token = await _storageService.getValue<String>('token');
        final apiKey = await _storageService.getValue<String>('selectedApiKey');
        final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl, headers: token != null ? {'Authorization': 'Bearer $token'} : (apiKey != null ? {'x-api-key': apiKey} : null)));
        final service = VaccinationService(dio);

          if (widget.vaccinationId == null) {
          final serverVaccination = await service.createVaccination(deviceKey, newVaccination);
          // find local item by localId and patch with server id + synced true
          final list = ref.read(vaccinationLocalProvider(deviceKey));
          final idx = list.indexWhere((e) => e['localId'] == localId);
            if (idx != -1) {
              final updated = {...list[idx], 'id': serverVaccination.id, 'synced': true};
              notifier.updateVaccination(idx, updated);
            }
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacuna sincronizada con el servidor.')));
        } else {
          final serverVaccination = await service.updateVaccination(deviceKey, widget.vaccinationId!, newVaccination);
          // update local item if we can find it
          final list = ref.read(vaccinationLocalProvider(deviceKey));
          final idx = widget.index ?? list.indexWhere((e) => e['localId'] == localId);
            if (idx != -1) {
              final updated = {...list[idx], 'id': serverVaccination.id, 'synced': true};
              notifier.updateVaccination(idx, updated);
            }
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacuna actualizada en el servidor.')));
        }
      } catch (e) {
        // Silent fallback: already saved locally
      }
      Navigator.of(context).pop(newVaccination);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vaccinationId == null ? 'Agregar vacuna' : 'Editar vacuna')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
                // Device is selected globally; do not allow choosing device here.
              const SizedBox(height: 16),
              TextFormField(
                controller: _vaccineController,
                decoration: const InputDecoration(labelText: 'Nombre de la vacuna'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Fecha aplicada'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) _dateController.text = picked.toIso8601String().split('T')[0];
                },
              ),
              TextFormField(controller: _batchController, decoration: const InputDecoration(labelText: 'Lote')),
              TextFormField(
                controller: _nextDueController,
                decoration: const InputDecoration(labelText: 'Próxima fecha'),
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime initial = DateTime.now();
                  if (_nextDueController.text.isNotEmpty) {
                    final parsed = DateTime.tryParse(_nextDueController.text);
                    if (parsed != null) initial = parsed;
                  }
                  final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) _nextDueController.text = picked.toIso8601String().split('T')[0];
                },
              ),
              TextFormField(controller: _vetController, decoration: const InputDecoration(labelText: 'Veterinario')),
              TextFormField(controller: _observationsController, decoration: const InputDecoration(labelText: 'Observaciones')),
              const SizedBox(height: 16),
              Text('Documento (opcional):', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(icon: const Icon(Icons.photo), label: const Text('Galería'), onPressed: () => _pickImage(ImageSource.gallery)),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Cámara'), onPressed: () => _pickImage(ImageSource.camera)),
                ],
              ),
              if (_documentImage != null) ...[
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_documentImage!, height: 120)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: Text(widget.vaccinationId == null ? 'Guardar' : 'Actualizar')),
            ],
          ),
        ),
      ),
    );
  }
}