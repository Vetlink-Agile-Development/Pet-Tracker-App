class Deworming {
  final String id;
  final String productName;
  final DateTime dateAdministered;
  final String? dose;
  final String? batch;
  final DateTime? nextDueDate;
  final String? veterinarian;
  final String? observations;
  final String? documentPath;
  final String? deviceId;

  Deworming({
    required this.id,
    required this.productName,
    required this.dateAdministered,
    this.dose,
    this.batch,
    this.nextDueDate,
    this.veterinarian,
    this.observations,
    this.documentPath,
    this.deviceId,
  });

  factory Deworming.fromJson(Map<String, dynamic> json) {
    return Deworming(
      id: json['id'].toString(),
      productName: json['productName'],
      dateAdministered: DateTime.parse(json['dateAdministered']),
      dose: json['dose'],
      batch: json['batch'],
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'])
          : null,
      veterinarian: json['veterinarian'],
      observations: json['observations'],
      documentPath: json['documentPath'],
      deviceId: json['deviceId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'dateAdministered': dateAdministered.toIso8601String(),
      'dose': dose,
      'batch': batch,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'veterinarian': veterinarian,
      'observations': observations,
      'documentPath': documentPath,
      'deviceId': deviceId,
    };
  }
}
