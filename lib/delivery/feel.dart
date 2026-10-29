import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias de "feel" de todo el juego (no de cada partida): cuánto se
/// mueve la pantalla y si el teléfono vibra.
///
/// El movimiento se aplica pisando `MediaQuery.disableAnimations` en la raíz
/// (ver [MotionScope]), así cada pieza animada solo tiene que preguntar
/// `MediaQuery.disableAnimationsOf(context)` (o usar [calm]).

/// Cuánto movimiento se muestra.
enum MotionPref {
  /// Lo que diga el ajuste del sistema.
  system,

  /// Todo el movimiento, aunque el sistema pida reducirlo.
  full,

  /// Sin sacudidas, partículas ni loops: las cosas aparecen y listo.
  reduced,
}

class FeelSettings {
  const FeelSettings({this.motion = MotionPref.system, this.haptics = true});

  final MotionPref motion;
  final bool haptics;

  FeelSettings copyWith({MotionPref? motion, bool? haptics}) => FeelSettings(
    motion: motion ?? this.motion,
    haptics: haptics ?? this.haptics,
  );

  static const _motionKey = 'long_breath.motion';
  static const _hapticsKey = 'long_breath.haptics';

  static FeelSettings read(SharedPreferences p) => FeelSettings(
    motion:
        MotionPref.values.asNameMap()[p.getString(_motionKey)] ??
        MotionPref.system,
    haptics: p.getBool(_hapticsKey) ?? true,
  );

  Future<void> write() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_motionKey, motion.name);
      await p.setBool(_hapticsKey, haptics);
    } catch (e) {
      debugPrint('feel: $e');
    }
  }
}

/// En `main` se reemplaza por lo guardado; en tests queda el valor de fábrica.
final initialFeelProvider = Provider<FeelSettings>(
  (ref) => const FeelSettings(),
);

final feelProvider = NotifierProvider<FeelNotifier, FeelSettings>(
  FeelNotifier.new,
);

class FeelNotifier extends Notifier<FeelSettings> {
  @override
  FeelSettings build() {
    final s = ref.watch(initialFeelProvider);
    Haptics.enabled = s.haptics;
    return s;
  }

  void set(FeelSettings s) {
    state = s;
    Haptics.enabled = s.haptics;
    s.write();
  }
}

/// Aplica la preferencia de movimiento a todo lo que cuelga de [child].
class MotionScope extends ConsumerWidget {
  const MotionScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = ref.watch(feelProvider.select((s) => s.motion));
    if (motion == MotionPref.system) return child;
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(disableAnimations: motion == MotionPref.reduced),
      child: child,
    );
  }
}

/// Atajo: ¿hay que evitar el movimiento decorativo acá?
bool calm(BuildContext context) => MediaQuery.disableAnimationsOf(context);

/// Vibración de todo el juego. Mismos nombres que [HapticFeedback], pero
/// respeta el ajuste "Vibración" de Opciones.
abstract final class Haptics {
  static bool enabled = true;

  static Future<void> selectionClick() =>
      enabled ? HapticFeedback.selectionClick() : Future.value();
  static Future<void> lightImpact() =>
      enabled ? HapticFeedback.lightImpact() : Future.value();
  static Future<void> mediumImpact() =>
      enabled ? HapticFeedback.mediumImpact() : Future.value();
  static Future<void> heavyImpact() =>
      enabled ? HapticFeedback.heavyImpact() : Future.value();
}

/// Arranca o frena un loop decorativo (respirar, flotar, niebla) según el
/// movimiento pedido. Va en `didChangeDependencies`, en lugar de `repeat()`.
void loopUnlessCalm(
  BuildContext context,
  AnimationController c, {
  bool reverse = false,
}) {
  if (calm(context)) {
    c.stop();
  } else if (!c.isAnimating) {
    c.repeat(reverse: reverse);
  }
}
