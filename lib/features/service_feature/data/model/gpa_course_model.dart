class GpaCourse {
  String name;
  double hours;
  String grade;

  GpaCourse({
    this.name = '',
    this.hours = 3,
    this.grade = 'A',
  });

  GpaCourse copyWith({String? name, double? hours, String? grade}) {
    return GpaCourse(
      name: name ?? this.name,
      hours: hours ?? this.hours,
      grade: grade ?? this.grade,
    );
  }
}
