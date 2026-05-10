part of 'department_cubit.dart';

abstract class DepartmentState {}

class DepartmentInitial extends DepartmentState {}

class DepartmentLoading extends DepartmentState {}

class DepartmentSuccess extends DepartmentState {
  final List<DepartmentModel> departments;

  DepartmentSuccess(this.departments);
}

class DepartmentError extends DepartmentState {
  final String message;

  DepartmentError(this.message);
}
