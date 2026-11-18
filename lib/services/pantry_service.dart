import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_item.dart';

class PantryService {
  final String householdId;
  PantryService(this.householdId);

  CollectionReference<Map<String, dynamic>> get _items => FirebaseFirestore
      .instance
      .collection('households')
      .doc(householdId)
      .collection('items');

  /// Živý seznam potravin seřazený podle data expirace
  Stream<List<FoodItem>> itemsStream() {
    return _items
        .orderBy('expiration')
        .snapshots()
        .map((snap) => snap.docs.map(FoodItem.fromDoc).toList());
  }

  /// Záměrně bez await: Firestore zapíše do lokální paměti okamžitě
  /// a na server dosynchronizuje později (funguje i offline).
  void addItem({
    required String name,
    required String brand,
    required int quantity,
    required DateTime expiration,
    required String category,
  }) {
    _items.add({
      'name': name,
      'brand': brand,
      'quantity': quantity,
      'expiration': Timestamp.fromDate(expiration),
      'category': category,
      'addedBy': FirebaseAuth.instance.currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void deleteItem(String id) {
    _items.doc(id).delete();
  }
}
