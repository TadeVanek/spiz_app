import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HouseholdException implements Exception {
  final String message;
  HouseholdException(this.message);
  @override
  String toString() => message;
}

class HouseholdService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Znaky bez snadno zaměnitelných (0/O, 1/I)
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String get _uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid);

  /// ID domácnosti přihlášeného uživatele (null = ještě v žádné není)
  Stream<String?> householdIdStream() {
    return _userDoc.snapshots().map((s) => s.data()?['householdId'] as String?);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> householdStream(String id) {
    return _db.collection('households').doc(id).snapshots();
  }

  Future<String> _generateUniqueCode() async {
    final rnd = Random.secure();
    while (true) {
      final code = List.generate(
        6,
        (_) => _alphabet[rnd.nextInt(_alphabet.length)],
      ).join();
      final exists = (await _db.collection('invites').doc(code).get()).exists;
      if (!exists) return code;
    }
  }

  Future<void> createHousehold(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw HouseholdException('Zadej název domácnosti.');

    final code = await _generateUniqueCode();
    final householdRef = _db.collection('households').doc();

    // Batch = všechny zápisy proběhnou naráz, nebo žádný
    final batch = _db.batch();
    batch.set(householdRef, {
      'name': trimmed,
      'inviteCode': code,
      'members': [_uid],
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection('invites').doc(code), {
      'householdId': householdRef.id,
    });
    batch.set(_userDoc, {
      'email': _auth.currentUser!.email,
      'householdId': householdRef.id,
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> joinHousehold(String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) throw HouseholdException('Zadej kód domácnosti.');

    final invite = await _db.collection('invites').doc(code).get();
    if (!invite.exists) throw HouseholdException('Takový kód neexistuje.');
    final householdId = invite.data()!['householdId'] as String;

    final batch = _db.batch();
    batch.update(_db.collection('households').doc(householdId), {
      'members': FieldValue.arrayUnion([_uid]),
    });
    batch.set(_userDoc, {
      'email': _auth.currentUser!.email,
      'householdId': householdId,
    }, SetOptions(merge: true));
    await batch.commit();
  }
}
