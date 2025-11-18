class Disease {
  final String id;
  final String name;
  final DateTime diagnosisDate;
  final String? symptoms;
  final String? treatment;
  final String? observations;

  Disease({
    required this.id,
    required this.name,
    required this.diagnosisDate,
    this.symptoms,
    this.treatment,
    this.observations,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'].toString(),
      name: json['name'],
      diagnosisDate: DateTime.parse(json['diagnosisDate']),
      symptoms: json['symptoms'],
      treatment: json['treatment'],
      observations: json['observations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'diagnosisDate': diagnosisDate.toIso8601String(),
      'symptoms': symptoms,
      'treatment': treatment,
      'observations': observations,
    };
  }
}
