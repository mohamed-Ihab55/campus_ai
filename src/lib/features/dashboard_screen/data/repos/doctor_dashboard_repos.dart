import 'package:campus_ai/features/dashboard_screen/data/models/doctors_dashboard_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorsDashboardRepo {
  final FirebaseFirestore firestore;

  DoctorsDashboardRepo(this.firestore);

  CollectionReference get doctors => firestore.collection('doctors');

  Stream<List<DoctorsDashboardModel>> getDoctors() {
    return doctors.snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          return DoctorsDashboardModel.fromFirestore(
            doc.id,
            doc.data() as Map<String, dynamic>,
          );
        }).toList();
      },
    );
  }

  Future<void> addDoctor(DoctorsDashboardModel doctor) async {
    await doctors.add(doctor.toMap());
  }

  Future<void> updateDoctor(DoctorsDashboardModel doctor) async {
    await doctors.doc(doctor.id).update(doctor.toMap());
  }

  Future<void> deleteDoctor(String id) async {
    await doctors.doc(id).delete();
  }
}