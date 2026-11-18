import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'pantry_screen.dart';

class MainShell extends StatefulWidget {
  final String householdId;
  const MainShell({super.key, required this.householdId});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack drží všechny záložky "naživu", takže se neztratí filtry
      body: IndexedStack(
        index: _index,
        children: [
          PantryScreen(householdId: widget.householdId),
          const Center(child: Text('Nákupní seznam – přidáme příště')),
          // Dočasně: stávající obrazovka s kódem domácnosti jako "Nastavení"
          HomeScreen(householdId: widget.householdId),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Spíž',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Nákup',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Nastavení',
          ),
        ],
      ),
    );
  }
}
