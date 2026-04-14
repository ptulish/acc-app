// lib/widgets/create_category_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/categories_provider.dart';

class CreateCategoryDialog extends ConsumerStatefulWidget {
  const CreateCategoryDialog({super.key});

  @override
  ConsumerState<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends ConsumerState<CreateCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();

  final List<Color> _availableColors = [
    Colors.red, Colors.orange, Colors.yellow.shade700, Colors.green,
    Colors.teal, Colors.cyan,
    Colors.blue, Colors.indigo, Colors.purple,
    Colors.pinkAccent, Colors.brown, Colors.blueGrey, Colors.grey
  ];
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _availableColors.first;
  }

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final newLabel = _labelController.text.trim();

      final newCategory = AacCategory(
        'custom_cat_${DateTime.now().millisecondsSinceEpoch}',
        newLabel.toUpperCase(),
        _selectedColor,
      );

      try {
        await ref.read(categoriesProvider.notifier).addCategory(newCategory);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategorija izveidota veiksmīgi!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kļūda saglabājot: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _pickCustomColor() {
    Color tempColor = _selectedColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izvēlieties savu krāsu'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) {
              tempColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Atcelt'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Labi'),
            onPressed: () {
              setState(() {
                _selectedColor = tempColor;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: SingleChildScrollView(
        child: Container(
          // ОГРАНИЧИВАЕМ ширину, а не задаем жестко
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
        // ДОБАВЛЕН скролл для защиты от клавиатуры
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Jaunas kategorijas izveide',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: 'Nosaukums (piem., Rotaļlietas)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Ievadiet nosaukumu' : null,
                ),
                const SizedBox(height: 24),

                const Text('Izvēlieties krāsu:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._availableColors.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 20,
                          child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),

                    GestureDetector(
                      onTap: _pickCustomColor,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400, width: 2),
                        ),
                        child: const Icon(Icons.add, color: Colors.grey, size: 28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Кнопки всегда сжимаются под размер экрана
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Atcelt', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: _saveCategory,
                        child: const Text('Izveidot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}