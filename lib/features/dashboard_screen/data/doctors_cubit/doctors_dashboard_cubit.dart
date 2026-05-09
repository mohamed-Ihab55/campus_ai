import 'dart:async';

import 'package:bloc/bloc.dart';

import '../models/doctors_dashboard_model.dart';
import '../repos/doctor_dashboard_repos.dart';

part 'doctors_dashboard_state.dart';

class DoctorsDashboardCubit extends Cubit<DoctorsDashboardState> {
  final DoctorsDashboardRepo repo;

  DoctorsDashboardCubit(this.repo) : super(DoctorsInitial());

  StreamSubscription? _subscription;

  void getDoctors() {
    emit(DoctorsLoading());

    _subscription?.cancel();

    _subscription = repo.getDoctors().listen(
          (doctors) {
        emit(DoctorsLoaded(doctors));
      },
      onError: (e) {
        emit(DoctorsError(e.toString()));
      },
    );
  }

  Future<void> addDoctor(DoctorsDashboardModel doctor) async {
    await repo.addDoctor(doctor);
  }

  Future<void> updateDoctor(DoctorsDashboardModel doctor) async {
    await repo.updateDoctor(doctor);
  }

  Future<void> deleteDoctor(String id) async {
    await repo.deleteDoctor(id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}