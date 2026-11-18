import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/food_item.dart';
import '../services/household_service.dart';
import '../services/pantry_service.dart';
import '../theme.dart';
import 'add_item_screen.dart';

class PantryScreen extends StatefulWidget {
  final String householdId;
  const PantryScreen({super.key, required this.householdId});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  late final PantryService _service = PantryService(widget.householdId);
  String _query = '';
  String _category = 'all';

  static const _filters = {
    'all': 'Vše',
    'lednice': 'Lednice',
    'mrazak': 'Mrazák',
    'spiz': 'Spíž',
  };

  bool _matches(FoodItem i) {
    if (_category != 'all' && i.category != _category) return false;
    final q = _query.trim().toLowerCase();
    return q.isEmpty ||
        i.name.toLowerCase().contains(q) ||
        i.brand.toLowerCase().contains(q);
  }

  void _openAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemScreen(householdId: widget.householdId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hlavička s názvem domácnosti
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: StreamBuilder(
                stream: HouseholdService().householdStream(widget.householdId),
                builder: (context, snap) {
                  final name = snap.data?.data()?['name'] ?? '';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NAŠE DOMÁCNOST',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: kGreen,
                        ),
                      ),
                      Text(
                        'Spíž – $name',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Vyhledávání
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Hledat potravinu…',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Filtry podle kategorie
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final e in _filters.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e.value),
                        selected: _category == e.key,
                        showCheckmark: false,
                        selectedColor: kGreen,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _category == e.key
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setState(() => _category = e.key),
                      ),
                    ),
                ],
              ),
            ),
            // Seznam potravin
            Expanded(
              child: StreamBuilder<List<FoodItem>>(
                stream: _service.itemsStream(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(child: Text('Chyba: ${snap.error}'));
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snap.data!.where(_matches).toList();
                  final n = items.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Podle data expirace'),
                            Text(
                              '$n ${czPlural(n, 'položka', 'položky', 'položek')}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: items.isEmpty
                            ? const Center(
                                child: Text(
                                  'Spíž je zatím prázdná.\nPřidej první potravinu tlačítkem +',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  140,
                                ),
                                itemCount: items.length,
                                itemBuilder: (context, i) {
                                  final item = items[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Dismissible(
                                      key: ValueKey(item.id),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(
                                          right: 24,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kRed,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onDismissed: (_) {
                                        _service.deleteItem(item.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${item.name} smazáno',
                                                ),
                                              ),
                                            );
                                      },
                                      child: FoodCard(item: item),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add',
            backgroundColor: Colors.white,
            foregroundColor: kGreen,
            onPressed: _openAdd,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'scan',
            backgroundColor: kGreen,
            foregroundColor: Colors.white,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Skener přidáme později')),
            ),
            child: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
    );
  }
}

/// Karta jedné potraviny (barevný proužek vlevo, název, štítek stavu)
class FoodCard extends StatelessWidget {
  final FoodItem item;
  const FoodCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.statusColor;
    final frozen = item.category == 'mrazak';
    final subtitle = item.brand.isEmpty
        ? '${item.quantity} ks'
        : '${item.brand} · ${item.quantity} ks';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.white,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: frozen
                              ? const Color(0xFFE3F0F8)
                              : const Color(0xFFE8F3E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: frozen
                            ? const Icon(
                                Icons.ac_unit,
                                color: Color(0xFF3B82A8),
                              )
                            : Text(
                                item.name.isEmpty
                                    ? '?'
                                    : item.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: kGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.statusLabel,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d. M. yyyy').format(item.expiration),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
