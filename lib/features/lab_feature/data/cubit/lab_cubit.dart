import 'package:bloc/bloc.dart';
import 'package:campus_ai/features/lab_feature/data/model/lab_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'lab_state.dart';

class LabCubit extends Cubit<LabState> {
  LabCubit() : super(LabInitial());
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> getDepartments() async {
    emit(LabLoading());

    try {
      final result = await firestore.collection('labs').get();

      final data = result.docs.map((doc) {
        return LabModel.fromJson(doc.data());
      }).toList();

      emit(LabSuccess(data));
    } catch (e) {
      emit(LabError(e.toString()));
    }
  }
}
