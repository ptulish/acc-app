import 'package:flutter/material.dart';

class AacCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;

  const AacCard({
    super.key,
    required this.text,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.white,
      elevation: 4, // Красивая тень
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Скругляем углы
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16), // Чтобы эффект нажатия тоже был скругленным
        onTap: () {
          // Здесь позже будет логика озвучки
          print('Нажали на карточку: $text');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Если иконка есть — показываем её
            if (icon != null)
              Icon(icon, size: 50, color: Colors.black87),

            const SizedBox(height: 12), // Отступ между картинкой и текстом

            // Текст карточки
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}