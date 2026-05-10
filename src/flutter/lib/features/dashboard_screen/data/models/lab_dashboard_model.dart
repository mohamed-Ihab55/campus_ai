class LabDashboardModel {
  final String id;
  final String labName;

  LabDashboardModel({
    required this.id,
    required this.labName,
  });

  factory LabDashboardModel.fromJson(Map<String, dynamic> json, String id) {
    return LabDashboardModel(
      id: id,
      labName: json['labName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labName': labName,
    };
  }
}