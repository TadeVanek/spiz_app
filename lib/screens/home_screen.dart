import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/household_service.dart';

class HomeScreen extends StatelessWidget {
  final String householdId;
  const HomeScreen({super.key, required this.householdId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: HouseholdService().householdStream(householdId),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name = data?['name'] ?? '…';
        final code = data?['inviteCode'] ?? '…';
        final members = (data?['members'] as List?)?.length ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Text('Nastavení – $name'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Odhlásit se',
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Kód pro připojení rodiny:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableText(
                      code,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: code)),
                    ),
                  ],
                ),
                Text('Členů: $members'),
              ],
            ),
          ),
        );
      },
    );
  }
}
