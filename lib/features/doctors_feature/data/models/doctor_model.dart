class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String department;
  final String room;
  final List<String> availableDays;
  final String officeHours;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.department,
    required this.room,
    required this.availableDays,
    required this.officeHours,
  });

  factory Doctor.fromJson(String id, Map<String, dynamic> json) => Doctor(
    id: id,
    name: json['name'] ?? '',
    specialty: json['specialty'] ?? '',
    department: json['department'] ?? '',
    room: json['room'] ?? '',
    availableDays: List<String>.from(json['availableDays'] ?? []),
    officeHours: json['officeHours'] ?? '',
  );
}
