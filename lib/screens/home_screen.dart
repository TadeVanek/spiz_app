import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spíž'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Odhlásit se',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(child: Text('Přihlášen: ${user?.email}')),
    );
  }
}