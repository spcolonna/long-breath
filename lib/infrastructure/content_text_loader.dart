import 'dart:convert';

import 'package:flutter/services.dart';

import '../delivery/content_text.dart';

/// Idioma de respaldo del contenido.
const contentFallbackLanguage = 'es';

/// Carga los textos del contenido para [language], con respaldo en español.
Future<ContentText> loadContentText(String language) async {
  Future<Map<String, dynamic>?> read(String lang) async {
    try {
      // Se decodifica acá: loadString pasa a otro isolate con más de 50 KB.
      final bytes = await rootBundle.load('assets/l10n/content/$lang.json');
      return jsonDecode(utf8.decode(bytes.buffer.asUint8List()))
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
