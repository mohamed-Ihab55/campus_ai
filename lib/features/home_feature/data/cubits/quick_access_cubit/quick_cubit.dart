import 'package:bloc/bloc.dart';
import 'package:campus_ai/features/home_feature/data/cubits/quick_access_cubit/quick_state.dart';
import 'package:campus_ai/features/home_feature/data/services/quick_repo.dart';

class QuickCubit extends Cubit<QuickState> {
  final QuickRepo repo;

  QuickCubit(this.repo) : super(QuickLoading());

  Future<void> load() async {
    try {
      final data = await repo.fetchItems();
      emit(QuickLoaded(data));
    } catch (e) {
      emit(QuickError(e.toString()));
    }
  }
}
