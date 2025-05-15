class Medication {
  final String id;
  final String name;
  final String dosage;
  final DateTime time;
  final String userId;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'time': time.toIso8601String(),
      'userId': userId,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['\$id'],
      name: json['name'],
      dosage: json['dosage'],
      time: DateTime.parse(json['time']),
      userId: json['userId'],
    );
  }
}
