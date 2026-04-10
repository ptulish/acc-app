import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../providers/cards_provider.dart';
import '../widgets/aac_card.dart';
import '../models/aac_card_model.dart';
import '../widgets/create_card_dialog.dart';
import '../providers/categories_provider.dart';
import '../widgets/create_category_dialog.dart';
import '../services/local_auth_service.dart';

// Провайдер для хранения текущей выбранной категории (по умолчанию 'Food')
final selectedCategoryProvider = StateProvider<String>((ref) => 'Food');


// --- 2. Главный экран ---
class CardsScreen extends ConsumerWidget {
  CardsScreen({super.key});

  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speakSentence(List<AacCardModel> sentence) async {
    if (sentence.isEmpty) return;

    await flutterTts.setLanguage("lv-LV"); // Меняем язык на латышский!
    await flutterTts.setSpeechRate(0.5);

    String textToSpeak = sentence.map((card) => card.label).join(' ');
    await flutterTts.speak(textToSpeak);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsyncValue = ref.watch(cardsLibraryProvider);
    final sentence = ref.watch(sentenceProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final categories = ref.watch(categoriesProvider); // Добавить эту строку

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. ВЕРХНЯЯ ПАНЕЛЬ: Категории и Замочек
            // ==========================================
            Container(
              height: 70,
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
              color: Colors.white,
              child: Row(
                children: [
                  // Горизонтальный скролл категорий
                  // Горизонтальный скролл категорий
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1, // +1 для кнопки добавления
                      itemBuilder: (context, index) {

                        // Если это последний элемент списка — рисуем кнопку "+"
                        if (index == categories.length) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(context: context, builder: (context) => const CreateCategoryDialog());
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.add, color: Colors.grey, size: 28),
                            ),
                          );
                        }

                        // Иначе рисуем обычную категорию
                        final category = categories[index];
                        final isSelected = category.id == selectedCategoryId;

                        return GestureDetector(
                          onTap: () => ref.read(selectedCategoryProvider.notifier).state = category.id,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: category.color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.black87 : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))] : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              category.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: (category.color == Colors.white || category.color == Colors.yellow.shade700) ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const VerticalDivider(width: 16, thickness: 2),
                  // Кнопка-замочек (УБРАЛИ КНОПКУ ДОБАВЛЕНИЯ ОТСЮДА)
                  // Кнопка-замочек (ВРЕМЕННО РАБОТАЕТ КАК ВЫХОД ИЗ АККАУНТА)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.lock_outline, size: 32, color: Colors.grey),
                      onPressed: () async {
                        // Вызываем функцию выхода из нашего сервиса
                        await LocalAuthService().signOut();

                        // AuthGate в main.dart автоматически увидит, что email стал null,
                        // и сам перерисует экран на AuthScreen!
                      },
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 2),

            // ==========================================
            // 2. СРЕДНЯЯ ЧАСТЬ: Сетка карточек + Кнопка ДОБАВИТЬ
            // ==========================================
            Expanded(
              child: Stack(
                children: [
                  // Сама сетка (занимает весь Stack)
                  Positioned.fill(
                    child: cardsAsyncValue.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(child: Text('Ошибка: $error')),
                      data: (allCards) {
                        final filteredCards = allCards.where((card) => card.category == selectedCategoryId).toList();
                        if (filteredCards.isEmpty) {
                          return const Center(child: Text('Šajā kategorijā vēl nav kartīšu', style: TextStyle(fontSize: 18, color: Colors.grey)));
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredCards.length,
                          itemBuilder: (context, index) {
                            final card = filteredCards[index];
                            return AacCard(
                              card: card,
                              onTap: () => ref.read(sentenceProvider.notifier).addCard(card),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ПЛАВАЮЩАЯ КНОПКА СОЗДАНИЯ КАРТОЧКИ (Справа, под замочком)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      // ПЕРЕДАЕМ ТЕКУЩУЮ КАТЕГОРИЮ В ДИАЛОГ
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => CreateCardDialog(
                            initialCategory: selectedCategoryId,
                          ),
                        );
                      },
                      child: const Icon(Icons.add, size: 32),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 3. НИЖНЯЯ ПАНЕЛЬ: Строка предложения
            // ==========================================
            Container(
              height: 140, // Высота подвала
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  // Левая часть: Сама лента карточек (скроллится)
                  Expanded(
                    child: sentence.isEmpty
                        ? const Center(
                      child: Text(
                        'Pievienojiet kartītes, lai izveidotu teikumu...', // "Добавьте карточки..." на лат.
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    )
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sentence.length,
                      itemBuilder: (context, index) {
                        final card = sentence[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 100,
                            child: Stack(
                              children: [
                                AacCard(card: card),
                                Positioned(
                                  top: -5,
                                  right: -5,
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 28),
                                    onPressed: () => ref.read(sentenceProvider.notifier).removeCard(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Правая часть: Блок с кнопками
                  SizedBox(
                    width: 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Кнопка: Произнести
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.campaign, size: 28), // Рупор
                            label: const Text('Izrunāt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            onPressed: () => _speakSentence(sentence),
                          ),
                        ),
                        // Кнопка: Удалить всё
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.red, width: 2),
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 28), // Мусорный бак
                            label: const Text('Dzēst visu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              ref.read(sentenceProvider.notifier).clearSentence();
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}