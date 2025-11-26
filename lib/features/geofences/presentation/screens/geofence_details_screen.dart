// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_tracker/features/geofences/domain/entities/geofence.dart';
import 'package:pet_tracker/features/geofences/presentation/providers/providers.dart';
import 'package:pet_tracker/features/geofences/presentation/widgets/geofences_map_widget.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:latlong2/latlong.dart';

class GeofenceDetailsScreen extends ConsumerStatefulWidget {
  final Geofence? geofence;
  final bool isEditMode;

  const GeofenceDetailsScreen({
    super.key,
    this.geofence,
    this.isEditMode = false,
  });

  @override
  GeofenceDetailsScreenState createState() => GeofenceDetailsScreenState();
}

class GeofenceDetailsScreenState extends ConsumerState<GeofenceDetailsScreen> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  String _geoFenceStatus = "ACTIVE";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.geofence?.name ?? "");
    _geoFenceStatus = widget.geofence?.geoFenceStatus ?? "ACTIVE";

    final initialPoints = widget.geofence?.coordinates
            .map((coord) => LatLng(coord.latitude, coord.longitude))
            .toList() ??
        [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapProvider).initializePoints(initialPoints);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    final mapNotifier = ref.read(mapProvider);
    final coordinates = mapNotifier.geofencePoints
        .map((point) =>
            Coordinate(latitude: point.latitude, longitude: point.longitude))
        .toList();

    final storageService = ref.read(keyValueStorageServiceProvider);
    final deviceRecordId =
        await storageService.getValue<String>('selectedDeviceRecordId');
    if (deviceRecordId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ID de dispositivo no encontrado. Por favor selecciona un dispositivo."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final geofence = widget.isEditMode
        ? widget.geofence!.copyWith(
            name: _nameController.text,
            coordinates: coordinates,
            geoFenceStatus: _geoFenceStatus,
          )
        : Geofence(
            id: 0,
            name: _nameController.text,
            geoFenceStatus: _geoFenceStatus,
            coordinates: coordinates,
            petTrackerDeviceRecordId: deviceRecordId,
          );

    try {
      if (widget.isEditMode) {
        await ref.read(geofenceProvider.notifier).updateGeofence(geofence);
      } else {
        await ref.read(geofenceProvider.notifier).addGeofence(geofence);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isEditMode
                  ? 'Geocerca actualizada exitosamente'
                  : 'Geocerca creada exitosamente')),
        );
        context.go('/geofences');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al ${widget.isEditMode ? "actualizar" : "crear"} geocerca: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeCoordinate(int index) {
    ref.read(mapProvider).removeGeofencePoint(index);
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Eliminar Geocerca',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Estás seguro de que quieres eliminar esta geocerca?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF08273A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.geofence?.name ?? 'Unnamed Geofence',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estado: ${widget.geofence?.geoFenceStatus ?? "ACTIVE"}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteGeofence();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGeofence() async {
    if (widget.geofence == null) return;

    try {
      await ref.read(geofenceProvider.notifier).deleteGeofence(widget.geofence!.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geocerca eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/geofences');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar geocerca: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapNotifier = ref.watch(mapProvider);

    ref.listen<GeofenceState>(geofenceProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.go('/geofences');
          },
        ),
        title: Text(
          widget.isEditMode ? 'Editar Geocerca' : 'Crear Geocerca',
          style: const TextStyle(fontSize: 18),
        ),
        actions: widget.isEditMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmationDialog(context),
                ),
              ]
            : null,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GeofenceMapWidget(
                geofence: widget.geofence,
                isEditable: _isEditing || !widget.isEditMode,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                enabled: _isEditing || !widget.isEditMode,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _geoFenceStatus,
                items: const [
                  DropdownMenuItem(
                    value: 'ACTIVE',
                    child: Text('Activo',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                  ),
                  DropdownMenuItem(
                    value: 'INACTIVE',
                    child: Text('Inactivo',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                  ),
                ],
                onChanged: _isEditing || !widget.isEditMode
                    ? (value) {
                        setState(() {
                          _geoFenceStatus = value!;
                        });
                      }
                    : null,
                decoration: const InputDecoration(labelText: 'Estado de Geocerca'),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isEditing || !widget.isEditMode)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nameController.text = widget.geofence?.name ?? '';
                            _geoFenceStatus =
                                widget.geofence?.geoFenceStatus ?? "ACTIVE";
                            ref.read(mapProvider).initializePoints(widget
                                    .geofence?.coordinates
                                    .map((coord) =>
                                        LatLng(coord.latitude, coord.longitude))
                                    .toList() ??
                                []);
                          });
                        },
                        child: const Text('Cancelar'),
                      ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isEditing || !widget.isEditMode
                          ? _saveChanges
                          : _toggleEditing,
                      child: Text(_isEditing || !widget.isEditMode
                          ? 'Guardar cambios'
                          : 'Editar geocerca'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_isEditing || !widget.isEditMode)
                _buildCoordinatesTable(mapNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinatesTable(MapNotifier mapNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coordenadas:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mapNotifier.geofencePoints.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Coord ${index + 1}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _removeCoordinate(index),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
