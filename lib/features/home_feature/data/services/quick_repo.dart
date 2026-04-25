import 'package:campus_ai/features/home_feature/data/model/quick_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuickRepo {
  final _firestore = FirebaseFirestore.instance;

  Future<List<QuickItem>> fetchItems() async {
    final res = await _firestore.collection('quick_access').get();

    return res.docs
        .map((e) => QuickItem.fromJson(e.data(), e.id))
        .toList();
  }
}