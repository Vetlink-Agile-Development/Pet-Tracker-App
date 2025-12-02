class Vaccination {
  final String id;
  final String vaccineName;
  final DateTime dateAdministered;
  final String? batch;
  final DateTime? nextDueDate;
  final String? veterinarian;
  final String? observations;
  final String? documentPath;
  final String? deviceId;

  Vaccination({
    required this.id,
    required this.vaccineName,
    required this.dateAdministered,
    this.batch,
    this.nextDueDate,
    this.veterinarian,
    this.observations,
    this.documentPath,
    this.deviceId,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'].toString(),
      vaccineName: json['vaccineName'],
      dateAdministered: DateTime.parse(json['dateAdministered']),
      batch: json['batch'],
      nextDueDate: json['nextDueDate'] != null ? DateTime.parse(json['nextDueDate']) : null,
      veterinarian: json['veterinarian'],
      observations: json['observations'],
      documentPath: json['documentPath'],
      deviceId: json['deviceId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccineName': vaccineName,
      'dateAdministered': dateAdministered.toIso8601String(),
      'batch': batch,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'veterinarian': veterinarian,
      'observations': observations,
      'documentPath': documentPath,
      'deviceId': deviceId,
    };
  }
}