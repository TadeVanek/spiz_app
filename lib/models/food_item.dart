import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

enum ExpiryStatus { expired, soon, ok }

/// České skloňování: 1 den, 2-4 dny, 5+ dní
String czPlural(int n, String one, String few, String many) {
  if (n == 1) return one;
  if (n >= 2 && n <= 4) return few;
  return many;
}

class FoodItem {
  final String id;
  final String name;
  final String brand;
  final int quantity;
  final DateTime expiration;
  final String category; // 'lednice' | 'mrazak' | 'spiz'

  FoodItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.quantity,
    required this.expiration,
    required this.category,
  });

  /// Převod dokumentu z Firestoru na objekt
  factory FoodItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return FoodItem(
      id: doc.id,
      name: d['name'] ?? '',
      brand: d['brand'] ?? '',
      quantity: (d['quantity'] as num?)?.toInt() ?? 1,
      expiration: (d['expiration'] as Timestamp).toDate(),
      category: d['category'] ?? 'spiz',
    );
  }

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiration.year, expiration.month, expiration.day);
    return exp.difference(today).inDays;
  }

  ExpiryStatus get status {
    if (daysLeft < 0) return ExpiryStatus.expired;
    if (daysLeft <= 3) return ExpiryStatus.soon;
    return ExpiryStatus.ok;
  }

  Color get statusColor => switch (status) {
    ExpiryStatus.expired => kRed,
    ExpiryStatus.soon => kOrange,
    ExpiryStatus.ok => kGreen,
  };

  String get statusLabel {
    final d = daysLeft;
    if (d < 0) return 'Prošlé';
    if (d == 0) return 'Dnes';
    return 'Za $d ${czPlural(d, 'den', 'dny', 'dní')}';
  }
}
