import 'dart:convert';

import 'package:flutter/services.dart';

import '../delivery/content_text.dart';

/// Idioma de respaldo del contenido.
const contentFallbackLanguage = 'es';

/// Carga los textos del contenido para [language], con respaldo en español.
Future<ContentText> loadContentText(String language) async {
  Future<Map<String, dynamic>?> read(String lang) async {
    try {
      return jsonDecode(
              await rootBundle.loadString('assets/l10n/content/$lang.json'))
          as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  final fallback = ContentText((await read(contentFallbackLanguage))!);
  if (language == contentFallbackLanguage) return fallback;
  final data = await read(language);
  return data == null ? fallback : ContentText(data, fallback);
}
