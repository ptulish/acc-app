// lib/widgets/create_card_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/aac_card_model.dart';
import '../providers/cards_provider.dart';
import '../providers/categories_provider.dart';
import 'aac_card.dart';

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
  String _currentEmoji = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _emojiController.addListener(_onEmojiChanged);
  }

  void _onEmojiChanged() {
    setState(() {
      _currentEmoji = _emojiController.text.trim();
    });
  }

  void _saveCard() async {
    if (_formKey.currentState!.validate()) {
      final newCard = AacCardModel(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        label: _labelController.text.trim(),
        category: _selectedCategory,
        imagePath: _currentEmoji,
        isCustom: true,
        usageCount: 0,
      );

      try {
        await ref.read(cardsLibraryProvider.notifier).addCustomCard(newCard);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kartīte izveidota veiksmīgi!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kļūda saglabājot: $e'), backgroundColor: Colors.red),
        );
      }
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

    // Определяем ширину экрана. Если меньше 600px - считаем, что это телефон
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Выносим поля ввода в отдельную переменную для чистоты кода
    final formFields = Column(
      children: [
        TextFormField(
          controller: _labelController,
          decoration: InputDecoration(
            labelText: 'Nosaukums (piem., Sula)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.text_fields),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Ievadiet nosaukumu' : null,
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
    );

    // Выносим предпросмотр в отдельную переменную
    final previewSection = Column(
      children: [
        const Text(
          'Priekšskatījums:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: 140, // На телефоне сделаем чуть компактнее
            height: 160,
            child: AacCard(
              card: AacCardModel(
                id: 'preview',
                label: _labelController.text.trim(),
                category: _selectedCategory,
                imagePath: _currentEmoji,
                isCustom: true,
              ),
            ),
          ),
        ),
      ],
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: SingleChildScrollView(
        child: Container(
          // Используем BoxConstraints: на планшете будет до 750, на телефоне сожмется под экран
          constraints: const BoxConstraints(maxWidth: 750),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Jaunas kartītes izveide',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // АДАПТИВНАЯ РАЗМЕТКА
                if (isMobile) ...[
                  // Для телефона: Предпросмотр сверху, поля снизу
                  previewSection,
                  const SizedBox(height: 24),
                  formFields,
                ] else ...[
                  // Для планшета: Форма слева, предпросмотр справа
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: formFields),
                      const SizedBox(width: 32),
                      Expanded(flex: 2, child: previewSection),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                // Адаптивные кнопки
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Atcelt', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16), // Чуть уменьшили отступ для узких экранов
                    Expanded(
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
      ),
    );
  }
}