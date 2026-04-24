part of 'gpa_cubit.dart';

@immutable
sealed class GpaCubitState {}

class GpaState {
  final List<GpaCourse> courses;
  final double? semesterResult;

  final List<SemesterEntry> semesters;
  final double? cumulativeResult;

  const GpaState({
    required this.courses,
    required this.semesters,
    this.semesterResult,
    this.cumulativeResult,
  });

  GpaState copyWith({
    List<GpaCourse>? courses,
    double? semesterResult,
    List<SemesterEntry>? semesters,
    double? cumulativeResult,
  }) {
    return GpaState(
      courses: courses ?? this.courses,
      semesters: semesters ?? this.semesters,
      semesterResult: semesterResult,
      cumulativeResult: cumulativeResult,
    );
  }
}
