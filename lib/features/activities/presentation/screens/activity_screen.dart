import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Activity entity import not required here (list items are handled dynamically)
import 'package:pet_tracker/features/activities/presentation/providers/activity_provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../devices/presentation/providers/device_provider.dart';
import '../../../devices/presentation/providers/selected_device_provider.dart';

import 'package:intl/intl.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userProfile = authState.userProfile;

    // Mostrar loading mientras se obtiene el estado de autenticación o el perfil del usuario
    if (authState.authStatus == AuthStatus.checking || userProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userId = userProfile.id.toString();
    final devicesAsync = ref.watch(deviceProvider(userId));
    final selectedDeviceId = ref.watch(selectedDeviceProvider);

    return devicesAsync.when(
      data: (devices) {
        if (devices.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No se encontraron dispositivos vinculados.')),
          );
        }

        // prefer globally selected device; fallback to first device
        final deviceId = selectedDeviceId ?? devices.first.petTrackerDeviceRecordId;

        return _ActivityPage(initialDeviceId: deviceId);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error cargando dispositivos: $e')),
      ),
    );
  }
}


class _ActivityPage extends ConsumerStatefulWidget {
  final String initialDeviceId;
  const _ActivityPage({required this.initialDeviceId});

  @override
  ConsumerState<_ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<_ActivityPage> {
  late String _deviceId;
  String? _selectedType;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _deviceId = widget.initialDeviceId;
    // initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityProvider(_deviceId).notifier).fetchActivities(_deviceId);
    });
  }

  @override
  void didUpdateWidget(covariant _ActivityPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDeviceId != oldWidget.initialDeviceId) {
      _deviceId = widget.initialDeviceId;
      ref.read(activityProvider(_deviceId).notifier).fetchActivities(_deviceId);
    }
  }

  Future<void> _applyFilters() async {
    final notifier = ref.read(activityProvider(_deviceId).notifier);
    await notifier.fetchActivities(_deviceId, activityType: _selectedType, from: _fromDate, to: _toDate, reset: true);
  }

  Future<void> _loadMore() async {
    final notifier = ref.read(activityProvider(_deviceId).notifier);
    await notifier.fetchNextPage(_deviceId);
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now().subtract(const Duration(days: 30)), firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null) setState(() => _fromDate = picked);
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null) setState(() => _toDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activityProvider(_deviceId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Actividades del Dispositivo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 600;
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: 'BPM', child: Text('BPM')),
                          DropdownMenuItem(value: 'SPO2', child: Text('SPO2')),
                          DropdownMenuItem(value: 'GPS', child: Text('GPS')),
                        ],
                        onChanged: (v) => setState(() => _selectedType = v),
                        decoration: const InputDecoration(labelText: 'Tipo'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(onPressed: _pickFromDate, icon: const Icon(Icons.calendar_today, size: 16), label: Text(_fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : 'Desde')),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(onPressed: _pickToDate, icon: const Icon(Icons.calendar_today, size: 16), label: Text(_toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : 'Hasta')),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: _applyFilters, child: const Text('Aplicar')),
                    const Spacer(),
                  ],
                );
              }

              // narrow layout
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos')),
                      DropdownMenuItem(value: 'BPM', child: Text('BPM')),
                      DropdownMenuItem(value: 'SPO2', child: Text('SPO2')),
                      DropdownMenuItem(value: 'GPS', child: Text('GPS')),
                    ],
                    onChanged: (v) => setState(() => _selectedType = v),
                    decoration: const InputDecoration(labelText: 'Tipo'),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: _pickFromDate, icon: const Icon(Icons.calendar_today, size: 16), label: Text(_fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : 'Desde'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton.icon(onPressed: _pickToDate, icon: const Icon(Icons.calendar_today, size: 16), label: Text(_toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : 'Hasta'))),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _applyFilters, child: const Text('Aplicar')),
                  ])
                ],
              );
            }),
          ),
          const Divider(),
          Expanded(
            child: activitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) return const Center(child: Text('No hay actividades registradas.'));
                final notifier = ref.read(activityProvider(_deviceId).notifier);
                final totalFiltered = notifier.filteredCount;
                final currentPage = notifier.currentPage;
                final pageSize = notifier.pageSize;
                final totalPages = (totalFiltered / pageSize).ceil();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: Row(
                        children: [
                          Text('Mostrando ${activities.length} de $totalFiltered', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(width: 12),
                          Text('Página $currentPage / $totalPages', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                  itemCount: activities.length + 1,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == activities.length) {
                      final notifier = ref.read(activityProvider(_deviceId).notifier);
                      return notifier.hasMore
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(child: ElevatedButton(onPressed: _loadMore, child: const Text('Cargar más'))),
                            )
                          : const SizedBox.shrink();
                    }
                    final a = activities[index];
                    
                    // Traducir nombres de actividad
                    String translatedActivityName = a.activityName;
                    switch (a.activityName) {
                      case 'High Heart Rate':
                        translatedActivityName = 'Frecuencia cardíaca alta';
                        break;
                      case 'Low Heart Rate':
                        translatedActivityName = 'Frecuencia cardíaca baja';
                        break;
                      case 'High Spo2':
                        translatedActivityName = 'Saturación de oxígeno alta';
                        break;
                      case 'Low Spo2':
                        translatedActivityName = 'Saturación de oxígeno baja';
                        break;
                      case 'Geofence Exit':
                        translatedActivityName = 'Salida de la geocerca';
                        break;
                    }
                    
                    return ListTile(
                      title: Text(translatedActivityName),
                      subtitle: Text('${a.activityType} • ${DateFormat('yyyy-MM-dd HH:mm').format(a.dateAndTime)}'),
                    );
                  },
                ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error cargando actividades: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
