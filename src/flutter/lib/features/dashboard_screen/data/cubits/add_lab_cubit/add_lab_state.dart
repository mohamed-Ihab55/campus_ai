part of 'add_lab_cubit.dart';


abstract class LabsDashboardState extends Equatable {
  const LabsDashboardState();

  @override
  List<Object> get props => [];
}

class LabsInitial extends LabsDashboardState {}

class LabsLoading extends LabsDashboardState {}

class LabsSuccess extends LabsDashboardState {}

class LabsError extends LabsDashboardState {
  final String message;

  const LabsError(this.message);

  @override
  List<Object> get props => [message];
}