class AacCard {
  final String id;
  final String title; // Текст (например, "Я хочу", "Пить")
  final String emoji; // Пиктограмма (пока используем эмодзи)
  final String userEmail; // К какому пользователю привязана карточка

  AacCard({
    required this.id,
    required this.title,
    required this.emoji,
    required this.userEmail,
  });

  // Превращаем объект в Map (JSON) для сохранения в базу
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'userEmail': userEmail,
    };
  }

  // Создаем объект из Map (при загрузке из базы)
  factory AacCard.fromMap(Map<String, dynamic> map) {
    return AacCard(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      emoji: map['emoji'] ?? '',
      userEmail: map['userEmail'] ?? '',
    );
  }
}