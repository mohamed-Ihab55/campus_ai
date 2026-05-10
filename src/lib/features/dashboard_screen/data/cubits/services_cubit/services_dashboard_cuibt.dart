import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'services_dashboard_state.dart';

class ServiceDashboardCubit extends Cubit<ServiceDashboardState> {
  ServiceDashboardCubit() : super(ServiceInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addService({
    required String icon,
    required String title,
    required String subTitle,
    required String route,
  }) async {
    emit(ServiceLoading());

    try {
      await _firestore.collection('services').add({
        'icon': 'receipt',
        'title': title,
        'subTitle': subTitle,
        'borderColor': '0xFFC7D2FE',
        'accentColor': '0xFF0D2680',
        'route': '/transcript',
      });

      emit(ServiceSuccess());
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }


}