import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_helper.dart';
import '../services/local_auth_service.dart';

// --- 1. Провайдер состояния авторизации ---
final authStateProvider = StreamProvider<String?>((ref) {
  return LocalAuthService().onAuthStateChanged;
});

// --- 2. Модель Категории ---
class AacCategory {
  final String id;
  final String label;
  final Color color;
  final bool isCustom;
  final String? userId;

  AacCategory(this.id, this.label, this.color, {this.isCustom = false, this.userId});

  factory AacCategory.fromMap(Map<String, dynamic> map) {
    return AacCategory(
      map['id'] as String,
      map['label'] as String,
      Color(map['color'] as int),
      isCustom: (map['is_custom'] as int) == 1,
      userId: map['user_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'color': color.value,
      'is_custom': isCustom ? 1 : 0,
      'user_id': userId,
    };
  }
}

final initialCategories = [
  AacCategory('Food', 'ĒDIENS', Colors.orange),
  AacCategory('Actions', 'DARBĪBAS', Colors.green),
  AacCategory('Needs', 'VAJADZĪBAS', Colors.red),
  AacCategory('People', 'CILVĒKI', Colors.purple),
  AacCategory('Emotions', 'EMOCIJAS', Colors.yellow.shade700),
  AacCategory('Places', 'VIETAS', Colors.blue),
  AacCategory('Numbers', 'CIPARI', Colors.lightBlue),
  AacCategory('Alphabet', 'BURTI', Colors.white),
  AacCategory('Frequently Used', 'BIEŽĀK IZMANTOTIE', Colors.pinkAccent),
];

// --- 3. Провайдер Категорий ---
class CategoriesNotifier extends Notifier<List<AacCategory>> {
  @override
  List<AacCategory> build() {
    // ВАЖНО: Теперь мы жестко наблюдаем за авторизацией
    final authState = ref.watch(authStateProvider);

    // Если данные авторизации загрузились и email не пустой, идем в БД
    if (authState.hasValue && authState.value != null) {
      _loadUserCategories(authState.value!);
    }

    return initialCategories;
  }

  Future<void> _loadUserCategories(String email) async {
    final dbCategories = await DatabaseHelper.instance.getUserCategories(email);
    if (dbCategories.isNotEmpty) {
      final customCategories = dbCategories.map((m) => AacCategory.fromMap(m)).toList();
      state = [...initialCategories, ...customCategories];
    }
  }

  Future<void> addCategory(AacCategory category) async {
    // Теперь email точно будет известен
    final userEmail = ref.read(authStateProvider).value;

    // Защита: если юзера нет, ничего не делаем (чтобы не сломать БД)
    if (userEmail == null) return;

    final newCat = AacCategory(
      category.id,
      category.label,
      category.color,
      isCustom: true,
      userId: userEmail,
    );

    await DatabaseHelper.instance.insertCategory(newCat.toMap());
    state = [...state, newCat];
  }
}

final categoriesProvider = NotifierProvider<CategoriesNotifier, List<AacCategory>>(() {
  return CategoriesNotifier();
});