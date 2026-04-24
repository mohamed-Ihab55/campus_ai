import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campus_ai/features/doctors_feature/data/services/doctor_repo.dart';
import 'doctor_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final DoctorsRepository _repo;

  DoctorsCubit({DoctorsRepository? repo})
      : _repo = repo ?? DoctorsRepository(),
        super(const DoctorsInitial());

  Future<void> load() async {
    emit(const DoctorsLoading());

    try {
      final doctors = await _repo.fetchAll();

      final departments = [
        'All',
        ...doctors.map((d) => d.department).toSet(),
      ];

      emit(DoctorsLoaded(
        all: doctors,
        departments: departments,
        selectedDept: 'All',
        query: '',
      ));
    } catch (e) {
      emit(DoctorsError(e.toString()));
    }
  }

  void selectDepartment(String dept) {
    final current = state;
    if (current is DoctorsLoaded) {
      emit(current.copyWith(selectedDept: dept));
    }
  }

  void search(String query) {
    final current = state;
    if (current is DoctorsLoaded) {
      emit(current.copyWith(query: query));
    }
  }
}