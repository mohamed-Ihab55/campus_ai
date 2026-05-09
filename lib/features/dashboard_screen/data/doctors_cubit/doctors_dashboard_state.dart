part of 'doctors_dashboard_cubit.dart';

abstract class DoctorsDashboardState {}

class DoctorsInitial extends DoctorsDashboardState {}

class DoctorsLoading extends DoctorsDashboardState {}

class DoctorsLoaded extends DoctorsDashboardState {
  final List<DoctorsDashboardModel> doctors;

  DoctorsLoaded(this.doctors);
}

class DoctorsError extends DoctorsDashboardState {
  final String message;

  DoctorsError(this.message);
}