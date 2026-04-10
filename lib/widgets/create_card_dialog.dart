// lib/widgets/create_card_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/aac_card_model.dart';
import '../providers/cards_provider.dart';
import '../providers/categories_provider.dart';
import 'aac_card.dart'; // Виджет карточки для предпросмотра

class CreateCardDialog extends ConsumerStatefulWidget {
  final String initialCategory;

  const CreateCardDialog({
    super.key,
    required this.initialCategory,
  });

  @override
  ConsumerState<CreateCardDialog> createState() => _CreateCardDialogState();
}

class _CreateCardDialogState extends ConsumerState<CreateCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _emojiController = TextEditingController();

  late String _selectedCategory;
  // ИЗМЕНЕНО: Инициализируем пустой строкой, без заглушки '❓'
  String _currentEmoji = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _emojiController.addListener(_onEmojiChanged);
  }

  // ИЗМЕНЕНО: Просто обновляем эмодзи, не подставляя заглушку, если поле пустое
  void _onEmojiChanged() {
    setState(() {
      _currentEmoji = _emojiController.text.trim();
    });
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final newCard = AacCardModel(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        label: _labelController.text.trim(),
        category: _selectedCategory,
        imagePath: _emojiController.text.trim(),
        isCustom: true,
        usageCount: 0,
      );

      ref.read(cardsLibraryProvider.notifier).addCustomCard(newCard);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kartīte izveidota veiksmīgi!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emojiController.removeListener(_onEmojiChanged);
    _labelController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesList = ref.watch(categoriesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Container(
        // ИЗМЕНЕНО: Увеличим ширину диалога, чтобы вместить поля слева и предпросмотр справа
        width: 750,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Окно занимает только нужное место по вертикали
            children: [
              // Заголовок (всегда сверху по центру)
              const Text(
                'Jaunas kartītes izveide',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // ==========================================
              // ИЗМЕНЕНО: Горизонтальная разметка (Форма слева, Предпросмотр справа)
              // ==========================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по верху
                children: [
                  // --- ЛЕВАЯ ЧАСТЬ: Поля ввода ---
                  Expanded(
                    flex: 3, // Занимает больше места
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _labelController,
                          decoration: InputDecoration(
                            labelText: 'Nosaukums (piem., Sula)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.text_fields),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Ievadiet nosaukumu' : null,
                          // Обновляем предпросмотр названия при вводе
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emojiController,
                          decoration: InputDecoration(
                            labelText: 'Emocijzīme (piem., 🧃)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Ievadiet emocijzīmi' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Kategorija',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.category_outlined),

                          ),
                          items: categoriesList.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(category.label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              if (value != null) _selectedCategory = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 32), // Пространство между колонками

                  // --- ПРАВАЯ ЧАСТЬ: Предпросмотр ---
                  Expanded(
                    flex: 2, // Занимает меньше места
                    child: Column(
                      children: [
                        const Text(
                          'Priekšskatījums:', // "Предпросмотр"
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            width: 150, // Чуть увеличим размер карточки предпросмотра
                            height: 170,
                            child: AacCard(
                              // ИЗМЕНЕНО: Временная модель БЕЗ заглушек. Используем чистые данные.
                              card: AacCardModel(
                                id: 'preview',
                                label: _labelController.text.trim(), // Пусто, если поле пустое
                                category: _selectedCategory,
                                imagePath: _currentEmoji, // Пусто, если поле пустое
                                isCustom: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ==========================================
              // Кнопки (Отмена / Создать)
              // (всегда снизу по центру)
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Центрируем кнопки
                children: [
                  SizedBox(
                    width: 160,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Atcelt', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveCard,
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