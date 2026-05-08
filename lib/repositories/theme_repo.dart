import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeRepository {
  final Box box = Hive.box('theme');

  ThemeRepository();

  ThemeMode getTheme() {
    final saved = box.get('mode');
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveTheme(ThemeMode mode) async {
    await box.put('mode', mode.name);
  }
}
