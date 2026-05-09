part of 'doctors_dashboard_cubit.dart';

abstract class DoctorsDashboardState {}

class DoctorsInitial extends DoctorsDashboardState {}

class DoctorsLoading extends DoctorsDashboardState {}

class DoctorsLoaded extends DoctorsDashboardState {
  final List<DoctorsDashboardModel> doctors;
  final List<DoctorsDashboardModel> allDoctors;

  DoctorsLoaded({
    required this.doctors,
    required this.allDoctors,
  });
}

class DoctorsError extends DoctorsDashboardState {
  final String message;

  DoctorsError(this.message);
}