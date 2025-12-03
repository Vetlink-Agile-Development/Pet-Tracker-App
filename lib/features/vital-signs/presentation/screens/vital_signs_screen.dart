import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/vital-signs/presentation/providers/health_summary_provider.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/bpm_chart.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/bpm_tips_list.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/spo2_chart.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/spo2_tips_list.dart';
import 'diseases_tab.dart';
import 'vaccinations_tab.dart';
import 'dewormings_tab.dart';

class HealthSummaryScreen extends ConsumerStatefulWidget {
  const HealthSummaryScreen({super.key});
  @override
  ConsumerState<HealthSummaryScreen> createState() =>
      _HealthSummaryScreenState();
}

class _HealthSummaryScreenState extends ConsumerState<HealthSummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // ahora 5 pestañas
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthSummaryProvider);
    final notifier = ref.read(healthSummaryProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null) return Text(state.errorMessage!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Mensual de Salud',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Frecuencia Cardíaca (BPM)'),
            Tab(text: 'Saturación (SpO2)'),
            Tab(text: 'Enfermedades'),
            Tab(text: 'Vacunaciones'),
            Tab(text: 'Desparasitaciones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: BPM
          // Wrap the charts with a Column that includes month selector
          RefreshIndicator(
            onRefresh: () async {
              await notifier.loadSummaries();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => notifier.showPreviousMonth(),
                        ),
                        Text(
                          '${state.selectedMonth.month.toString().padLeft(2, '0')}/${state.selectedMonth.year}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Row(children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: state.selectedMonth,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                helpText:
                                    'Seleccione mes y año (el día se ignora)',
                              );
                              if (picked != null) {
                                await notifier.pickMonth(picked);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => notifier.showNextMonth(),
                          ),
                        ])
                      ],
                    ),
                  ),
                  if (state.summaries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'No hay datos para ${state.selectedMonth.month.toString().padLeft(2, '0')}/${state.selectedMonth.year}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => notifier.loadSummaries(),
                              child: const Text('Refrescar'),
                            )
                          ],
                        ),
                      ),
                    )
                  else ...[
                    BpmChartWidget(data: state.summaries),
                    const BpmTipsListWidget()
                  ]
                ],
              ),
            ),
          ),

          // Tab 2: SpO2
          RefreshIndicator(
            onRefresh: () async {
              await notifier.loadSummaries();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => notifier.showPreviousMonth(),
                        ),
                        Text(
                          '${state.selectedMonth.month.toString().padLeft(2, '0')}/${state.selectedMonth.year}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Row(children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: state.selectedMonth,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                await notifier.pickMonth(picked);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => notifier.showNextMonth(),
                          ),
                        ])
                      ],
                    ),
                  ),
                  if (state.summaries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'No hay datos para ${state.selectedMonth.month.toString().padLeft(2, '0')}/${state.selectedMonth.year}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => notifier.loadSummaries(),
                              child: const Text('Refrescar'),
                            )
                          ],
                        ),
                      ),
                    )
                  else ...[
                    Spo2ChartWidget(data: state.summaries),
                    const Spo2TipsListWidget()
                  ]
                ],
              ),
            ),
          ),

          // Tab 3: Diseases
          const DiseasesTab(petId: 0),

          // Tab 4: Vaccinations
          const VaccinationsTab(petId: 0),

          // Tab 5: Dewormings
          const DewormingsTab(petId: 0),
        ],
      ),
    );
  }
}
