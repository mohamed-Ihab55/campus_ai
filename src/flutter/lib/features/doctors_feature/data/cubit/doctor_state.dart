import 'package:campus_ai/features/doctors_feature/data/models/doctor_model.dart';

sealed class DoctorsState {
  const DoctorsState();
}

class DoctorsInitial extends DoctorsState {
  const DoctorsInitial();
}

class DoctorsLoading extends DoctorsState {
  const DoctorsLoading();
}

class DoctorsLoaded extends DoctorsState {
  final List<Doctor> all;
  final List<String> departments;
  final String selectedDept;
  final String query;

  const DoctorsLoaded({
    required this.all,
    required this.departments,
    required this.selectedDept,
    required this.query,
  });

  List<Doctor> get filtered {
    final q = query.trim().toLowerCase();

    return all.where((d) {
      final matchDept = selectedDept == 'All' ||
          d.department.toLowerCase() == selectedDept.toLowerCase();

      final matchQuery = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.department.toLowerCase().contains(q);

      return matchDept && matchQuery;
    }).toList();
  }

  DoctorsLoaded copyWith({
    List<Doctor>? all,
    List<String>? departments,
    String? selectedDept,
    String? query,
  }) {
    return DoctorsLoaded(
      all: all ?? this.all,
      departments: departments ?? this.departments,
      selectedDept: selectedDept ?? this.selectedDept,
      query: query ?? this.query,
    );
  }
}

class DoctorsError extends DoctorsState {
  final String message;
  const DoctorsError(this.message);
}
