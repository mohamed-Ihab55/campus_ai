import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'add_lab_state.dart';

class LabsDashboardCubit extends Cubit<LabsDashboardState> {
  LabsDashboardCubit() : super(LabsInitial());

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addLab(String labName) async {
    try {
      emit(LabsLoading());

      await firestore.collection('labs').add({
        'labName': labName,
      });

      emit(LabsSuccess());
    } catch (e) {
      emit(LabsError(e.toString()));
    }
  }
}