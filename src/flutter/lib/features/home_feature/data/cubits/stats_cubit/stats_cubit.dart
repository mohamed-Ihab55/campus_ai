import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  StatsCubit() : super(const StatsState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> countDocuments(String collectionName) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> loadStats() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final doctors = await countDocuments('doctors');
      final departments = await countDocuments('departments');
      final services = await countDocuments('services');
      final labs = await countDocuments('labs');

      emit(
        state.copyWith(
          isLoading: false,
          stats: {
            'doctors': doctors,
            'departments': departments,
            'services': services,
            'labs': labs,
          },
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }
}