import 'package:flutter/material.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/tip_card.dart';

class BpmTipsListWidget extends StatelessWidget {
  const BpmTipsListWidget({super.key});

  final List<TipItem> tips = const [
    TipItem(
      range: '< 60 BPM',
      icon: Icons.warning_amber,
      color: Colors.orange,
      text:
          'Frecuencia cardíaca baja. Puede indicar fatiga, bradicardia o problemas médicos. Se recomienda consultar al veterinario.',
    ),
    TipItem(
      range: '60 - 100 BPM',
      icon: Icons.favorite,
      color: Colors.green,
      text:
          'Frecuencia cardíaca en reposo normal. Tu mascota parece estar saludable y relajada.',
    ),
    TipItem(
      range: '101 - 140 BPM',
      icon: Icons.monitor_heart,
      color: Colors.yellow,
      text:
          'Ligeramente elevada. Podría ser causada por emoción, actividad física o estrés.',
    ),
    TipItem(
      range: '> 140 BPM',
      icon: Icons.heart_broken,
      color: Colors.red,
      text:
          'Frecuencia cardíaca alta. Puede indicar fiebre, dolor o condiciones cardíacas graves. Busca atención inmediata.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tips.map((tip) => TipCardWithAccentBorder(tip)).toList(),
    );
  }
}
