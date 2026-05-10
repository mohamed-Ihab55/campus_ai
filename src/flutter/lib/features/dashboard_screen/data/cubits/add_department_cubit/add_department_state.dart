part of 'add_department_cubit.dart';

abstract class AddDepartmentState {}

class DepartmentInitial extends AddDepartmentState {}

class AddDepartmentLoading extends AddDepartmentState {}

class AddDepartmentSuccess extends AddDepartmentState {}

class AddDepartmentError extends AddDepartmentState {
  final String error;

  AddDepartmentError(this.error);
}