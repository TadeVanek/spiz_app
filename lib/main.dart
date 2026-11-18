import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/household_gate.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

Future<void> main() async {
  // Nutné před jakýmkoliv použitím pluginů (Firebase) před runApp
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SpizApp());
}

class SpizApp extends StatelessWidget {
  const SpizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spíž',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // StreamBuilder poslouchá stav přihlášení a sám přepíná obrazovky
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) return const HouseholdGate();
          return const LoginScreen();
        },
      ),
    );
  }
}
