import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/household_service.dart';
import '../services/shopping_service.dart';
import '../theme.dart';
import 'add_item_screen.dart';

class ShoppingScreen extends StatefulWidget {
  final String householdId;
  const ShoppingScreen({super.key, required this.householdId});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  late final ShoppingService _service = ShoppingService(widget.householdId);
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _service.add(text);
    _controller.clear();
  }

  /// Koupené položky se do spíže přesunou jednu po druhé:
  /// otevře se formulář s předvyplněným názvem a doplníš expiraci.
  Future<void> _moveToPantry(List<ShoppingItem> checked) async {
    for (final item in checked) {
      if (!mounted) return;
      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AddItemScreen(
            householdId: widget.householdId,
            initialName: item.name,
          ),
        ),
      );
      if (saved != true) break; // uživatel dal "Zrušit"
      _service.delete(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Hlavička
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: HouseholdService().householdStream(
                        widget.householdId,
                      ),
                      builder: (context, snap) {
                        final name = (snap.data?.data()?['name'] ?? '')
                            .toString();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                                color: kGreen,
                              ),
                            ),
                            Text(
                              'Nákupní seznam',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F0E3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: kGreen,
                    ),
                  ),
                ],
              ),
            ),
            // Přidání položky
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _add(),
                      decoration: InputDecoration(
                        hintText: 'Přidat položku…',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _add,
                    style: IconButton.styleFrom(
                      backgroundColor: kGreen,
                      fixedSize: const Size(52, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            // Seznam
            Expanded(
              child: StreamBuilder<List<ShoppingItem>>(
                stream: _service.itemsStream(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(child: Text('Chyba: ${snap.error}'));
                  }
                  final items = snap.data ?? [];
                  final checked = items.where((i) => i.checked).toList();
                  final remaining = items.length - checked.length;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('K nákupu'),
                          Text(
                            '$remaining ${czPlural(remaining, 'zbývá', 'zbývají', 'zbývá')}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('Nákupní seznam je prázdný.'),
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            children: [
                              for (int i = 0; i < items.length; i++) ...[
                                if (i > 0) const Divider(height: 1),
                                Dismissible(
                                  key: ValueKey(items[i].id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: kRed,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) =>
                                      _service.delete(items[i].id),
                                  child: CheckboxListTile(
                                    tileColor: Colors.white,
                                    activeColor: kGreen,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: items[i].checked,
                                    onChanged: (v) => _service.setChecked(
                                      items[i].id,
                                      v ?? false,
                                    ),
                                    title: Text(
                                      items[i].name,
                                      style: TextStyle(
                                        decoration: items[i].checked
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: items[i].checked
                                            ? Colors.black45
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F0E3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.kitchen, color: kGreen),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Koupené položky můžete rovnou přidat do spíže.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: kGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: checked.isEmpty
                            ? null
                            : () => _moveToPantry(checked),
                        child: const Text('Přesunout koupené do spíže'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
