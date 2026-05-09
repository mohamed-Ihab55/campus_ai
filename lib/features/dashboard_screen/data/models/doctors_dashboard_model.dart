class DoctorsDashboardModel {
  final String id;
  final String name;
  final String department;
  final String initials;
  final String room;
  final String title;
  final int avatarColor;

  DoctorsDashboardModel({
    required this.id,
    required this.name,
    required this.department,
    required this.initials,
    required this.room,
    required this.title,
    required this.avatarColor,
  });

  factory DoctorsDashboardModel.fromFirestore(String id, Map<String, dynamic> json) {
    return DoctorsDashboardModel(
      id: id,
      name: json['name'],
      department: json['department'],
      initials: json['initials'],
      room: json['room'],
      title: json['title'],
      avatarColor: json['avatarColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
      'initials': initials,
      'room': room,
      'title': title,
      'avatarColor': avatarColor,
    };
  }
}