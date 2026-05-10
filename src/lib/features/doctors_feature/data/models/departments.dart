enum Department { all, math, physics, chemistry, biology, geology, cs }

extension DeptExt on Department {
  String get label {
    const map = {
      Department.all: 'All',
      Department.math: 'Mathematics',
      Department.physics: 'Physics',
      Department.chemistry: 'Chemistry',
      Department.biology: 'Biology',
      Department.geology: 'Geology',
      Department.cs: 'Computer Science',
    };
    return map[this]!;
  }
}