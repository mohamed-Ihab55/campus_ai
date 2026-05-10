part of 'services_dashboard_cuibt.dart';

abstract class ServiceDashboardState {}

class ServiceInitial extends ServiceDashboardState {}

class ServiceLoading extends ServiceDashboardState {}

class ServiceSuccess extends ServiceDashboardState {}

class ServiceError extends ServiceDashboardState {
  final String message;
  ServiceError(this.message);
}