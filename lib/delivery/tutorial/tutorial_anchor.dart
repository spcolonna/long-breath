import 'package:flutter/widgets.dart';

/// Marca una zona de la pantalla para que el tutorial pueda resaltarla.
class TutorialAnchor extends StatefulWidget {
  const TutorialAnchor({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  /// Varias zonas pueden compartir id (dos copias de una carta): se usa la
  /// última que sigue en pantalla.
  static final _keys = <String, List<GlobalKey>>{};

  /// Rectángulo de la zona [id] en coordenadas de [ancestor], si está en pantalla.
  static Rect? rectOf(String id, RenderBox ancestor) {
    for (final key in (_keys[id] ?? const <GlobalKey>[]).reversed) {
      final box = key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      return box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;
    }
    return null;
  }

  @override
  State<TutorialAnchor> createState() => _TutorialAnchorState();
}

class _TutorialAnchorState extends State<TutorialAnchor> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _remember(widget.id);
  }

  @override
  void didUpdateWidget(TutorialAnchor old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      _forget(old.id);
      _remember(widget.id);
    }
  }

  @override
  void dispose() {
    _forget(widget.id);
    super.dispose();
  }

  void _remember(String id) => (TutorialAnchor._keys[id] ??= []).add(_key);

  void _forget(String id) {
    final keys = TutorialAnchor._keys[id]?..remove(_key);
    if (keys != null && keys.isEmpty) TutorialAnchor._keys.remove(id);
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(key: _key, child: widget.child);
}
