import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../infrastructure/disease_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path_util;
import '../providers/disease_local_provider.dart';

class DiseaseFormScreen extends StatefulWidget {
  final int petId;
  final String? diseaseId;
  final Map<String, dynamic>? initialData;
  final int? index;
  const DiseaseFormScreen({Key? key, required this.petId, this.diseaseId, this.initialData, this.index}) : super(key: key);

  @override
  State<DiseaseFormScreen> createState() => _DiseaseFormScreenState();
}

class _DiseaseFormScreenState extends State<DiseaseFormScreen> {
  File? _diagnosisImage;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _symptomsController;
  late TextEditingController _treatmentController;
  late TextEditingController _observationsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    _dateController = TextEditingController(text: widget.initialData?['diagnosisDate'] ?? '');
    _symptomsController = TextEditingController(text: widget.initialData?['symptoms'] ?? '');
    _treatmentController = TextEditingController(text: widget.initialData?['treatment'] ?? '');
    _observationsController = TextEditingController(text: widget.initialData?['observations'] ?? '');
    // storage will be read when needed via container.read
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _symptomsController.dispose();
    _treatmentController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _diagnosisImage = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final localId = widget.initialData?['localId'] ?? DateTime.now().millisecondsSinceEpoch.toString();

      final newDisease = {
        'localId': localId,
        'name': _nameController.text,
        'diagnosisDate': _dateController.text,
        'symptoms': _symptomsController.text,
        'treatment': _treatmentController.text,
        'observations': _observationsController.text,
        'diagnosisImagePath': _diagnosisImage?.path,
        'synced': false,
      };

      final container = ProviderScope.containerOf(context);
      final storage = container.read(keyValueStorageServiceProvider);
      final deviceId = await storage.getValue<String>('selectedDeviceRecordId');
      if (!mounted) return;
      if (deviceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay dispositivo seleccionado.')),
        );
        return;
      }

      // Save locally first for immediate UI
      if (widget.index != null) {
        container.read(diseaseLocalProvider(deviceId).notifier).updateDisease(widget.index!, newDisease);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Enfermedad actualizada!')));
      } else {
        container.read(diseaseLocalProvider(deviceId).notifier).addDisease(newDisease);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Enfermedad guardada!')));
      }

      // Try to persist to server (DB)
      try {
        final token = await storage.getValue<String>('token');
        final apiKey = await storage.getValue<String>('selectedApiKey');
        if (!mounted) return;
        final dio = Dio(BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: token != null ? {'Authorization': 'Bearer $token'} : (apiKey != null ? {'x-api-key': apiKey} : null),
        ));
        final service = DiseaseService(dio);

        if (widget.diseaseId == null) {
          // Create new disease
          MultipartFile? imageFile;
          if (_diagnosisImage != null) {
            final file = File(_diagnosisImage!.path);
            final fileName = path_util.basename(file.path);
            imageFile = await MultipartFile.fromFile(file.path, filename: fileName);
          }
          
          final serverDisease = await service.createDisease(
            deviceId,
            name: _nameController.text,
            diagnosisDate: _dateController.text,
            symptoms: _symptomsController.text,
            treatment: _treatmentController.text,
            observations: _observationsController.text.isNotEmpty ? _observationsController.text : null,
            image: imageFile,
          );
          
          // find local item by localId and mark synced
          final list = container.read(diseaseLocalProvider(deviceId));
          final idx = list.indexWhere((e) => e['localId'] == localId);
          if (idx != -1) {
            final updated = {...list[idx], 'id': serverDisease.id, 'synced': true};
            container.read(diseaseLocalProvider(deviceId).notifier).updateDisease(idx, updated);
          }
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enfermedad guardada en el servidor.')));
        } else {
          // Update existing disease
          MultipartFile? imageFile;
          if (_diagnosisImage != null) {
            final file = File(_diagnosisImage!.path);
            final fileName = path_util.basename(file.path);
            imageFile = await MultipartFile.fromFile(file.path, filename: fileName);
          }
          
          final serverDisease = await service.updateDisease(
            deviceId,
            widget.diseaseId!,
            name: _nameController.text,
            diagnosisDate: _dateController.text,
            symptoms: _symptomsController.text,
            treatment: _treatmentController.text,
            observations: _observationsController.text.isNotEmpty ? _observationsController.text : null,
            image: imageFile,
          );
          
          final list = container.read(diseaseLocalProvider(deviceId));
          final idx = widget.index ?? list.indexWhere((e) => e['localId'] == localId);
          if (idx != -1) {
            final updated = {...list[idx], 'id': serverDisease.id, 'synced': true};
            container.read(diseaseLocalProvider(deviceId).notifier).updateDisease(idx, updated);
          }
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enfermedad actualizada en el servidor.')));
        }
        } catch (e) {
          // On error: keep user UX clean; data already saved locally
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo sincronizar con el servidor.')));
        }

      if (mounted) Navigator.of(context).pop(newDisease);

      // Removed old commented-out API snippet; network logic above is used instead.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.diseaseId == null ? 'Agregar Enfermedad' : 'Editar Enfermedad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Device selection is global; do not allow choosing device here.
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre de Enfermedad'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Fecha de Diagnóstico'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _dateController.text = picked.toIso8601String().split('T')[0];
                  }
                },
              ),
              TextFormField(
                controller: _symptomsController,
                decoration: const InputDecoration(labelText: 'Síntomas'),
              ),
              TextFormField(
                controller: _treatmentController,
                decoration: const InputDecoration(labelText: 'Tratamiento'),
              ),
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
              const SizedBox(height: 16),
              Text('Reporte Clínico (opcional):', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text('Galería'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ],
              ),
              if (_diagnosisImage != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_diagnosisImage!, height: 120),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.diseaseId == null ? 'Guardar' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
