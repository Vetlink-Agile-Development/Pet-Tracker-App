import 'package:pet_tracker/features/vital-signs/domain/entities/health_summary.dart';

class HealthSummaryMapper {
  static HealthSummary fromJson(Map<String, dynamic> json) {
    // Date field can be 'date', 'created_at', or 'day'
    final dateString = json['date'] ?? json['created_at'] ?? json['day'];
    DateTime date;
    if (dateString is DateTime) {
      date = dateString;
    } else if (dateString is String) {
      date = DateTime.tryParse(dateString) ?? DateTime.now();
    } else if (dateString is Map) {
      // Some backends return a date object like {"year":2024,"month":10,"day":5}
      try {
        final y = dateString['year'];
        final m = dateString['month'];
        final d = dateString['day'] ?? 1;
        if (y is int && m is int) {
          date = DateTime(y, m, d is int ? d : int.tryParse(d.toString()) ?? 1);
        } else {
          date = DateTime.now();
        }
      } catch (_) {
        date = DateTime.now();
      }
    } else {
      date = DateTime.now();
    }

    // BPM field variants: 'avgBpm', 'bpm', 'avg_bpm'
    final bpmValue = json['avgBpm'] ?? json['bpm'] ?? json['avg_bpm'];
    final spo2Value = json['avgSpo2'] ?? json['spo2'] ?? json['avg_spo2'];

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      if (v is num) return v.toInt();
      return 0;
    }

    final avgBpm = parseInt(bpmValue);
    final avgSpo2 = parseInt(spo2Value);

    return HealthSummary(date: date, avgBpm: avgBpm, avgSpo2: avgSpo2);
  }
}