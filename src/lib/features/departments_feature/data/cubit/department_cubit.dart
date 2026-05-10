import 'package:bloc/bloc.dart';
import 'package:campus_ai/features/departments_feature/data/models/department_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'department_state.dart';

class DepartmentCubit extends Cubit<DepartmentState> {
  DepartmentCubit() : super(DepartmentInitial());

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> getDepartments() async {
    emit(DepartmentLoading());

    try {
      final result = await firestore.collection('departments').get();

      final data = result.docs.map((doc) {
        return DepartmentModel.fromJson(doc.data());
      }).toList();

      emit(DepartmentSuccess(data));
    } catch (e) {
      emit(DepartmentError(e.toString()));
    }
  }
}
