import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final String id;
  final String name;
  final bool checked;

  ShoppingItem({required this.id, required this.name, required this.checked});

  factory ShoppingItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ShoppingItem(
      id: doc.id,
      name: d['name'] ?? '',
      checked: d['checked'] ?? false,
    );
  }
}

class ShoppingService {
  final String householdId;
  ShoppingService(this.householdId);

  CollectionReference<Map<String, dynamic>> get _col => FirebaseFirestore
      .instance
      .collection('households')
      .doc(householdId)
      .collection('shopping');

  Stream<List<ShoppingItem>> itemsStream() {
    return _col
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(ShoppingItem.fromDoc).toList());
  }

  void add(String name) {
    _col.add({
      'name': name,
      'checked': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void setChecked(String id, bool checked) {
    _col.doc(id).update({'checked': checked});
  }

  void delete(String id) {
    _col.doc(id).delete();
  }
}
