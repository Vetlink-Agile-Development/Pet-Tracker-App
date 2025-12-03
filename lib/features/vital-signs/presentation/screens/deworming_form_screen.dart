import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path_util;
import '../../infrastructure/deworming_service.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/deworming_local_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class DewormingFormScreen extends ConsumerStatefulWidget {
  final int petId;
  final String? dewormingId;
  final Map<String, dynamic>? initialData;
  final int? index;
  final String? deviceKey;
  const DewormingFormScreen(
      {Key? key,
      required this.petId,
      this.dewormingId,
      this.initialData,
      this.index,
      this.deviceKey})
      : super(key: key);
  @override
  ConsumerState<DewormingFormScreen> createState() =>
      _DewormingFormScreenState();
}

class _DewormingFormScreenState extends ConsumerState<DewormingFormScreen> {
  late KeyValueStorageService _storageService;
  File? _documentImage;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productController;
  late TextEditingController _dateController;
  late TextEditingController _doseController;
  late TextEditingController _batchController;
  late TextEditingController _nextDueController;
  late TextEditingController _vetController;
  late TextEditingController _observationsController;

  @override
  void initState() {
    super.initState();
    _productController =
        TextEditingController(text: widget.initialData?['productName'] ?? '');
    _dateController = TextEditingController(
        text: widget.initialData?['dateAdministered'] ?? '');
    _doseController =
        TextEditingController(text: widget.initialData?['dose'] ?? '');
    _batchController =
        TextEditingController(text: widget.initialData?['batch'] ?? '');
    _nextDueController =
        TextEditingController(text: widget.initialData?['nextDueDate'] ?? '');
    _vetController =
        TextEditingController(text: widget.initialData?['veterinarian'] ?? '');
    _observationsController =
        TextEditingController(text: widget.initialData?['observations'] ?? '');

    _storageService = ref.read(keyValueStorageServiceProvider);
  }

  @override
  void dispose() {
    _productController.dispose();
    _dateController.dispose();
    _doseController.dispose();
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
      final localId = widget.initialData?['localId'] ??
          DateTime.now().millisecondsSinceEpoch.toString();

      final newDeworming = {
        'localId': localId,
        'productName': _productController.text,
        'dateAdministered': _dateController.text,
        'dose': _doseController.text,
        'batch': _batchController.text,
        'nextDueDate': _nextDueController.text,
        'veterinarian': _vetController.text,
        'observations': _observationsController.text,
        'documentPath': _documentImage?.path,
        'synced': false,
      };

      final deviceKey = widget.deviceKey ??
          await _storageService.getValue<String>('selectedDeviceRecordId') ??
          'default';

      final notifier = ref.read(dewormingLocalProvider(deviceKey).notifier);

      if (widget.index != null) {
        notifier.updateDeworming(widget.index!, newDeworming);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Desparasitación actualizada.')));
      } else {
        notifier.addDeworming(newDeworming);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Desparasitación guardada.')));
      }

      // Attempt to sync with API
      try {
        final token = await _storageService.getValue<String>('token');
        final apiKey = await _storageService.getValue<String>('selectedApiKey');
        final dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: token != null
                ? {'Authorization': 'Bearer $token'}
                : (apiKey != null ? {'x-api-key': apiKey} : null)));
        final service = DewormingService(dio);

        // Debug: verificar qué operación se está realizando
        print('🐾 dewormingId: ${widget.dewormingId}');
        print('🐾 Operación: ${widget.dewormingId == null ? "CREATE" : "UPDATE"}');

