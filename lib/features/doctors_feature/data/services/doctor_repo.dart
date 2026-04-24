import 'package:campus_ai/features/doctors_feature/data/models/doctor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorsRepository {
  final _col = FirebaseFirestore.instance.collection('doctors');

  Future<List<Doctor>> fetchAll() async {
    final snap = await _col.orderBy('department').get();
    return snap.docs
        .map((d) => Doctor.fromJson(d.id, d.data()))
        .toList();
  }
}