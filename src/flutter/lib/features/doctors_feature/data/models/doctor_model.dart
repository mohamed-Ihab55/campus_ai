class Doctor {
  final String id;
  final String name;
  final String department;
  final String room;
  final String initials;
  final String title;
  final int avatarColor;

  const Doctor({
    required this.id,
    required this.name,
    required this.department,
    required this.room,
    required this.initials,
    required this.title,
    required this.avatarColor,
  });

  factory Doctor.fromJson(String id, Map<String, dynamic> json) => Doctor(
        id: id,
        name: json['name'] ?? '',
        department: json['department'] ?? '',
        room: json['room'] ?? '',
        initials: json['initials'] ?? '',
        title: json['title'] ?? '',
        avatarColor: json['avatarColor'] is int
            ? json['avatarColor']
            : int.tryParse(json['avatarColor']?.toString() ?? '') ??
                0xFF000000,
      );
}

