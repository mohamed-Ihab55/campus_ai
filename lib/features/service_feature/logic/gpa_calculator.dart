import 'package:campus_ai/features/service_feature/data/model/gpa_course_model.dart';

const Map<String, double> gradePoints = {
  'A': 4.00,
  'A-': 3.67,
  'B+': 3.33,
  'B': 3.00,
  'C+': 2.67,
  'C': 2.33,
  'D': 2.00,
  'F': 0.00,
  'Abs': 0.00,
  'I': 0.00,
  'W': 0.00,
  'Ba': 0.00,
};

const List<String> selectableGrades = [
  'A',
  'A-',
  'B+',
  'B',
  'C+',
  'C',
  'D',
  'F',
  'Abs',
  'I',
  'W',
  'Ba',
];

double calcSemesterGPA(List<GpaCourse> courses) {
  double totalQualityPoints = 0;
  double totalHours = 0;

  for (final c in courses) {
    final points = gradePoints[c.grade] ?? 0.0;
    totalQualityPoints += points * c.hours;
    totalHours += c.hours;
  }

  if (totalHours == 0) return 0.0;
  return double.parse((totalQualityPoints / totalHours).toStringAsFixed(2));
}

double calcCumulativeGPA(List<SemesterEntry> semesters) {
  double totalQualityPoints = 0;
  double totalHours = 0;

  for (final s in semesters) {
    if (s.hours > 0) {
      totalQualityPoints += s.gpa * s.hours;
      totalHours += s.hours;
    }
  }

  if (totalHours == 0) return 0.0;
  return double.parse((totalQualityPoints / totalHours).toStringAsFixed(2));
}

class SemesterEntry {
  double gpa;
  double hours;

  SemesterEntry({this.gpa = 0.0, this.hours = 15});
}

class AcademicStatus {
  final String labelEn;
  final String emoji;
  final bool canGraduate;

  const AcademicStatus({
    required this.labelEn,
    required this.emoji,
    required this.canGraduate,
  });
}

AcademicStatus getAcademicStatus(double gpa) {
  if (gpa >= 3.60) {
    return const AcademicStatus(
      labelEn: 'Honor Roll',
      emoji: '🏆',
      canGraduate: true,
    );
  } else if (gpa >= 3.00) {
    return const AcademicStatus(
      labelEn: 'Excellent',
      emoji: '⭐',
      canGraduate: true,
    );
  } else if (gpa >= 2.00) {
    return const AcademicStatus(
      labelEn: 'Passing',
      emoji: '✅',
      canGraduate: true,
    );
  } else {
    return const AcademicStatus(
      labelEn: 'Below Minimum',
      emoji: '⚠️',
      canGraduate: false,
    );
  }
}
