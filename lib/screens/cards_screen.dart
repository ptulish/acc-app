import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';
import '../services/local_card_service.dart';
import '../models/aac_card.dart';

class CardsScreen extends StatefulWidget {
  final String userEmail;

  const CardsScreen({super.key, required this.userEmail});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final _cardService = LocalCardService();
  List<AacCard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  // Загружаем карточки из базы
  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    final cards = await _cardService.getUserCards(widget.userEmail);
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
  }

  // Временная функция для быстрой генерации тестовых карточек
  Future<void> _addDummyCard() async {
    // Список для случайного выбора
    final dummyData = [
      {'title': 'Я хочу', 'emoji': '🫴'},
      {'title': 'Яблоко', 'emoji': '🍎'},
      {'title': 'Пить', 'emoji': '💧'},
      {'title': 'Да', 'emoji': '✅'},
      {'title': 'Нет', 'emoji': '❌'},
      {'title': 'Туалет', 'emoji': '🚽'},
    ];

    final randomItem = dummyData[_cards.length % dummyData.length];

    final newCard = AacCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Уникальный ID
      title: randomItem['title']!,
      emoji: randomItem['emoji']!,
      userEmail: widget.userEmail,
    );

    await _cardService.addCard(newCard);
    _loadCards(); // Перезагружаем список
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя доска'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCards, // Ручное обновление на всякий случай
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await LocalAuthService().signOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
          ? const Center(child: Text('У вас пока нет карточек. Добавьте первую!'))
      // GridView - идеален для плитки карточек
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5 колонок для горизонтального планшета
          childAspectRatio: 1.0, // Карточки будут квадратными
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return _buildCardWidget(card);
        },
      ),
      // Кнопка добавления в правом нижнем углу
      floatingActionButton: FloatingActionButton(
        onPressed: _addDummyCard,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Выносим визуал карточки в отдельный метод (позже вынесем в отдельный файл)
  Widget _buildCardWidget(AacCard card) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell( // Добавляем эффект нажатия
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Здесь позже мы добавим озвучку (TTS) карточки!
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Вы нажали: ${card.title}'), duration: const Duration(milliseconds: 500)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.emoji,
                style: const TextStyle(fontSize: 50),
              ),
              const SizedBox(height: 8),
              Text(
                card.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}