import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/vital-signs/presentation/providers/health_summary_provider.dart';
import 'package:pet_tracker/features/vital-signs/presentation/screens/prediction_loading_screen.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/bpm_chart.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/bpm_tips_list.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/prediction_button.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/spo2_chart.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/spo2_tips_list.dart';
import 'diseases_tab.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
          tabs: const [
            Tab(text: 'Frecuencia Cardíaca (BPM)'),
            Tab(text: 'Saturación (SpO2)'),
            Tab(text: 'Enfermedades'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: BPM
          RefreshIndicator(
            onRefresh: () async {
              await notifier.loadSummaries();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  BpmChartWidget(data: state.summaries),
                  const BpmTipsListWidget()
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
                  Spo2ChartWidget(data: state.summaries),
                  const Spo2TipsListWidget()
                ],
              ),
            ),
          ),

          // Tab 3: Diseases
          DiseasesTab(petId: 0), // TODO: Reemplazar con el petId real
        ],
      ),
    );
  }
}
