import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/aac_card_model.dart';
import '../services/database_helper.dart';
import 'categories_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardsLibraryNotifier extends AsyncNotifier<List<AacCardModel>> {
  @override
  Future<List<AacCardModel>> build() async {
    // ВАЖНО: Наблюдаем за авторизацией
    final authState = ref.watch(authStateProvider);

    final String response = await rootBundle.loadString('assets/data/cards.json');
    final List<dynamic> data = json.decode(response);
    final jsonCards = data.map((item) => AacCardModel.fromJson(item)).toList();

    // Загружаем из SQLite только если знаем email
    if (authState.hasValue && authState.value != null) {
      final dbCards = await DatabaseHelper.instance.getUserCards(authState.value!);
      final customCards = dbCards.map((map) => AacCardModel.fromMap(map)).toList();
      jsonCards.addAll(customCards);
    }

    return jsonCards;
  }

  Future<void> addCustomCard(AacCardModel newCard) async {
    // Читаем email напрямую из памяти
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');

    if (userEmail == null) return;

    final cardToSave = AacCardModel(
      id: newCard.id,
      label: newCard.label,
      category: newCard.category,
      imagePath: newCard.imagePath,
      isCustom: true,
      usageCount: 0,
      userId: userEmail,
    );

    try {
      await DatabaseHelper.instance.insertCard(cardToSave.toMap());
      if (state.hasValue) {
        state = AsyncData([...state.value!, cardToSave]);
      }
    } catch (e) {
      print('Ошибка SQLite при сохранении карточки: $e');
      rethrow;
    }
  }
}

final cardsLibraryProvider = AsyncNotifierProvider<CardsLibraryNotifier, List<AacCardModel>>(() {
  return CardsLibraryNotifier();
});

class SentenceNotifier extends Notifier<List<AacCardModel>> {
  @override
  List<AacCardModel> build() => [];
  void addCard(AacCardModel card) => state = [...state, card];
  void removeCard(int index) {
    final newState = [...state];
    newState.removeAt(index);
    state = newState;
  }
  void clearSentence() => state = [];
}

final sentenceProvider = NotifierProvider<SentenceNotifier, List<AacCardModel>>(() {
  return SentenceNotifier();
});