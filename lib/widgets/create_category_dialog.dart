// lib/widgets/create_category_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 1. ИМПОРТ ПАКЕТА ВЫБОРА ЦВЕТА
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

  // 2. ОБНОВЛЕННАЯ ПАЛИТРА: Добавили Colors.cyan
  final List<Color> _availableColors = [
    Colors.red, Colors.orange, Colors.yellow.shade700, Colors.green,
    Colors.teal, Colors.cyan, // <- Новый стандартный цвет
    Colors.blue, Colors.indigo, Colors.purple,
    Colors.pinkAccent, Colors.brown, Colors.blueGrey, Colors.grey
  ];
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _availableColors.first; // По умолчанию Красный
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final newLabel = _labelController.text.trim();

      final newCategory = AacCategory(
        'custom_cat_${DateTime.now().millisecondsSinceEpoch}', // Генерируем ID
        newLabel.toUpperCase(), // Категории у нас капсом
        _selectedColor,
      );

      ref.read(categoriesProvider.notifier).addCategory(newCategory);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategorija izveidota veiksmīgi!'), backgroundColor: Colors.green),
      );
    }
  }

  // 3. НОВАЯ ФУНКЦИЯ: Показывает диалог выбора произвольного цвета
  void _pickCustomColor() {
    Color tempColor = _selectedColor; // Временная переменная для выбора
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izvēlieties savu krāsu'), // "Выберите свой цвет"
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor, // Начальный цвет в пикере
            onColorChanged: (color) {
              tempColor = color; // Обновляем временную переменную
            },
            showLabel: true, // Показывать HEX-код
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Atcelt'), // "Отмена"
            onPressed: () {
              Navigator.of(context).pop(); // Просто закрываем диалог
            },
          ),
          ElevatedButton(
            child: const Text('Labi'), // "ОК"
            onPressed: () {
              // Сохраняем выбранный цвет и закрываем диалог пикера
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
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('Jaunas kategorijas izveide', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: 'Nosaukums (piem., Rotaļlietas)', // Название
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ievadiet nosaukumu' : null,
              ),
              const SizedBox(height: 24),

              const Text('Izvēлиeties krāsu:', style: TextStyle(fontSize: 16, color: Colors.grey)), // Выберите цвет
              const SizedBox(height: 12),

              // 4. ОБНОВЛЕННАЯ ПАЛИТРА ЦВЕТОВ: С кнопкой '+'
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // 1. Рисуем кружочки стандартных цветов
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

                  // 2. НОВОЕ: Добавляем кнопку '+' для произвольного цвета
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
    );
  }
}