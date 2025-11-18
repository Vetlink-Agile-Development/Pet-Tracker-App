import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../infrastructure/device_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/disease_local_provider.dart';

class DiseaseFormScreen extends StatefulWidget {
  final int petId;
  final String? diseaseId;
  final Map<String, dynamic>? initialData;
  final int? index; // Nuevo: índice para edición
  const DiseaseFormScreen({Key? key, required this.petId, this.diseaseId, this.initialData, this.index}) : super(key: key);

  @override
  State<DiseaseFormScreen> createState() => _DiseaseFormScreenState();
}

class _DiseaseFormScreenState extends State<DiseaseFormScreen> {
  late KeyValueStorageService _storageService;
  String? _selectedDeviceNickname;
  List<String> _deviceNicknames = [];
  bool _loadingDevices = false;
  File? _diagnosisImage;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _symptomsController;
  late TextEditingController _treatmentController;
  late TextEditingController _observationsController;

  @override
  @override
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    _dateController = TextEditingController(text: widget.initialData?['diagnosisDate'] ?? '');
    _symptomsController = TextEditingController(text: widget.initialData?['symptoms'] ?? '');
    _treatmentController = TextEditingController(text: widget.initialData?['treatment'] ?? '');
    _observationsController = TextEditingController(text: widget.initialData?['observations'] ?? '');
    // Obtener storageService desde el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final container = ProviderScope.containerOf(context);
      _storageService = container.read(keyValueStorageServiceProvider);
      _fetchDeviceNicknames();
    });
  }

  Future<void> _fetchDeviceNicknames() async {
    setState(() => _loadingDevices = true);
    try {
      final userId = await _storageService.getValue<String>('userId');
      if (userId == null) throw Exception('No user found');
      final dio = Dio(); // Usa la instancia global/configurada si existe
      final service = DeviceService(dio);
      // Si tienes un token, obténlo del storageService
      final token = await _storageService.getValue<String>('token');
      final nicknames = await service.getDeviceNicknames(userId, token: token);
      setState(() {
        _deviceNicknames = nicknames;
        _selectedDeviceNickname = _deviceNicknames.isNotEmpty ? _deviceNicknames.first : null;
        _loadingDevices = false;
      });
    } catch (e) {
      setState(() {
        _deviceNicknames = [];
        _selectedDeviceNickname = null;
        _loadingDevices = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading devices: ${e.toString()}')),
      );
    }
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
      final newDisease = {
        'name': _nameController.text,
        'diagnosisDate': _dateController.text,
        'symptoms': _symptomsController.text,
        'treatment': _treatmentController.text,
        'observations': _observationsController.text,
        'diagnosisImagePath': _diagnosisImage?.path, // Opcional
        'deviceNickname': _selectedDeviceNickname, // Nuevo campo
      };
      final container = ProviderScope.containerOf(context);
      if (widget.index != null) {
        // Edición: actualizar en provider
        container.read(diseaseLocalProvider.notifier).updateDisease(widget.index!, newDisease);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disease updated!')),
        );
      } else {
        // Creación: agregar en provider
        container.read(diseaseLocalProvider.notifier).addDisease(newDisease);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disease saved locally!')),
        );
      }
      Navigator.of(context).pop(newDisease);

      /*
      // VERSIÓN API
      // Descomenta para guardar usando el API
      try {
        // import 'package:dio/dio.dart';
        // import '../../infrastructure/disease_service.dart';
        final dio = Dio(); // Usa la instancia global/configurada
        final service = DiseaseService(dio);
        if (widget.diseaseId == null) {
          await service.createDisease(widget.petId.toString(), newDisease);
        } else {
          await service.updateDisease(widget.petId.toString(), widget.diseaseId!, newDisease);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disease saved via API!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      */
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.diseaseId == null ? 'Add Disease' : 'Edit Disease')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _loadingDevices
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedDeviceNickname,
                      decoration: const InputDecoration(labelText: 'Pet Device'),
                      items: _deviceNicknames
                          .map((nickname) => DropdownMenuItem(
                                value: nickname,
                                child: Text(nickname),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDeviceNickname = value;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Disease Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Diagnosis Date'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
                decoration: const InputDecoration(labelText: 'Symptoms'),
              ),
              TextFormField(
                controller: _treatmentController,
                decoration: const InputDecoration(labelText: 'Treatment'),
              ),
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(labelText: 'Observations'),
              ),
              const SizedBox(height: 16),
              Text('Clinical Report (optional):', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
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
                child: Text(widget.diseaseId == null ? 'Save' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
