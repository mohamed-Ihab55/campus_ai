import 'package:bloc/bloc.dart';
import 'package:campus_ai/features/service_feature/data/model/gpa_course_model.dart';
import 'package:campus_ai/features/service_feature/logic/gpa_calculator.dart';
import 'package:meta/meta.dart';

part 'gpa_state.dart';

class GpaCubit extends Cubit<GpaState> {
  GpaCubit()
      : super(
          GpaState(
            courses: [GpaCourse(), GpaCourse(), GpaCourse()],
            semesters: [SemesterEntry(), SemesterEntry(), SemesterEntry()],
          ),
        );

  void addCourse() {
    emit(state.copyWith(
      courses: [...state.courses, GpaCourse()],
      semesterResult: null,
    ));
  }

  void removeCourse(int i) {
    if (state.courses.length <= 1) return;

    final updated = [...state.courses]..removeAt(i);
    emit(state.copyWith(courses: updated, semesterResult: null));
  }

  void updateCourse(int i, GpaCourse course) {
    final updated = [...state.courses];
    updated[i] = course;

    emit(state.copyWith(courses: updated, semesterResult: null));
  }

  void calcSemester() {
    final result = calcSemesterGPA(state.courses);
    emit(state.copyWith(semesterResult: result));
  }

  void resetSemester() {
    emit(state.copyWith(
      courses: [GpaCourse(), GpaCourse(), GpaCourse()],
      semesterResult: null,
    ));
  }

  void addSemester() {
    emit(state.copyWith(
      semesters: [...state.semesters, SemesterEntry()],
      cumulativeResult: null,
    ));
  }

  void removeSemester(int i) {
    if (state.semesters.length <= 1) return;

    final updated = [...state.semesters]..removeAt(i);
    emit(state.copyWith(semesters: updated, cumulativeResult: null));
  }

  void updateSemester(int i, SemesterEntry entry) {
    final updated = [...state.semesters];
    updated[i] = entry;

    emit(state.copyWith(semesters: updated, cumulativeResult: null));
  }

  void calcCumulative() {
    final result = calcCumulativeGPA(state.semesters);
    emit(state.copyWith(cumulativeResult: result));
  }

  void resetCumulative() {
    emit(state.copyWith(
      semesters: [SemesterEntry(), SemesterEntry(), SemesterEntry()],
      cumulativeResult: null,
    ));
  }
}
