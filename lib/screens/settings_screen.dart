import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/food_item.dart';
import '../services/household_service.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  final String householdId;
  const SettingsScreen({super.key, required this.householdId});

  @override
  Widget build(BuildContext context) {
    final service = HouseholdService();
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: service.householdStream(householdId),
          builder: (context, snap) {
            final data = snap.data?.data();
            if (data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final name = (data['name'] ?? '').toString();
            final code = (data['inviteCode'] ?? '').toString();
            final members = List<String>.from(data['members'] ?? []);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'VÁŠ ÚČET',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: kGreen,
                  ),
                ),
                Text(
                  'Nastavení',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                // Zelená karta s kódem domácnosti
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.kitchen,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DOMÁCNOST',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Párovací kód',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    code,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white54,
                                    ),
                                  ),
                                  icon: const Icon(Icons.copy, size: 18),
                                  label: const Text('Kopírovat'),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: code),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Kód zkopírován'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tento kód pošli členům rodiny.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Členové
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Členové domácnosti'),
                    Text(
                      '${members.length} ${czPlural(members.length, 'člen', 'členové', 'členů')}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (members.isNotEmpty)
                  StreamBuilder(
                    stream: service.membersStream(members),
                    builder: (context, msnap) {
                      final emails = {
                        for (final d in msnap.data?.docs ?? [])
                          d.id: (d.data()['email'] as String?) ?? '',
                      };
                      const colors = [
                        Color(0xFFFBE0D8),
                        Color(0xFFDDEAF6),
                        Color(0xFFE2F1E2),
                      ];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            for (int i = 0; i < members.length; i++) ...[
                              if (i > 0) const Divider(height: 1),
                              Builder(
                                builder: (context) {
                                  final email = emails[members[i]] ?? '';
                                  final label = email.isEmpty
                                      ? 'Člen domácnosti'
                                      : email;
                                  final initials = email.length >= 2
                                      ? email.substring(0, 2).toUpperCase()
                                      : '?';
                                  return ListTile(
                                    tileColor: Colors.white,
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          colors[i % colors.length],
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    title: Text(label),
                                    subtitle: members[i] == myUid
                                        ? const Text('Vy')
                                        : null,
                                    trailing: i == 0
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE3F0E3),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Správce',
                                              style: TextStyle(
                                                color: kGreen,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          )
                                        : null,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kRed,
                    side: BorderSide(color: kRed.withValues(alpha: 0.4)),
                    backgroundColor: kRed.withValues(alpha: 0.06),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Odhlásit se'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
