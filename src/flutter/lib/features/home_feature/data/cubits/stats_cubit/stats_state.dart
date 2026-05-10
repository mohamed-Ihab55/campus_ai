part of 'stats_cubit.dart';

class StatsState extends Equatable {
  final bool isLoading;
  final Map<String, int> stats;
  final String? error;

  const StatsState({this.isLoading = false, this.stats = const {}, this.error});

  StatsState copyWith({
    bool? isLoading,
    Map<String, int>? stats,
    String? error,
  }) {
    return StatsState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, stats, error];
}
