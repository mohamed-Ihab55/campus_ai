import 'dart:async';
import 'package:bloc/bloc.dart';

import '../models/doctors_dashboard_model.dart';
import '../repos/doctor_dashboard_repos.dart';

part 'doctors_dashboard_state.dart';

class DoctorsDashboardCubit extends Cubit<DoctorsDashboardState> {
  final DoctorsDashboardRepo repo;

  DoctorsDashboardCubit(this.repo) : super(DoctorsInitial());

  StreamSubscription? _subscription;

  List<DoctorsDashboardModel> _allDoctors = [];
  String _searchQuery = "";

  /// 🔄 GET DOCTORS (REALTIME)
  void getDoctors() {
    emit(DoctorsLoading());

    _subscription?.cancel();

    _subscription = repo.getDoctors().listen(
          (doctors) {
        _allDoctors = doctors;

        emit(
          DoctorsLoaded(
            doctors: _applyFilter(doctors),
            allDoctors: doctors,
          ),
        );
      },
      onError: (e) {
        emit(DoctorsError(e.toString()));
      },
    );
  }

  /// 🔍 SEARCH FUNCTION
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();

    if (state is DoctorsLoaded) {
      emit(
        DoctorsLoaded(
          doctors: _applyFilter(_allDoctors),
          allDoctors: _allDoctors,
        ),
      );
    }
  }

  /// 🧠 FILTER LOGIC
  List<DoctorsDashboardModel> _applyFilter(
      List<DoctorsDashboardModel> doctors) {
    if (_searchQuery.isEmpty) return doctors;

    return doctors.where((doc) {
      return doc.name.toLowerCase().contains(_searchQuery) ||
          doc.title.toLowerCase().contains(_searchQuery) ||
          doc.department.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  /// ➕ ADD
  Future<void> addDoctor(DoctorsDashboardModel doctor) async {
    await repo.addDoctor(doctor);
  }

  /// ✏️ UPDATE
  Future<void> updateDoctor(DoctorsDashboardModel doctor) async {
    await repo.updateDoctor(doctor);
  }

  /// ❌ DELETE
  Future<void> deleteDoctor(String id) async {
    await repo.deleteDoctor(id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}