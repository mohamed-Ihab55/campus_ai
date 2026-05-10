import 'package:campus_ai/features/home_feature/data/model/quick_item_model.dart';

sealed class QuickState {}

class QuickLoading extends QuickState {}

class QuickLoaded extends QuickState {
  final List<QuickItem> items;
  QuickLoaded(this.items);
}

class QuickError extends QuickState {
  final String msg;
  QuickError(this.msg);
}
