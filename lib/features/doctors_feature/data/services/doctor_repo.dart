import 'package:campus_ai/features/doctors_feature/data/models/doctor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorsRepository {
  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('doctors');

  Future<List<Doctor>> fetchAll() async {
    final snapshot = await _col.get();

    return snapshot.docs.map((doc) {
      return Doctor.fromJson(
        doc.id,
        doc.data(),
      );
    }).toList();
  }
}