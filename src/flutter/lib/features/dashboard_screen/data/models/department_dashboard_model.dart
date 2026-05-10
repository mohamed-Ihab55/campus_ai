class DepartmentDashboardModel {
  final String deptName;
  final List<String> subFields;

  DepartmentDashboardModel({
    required this.deptName,
    required this.subFields,
  });

  Map<String, dynamic> toMap() {
    return {
      'deptName': deptName,
      'subFields': subFields,
    };
  }
}