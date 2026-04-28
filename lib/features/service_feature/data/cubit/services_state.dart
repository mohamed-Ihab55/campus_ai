part of 'services_cubit.dart';

sealed class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object> get props => [];
}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesSuccess extends ServicesState {
  final List<ServiceItem> services;
  ServicesSuccess(this.services);
}

class ServicesError extends ServicesState {
  final String message;
  ServicesError(this.message);
}
