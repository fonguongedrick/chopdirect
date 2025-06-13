import 'package:chopdirect/models/farmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Stream<List<Map<String, dynamic>>> fetchProducts() {
  return FirebaseFirestore.instance
      .collection('products')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList());
}
Stream<List<Farmer>> fetchFarmers() {
  return FirebaseFirestore.instance
      .collection('users_chopdirect')
      .where('role', isEqualTo: 'farmer')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Farmer.fromMap(data);
          }).toList());
}