import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/pantry_service.dart';
import '../theme.dart';

class AddItemScreen extends StatefulWidget {
  final String householdId;
  final String? initialName;
  final String? initialBrand;

  const AddItemScreen({
    super.key,
    required this.householdId,
    this.initialName,
    this.initialBrand,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  late final _brand = TextEditingController(text: widget.initialBrand);
  int _quantity = 1;
  DateTime _expiration = DateTime.now().add(const Duration(days: 7));
  String _category = 'lednice';

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiration,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && mounted) setState(() => _expiration = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    PantryService(widget.householdId).addItem(
      name: _name.text.trim(),
      brand: _brand.text.trim(),
      quantity: _quantity,
      expiration: _expiration,
      category: _category,
    );
    Navigator.pop(context, true);
  }

  InputDecoration _decoration(String label, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nová potravina'),
        centerTitle: true,
        backgroundColor: kBackground,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoration('Název'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Zadej název' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _brand,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoration('Značka'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Počet kusů',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        IconButton.outlined(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '$_quantity',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton.outlined(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: _decoration(
                      'Datum expirace',
                      suffix: const Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(DateFormat('d. M. yyyy').format(_expiration)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kategorie',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'lednice', label: Text('Lednice')),
                    ButtonSegment(value: 'mrazak', label: Text('Mrazák')),
                    ButtonSegment(value: 'spiz', label: Text('Spíž')),
                  ],
                  selected: {_category},
                  onSelectionChanged: (s) =>
                      setState(() => _category = s.first),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _save,
                  child: const Text('Uložit potravinu'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Zrušit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
