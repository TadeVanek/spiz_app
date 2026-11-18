import 'package:flutter/material.dart';

import '../services/household_service.dart';
import 'household_setup_screen.dart';
import 'main_shell.dart';

class HouseholdGate extends StatelessWidget {
  const HouseholdGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: HouseholdService().householdIdStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Chyba: ${snapshot.error}')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final householdId = snapshot.data;
        if (householdId == null) return const HouseholdSetupScreen();
        return MainShell(householdId: householdId);
      },
    );
  }
}
