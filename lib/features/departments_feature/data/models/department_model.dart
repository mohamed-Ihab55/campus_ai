class DepartmentModel {
  final String deptName;
  final List<String> subFields;

  DepartmentModel({
    required this.deptName,
    required this.subFields,
  });

  factory DepartmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DepartmentModel(
      deptName: json['deptName'] ?? '',
      subFields: List<String>.from(
        json['subFields'] ?? [],
      ),
    );
  }
}