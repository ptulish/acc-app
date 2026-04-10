class AacCardModel {
  final String id;
  final String label;
  final String category;
  final String imagePath;
  final String? audioPath;
  final bool isCustom;
  final int usageCount;
  final String? userId; // <-- ДОБАВЛЕНО: Привязка к пользователю

  AacCardModel({
    required this.id,
    required this.label,
    required this.category,
    required this.imagePath,
    this.audioPath,
    this.isCustom = false,
    this.usageCount = 0,
    this.userId,
  });

  // Чтение из JSON (дефолтные карточки)
  factory AacCardModel.fromJson(Map<String, dynamic> json) {
    return AacCardModel(
      id: json['id'] as String,
      label: json['label'] as String,
      category: json['category'] as String,
      imagePath: json['image_path'] as String,
      audioPath: json['audio_path'] as String?,
      isCustom: json['is_custom'] as bool? ?? false,
      usageCount: json['usage_count'] as int? ?? 0,
      userId: json['user_id'] as String?,
    );
  }

  // ==========================================
  // ДОБАВЛЕНО: МЕТОДЫ ДЛЯ РАБОТЫ СО SQLITE
  // ==========================================

  factory AacCardModel.fromMap(Map<String, dynamic> map) {
    return AacCardModel(
      id: map['id'] as String,
      label: map['label'] as String,
      category: map['category_id'] as String, // В БД колонка называется category_id
      imagePath: map['image_path'] as String,
      isCustom: (map['is_custom'] as int) == 1, // В SQLite нет bool, там 0 и 1
      usageCount: map['usage_count'] as int,
      userId: map['user_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'category_id': category,
      'image_path': imagePath,
      'is_custom': isCustom ? 1 : 0,
      'usage_count': usageCount,
      'user_id': userId,
    };
  }
}