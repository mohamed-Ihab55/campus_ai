class LabModel {
  final String labName;

  LabModel({
    required this.labName,
  });

  factory LabModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LabModel(
      labName: json['labName'] ?? '',
    );
  }
}