        if (widget.dewormingId == null) {
          // Create new deworming
          MultipartFile? imageFile;
          if (_documentImage != null) {
            final file = File(_documentImage!.path);
            final fileName = path_util.basename(file.path);
            imageFile =
                await MultipartFile.fromFile(file.path, filename: fileName);
          }

          final serverDeworming = await service.createDeworming(
            deviceKey,
            productName: _productController.text,
            dateAdministered: _dateController.text,
            dose: _doseController.text.isNotEmpty ? _doseController.text : null,
            batch:
                _batchController.text.isNotEmpty ? _batchController.text : null,
            veterinarian:
                _vetController.text.isNotEmpty ? _vetController.text : null,
            nextDueDate: _nextDueController.text.isNotEmpty
                ? _nextDueController.text
                : null,
            observations: _observationsController.text.isNotEmpty
                ? _observationsController.text
                : null,
            image: imageFile,
          );

          final list = ref.read(dewormingLocalProvider(deviceKey));
          final idx = list.indexWhere((e) => e['localId'] == localId);
          if (idx != -1) {
            final updated = {
              ...list[idx],
              'id': serverDeworming.id,
              'synced': true
            };
            notifier.updateDeworming(idx, updated);
          }
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Desparasitaciones sincronizadas')));
        } else {
          // Update existing deworming
          MultipartFile? imageFile;
          if (_documentImage != null) {
            final file = File(_documentImage!.path);
            final fileName = path_util.basename(file.path);
            imageFile =
                await MultipartFile.fromFile(file.path, filename: fileName);
          }

          final serverDeworming = await service.updateDeworming(
            deviceKey,
            widget.dewormingId!,
            productName: _productController.text,
            dateAdministered: _dateController.text,
            dose: _doseController.text.isNotEmpty ? _doseController.text : null,
            batch:
                _batchController.text.isNotEmpty ? _batchController.text : null,
            veterinarian:
                _vetController.text.isNotEmpty ? _vetController.text : null,
            nextDueDate: _nextDueController.text.isNotEmpty
                ? _nextDueController.text
                : null,
            observations: _observationsController.text.isNotEmpty
                ? _observationsController.text
                : null,
            image: imageFile,
          );

          final list = ref.read(dewormingLocalProvider(deviceKey));
          final idx =
              widget.index ?? list.indexWhere((e) => e['localId'] == localId);
          if (idx != -1) {
            final updated = {
              ...list[idx],
              'id': serverDeworming.id,
              'synced': true
            };
            notifier.updateDeworming(idx, updated);
          }
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Desparasitación actualizada en el servidor.')));
        }
      } catch (e) {
        // Silent fallback: already saved locally
      }
      Navigator.of(context).pop(newDeworming);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.dewormingId == null
              ? 'Agregar Desparasitación'
              : 'Editar Desparasitación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _productController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration:
                    const InputDecoration(labelText: 'Fecha de Administración'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _dateController.text =
                        picked.toIso8601String().split('T')[0];
                  }
                },
              ),
              TextFormField(
                controller: _doseController,
                decoration:
                    const InputDecoration(labelText: 'Dosis (opcional)'),
              ),
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(labelText: 'Lote (opcional)'),
              ),
              TextFormField(
                controller: _nextDueController,
                decoration: const InputDecoration(
                    labelText: 'Próxima Fecha (opcional)'),
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime initial = DateTime.now();
                  if (_nextDueController.text.isNotEmpty) {
                    final parsed = DateTime.tryParse(_nextDueController.text);
                    if (parsed != null) initial = parsed;
                  }
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _nextDueController.text =
                        picked.toIso8601String().split('T')[0];
                  }
                },
              ),
              TextFormField(
                controller: _vetController,
                decoration:
                    const InputDecoration(labelText: 'Veterinario (opcional)'),
              ),
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(
                    labelText: 'Observaciones (opcional)'),
              ),
              const SizedBox(height: 16),
              Text('Documento (opcional):',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text('Galería'),
                      onPressed: () => _pickImage(ImageSource.gallery)),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cámara'),
                      onPressed: () => _pickImage(ImageSource.camera)),
                ],
              ),
              if (_documentImage != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_documentImage!, height: 120)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child:
                    Text(widget.dewormingId == null ? 'Guardar' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
