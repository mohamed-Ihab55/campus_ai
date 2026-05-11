import 'package:campus_ai/features/dashboard_screen/data/models/department_dashboard_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'add_department_state.dart';

class AddDepartmentCubit extends Cubit<AddDepartmentState> {
  AddDepartmentCubit() : super(DepartmentInitial());

  static AddDepartmentCubit get(context) =>
      BlocProvider.of(context);

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addDepartment({
    required String deptName,
    required List<String> subFields,
  }) async {
    emit(AddDepartmentLoading());

    try {
      DepartmentDashboardModel model = DepartmentDashboardModel(
        deptName: deptName,
        subFields: subFields,
      );

      await firestore.collection('departments').add(
        model.toMap(),
      );

      emit(AddDepartmentSuccess());
    } catch (e) {
      emit(AddDepartmentError(e.toString()));
    }
  }
}