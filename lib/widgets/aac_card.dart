import 'package:flutter/material.dart';
import '../models/aac_card_model.dart';

class AacCard extends StatelessWidget {
  final AacCardModel card;
  final VoidCallback? onTap; // Callback для нажатия (добавление в строку)

  const AacCard({
    super.key,
    required this.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Четкая граница помогает с фокусировкой внимания (важно для AAC)
          side: BorderSide(color: Colors.blue.shade200, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Картинка карточки
              Expanded(
                flex: 3,
                child: Center(
                  child: card.imagePath.length < 4 // Простая проверка: если строка короткая, значит это эмодзи
                      ? Text(
                    card.imagePath,
                    style: const TextStyle(fontSize: 50), // Размер эмодзи
                  )
                      : Image.asset(
                    card.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Текст карточки
              Expanded(
                flex: 1,
                child: Text(
                  card.label,
                  style: const TextStyle(
                    fontSize: 16, // Крупный и читаемый шрифт
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // Защита от слишком длинного текста
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}