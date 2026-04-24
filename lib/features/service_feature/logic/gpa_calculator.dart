import 'package:campus_ai/features/service_feature/data/model/gpa_course_model.dart';

// ── جدول النقاط من وثيقة كلية العلوم ──────────────────────────────────────
const Map<String, double> gradePoints = {
  'A': 4.00, // ممتاز       — ≥ 90%
  'A-': 3.67, // ممتاز ناقص — 85–90%
  'B+': 3.33, // جيد جداً+  — 80–85%
  'B': 3.00, // جيد جداً   — 75–80%
  'C+': 2.67, // جيد+       — 70–75%
  'C': 2.33, // جيد        — 65–70%
  'D': 2.00, // مقبول      — 60–65%  (الحد الأدنى للنجاح)
  'F': 0.00, // راسب       — < 60%
  'Abs': 0.00, // غائب
  'I': 0.00, // غير مكتمل
  'W': 0.00, // منسحب
  'Ba': 0.00, // محروم
};

// ── التقديرات الظاهرة في القائمة المنسدلة ─────────────────────────────────
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

// ── حساب GPA الفصل ─────────────────────────────────────────────────────────
// المعادلة: Σ(نقاط × ساعات) ÷ Σساعات
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

// ── حساب GPA التراكمي ──────────────────────────────────────────────────────
// المعادلة: Σ(GPA الفصل × ساعاته) ÷ Σ كل الساعات
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

// ── موديل فصل دراسي (للـ Cumulative) ──────────────────────────────────────
class SemesterEntry {
  double gpa;
  double hours;

  SemesterEntry({this.gpa = 0.0, this.hours = 15});
}

// ── تصنيف مستوى الطالب من وثيقة الكلية ───────────────────────────────────
class AcademicStatus {
  final String labelAr;
  final String labelEn;
  final String emoji;
  final bool canGraduate;

  const AcademicStatus({
    required this.labelAr,
    required this.labelEn,
    required this.emoji,
    required this.canGraduate,
  });
}

AcademicStatus getAcademicStatus(double gpa) {
  if (gpa >= 3.60) {
    return const AcademicStatus(
      labelAr: 'مرتبة الشرف',
      labelEn: 'Honor Roll',
      emoji: '🏆',
      canGraduate: true,
    );
  } else if (gpa >= 3.00) {
    return const AcademicStatus(
      labelAr: 'أداء ممتاز',
      labelEn: 'Excellent',
      emoji: '⭐',
      canGraduate: true,
    );
  } else if (gpa >= 2.00) {
    return const AcademicStatus(
      labelAr: 'ناجح',
      labelEn: 'Passing',
      emoji: '✅',
      canGraduate: true,
    );
  } else {
    return const AcademicStatus(
      labelAr: 'دون الحد الأدنى للتخرج',
      labelEn: 'Below Minimum',
      emoji: '⚠️',
      canGraduate: false,
    );
  }
}
