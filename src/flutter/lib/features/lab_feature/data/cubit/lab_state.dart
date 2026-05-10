part of 'lab_cubit.dart';

sealed class LabState extends Equatable {
  const LabState();

  @override
  List<Object> get props => [];
}

final class LabInitial extends LabState {}

final class LabLoading extends LabState {}

final class LabSuccess extends LabState {
  final List<LabModel> labs;

  const LabSuccess(this.labs);
}

final class LabError extends LabState {
  final String message;

  const LabError(this.message);
}
