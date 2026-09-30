import 'package:flutter/widgets.dart';

/// Marca una zona de la pantalla para que el tutorial pueda resaltarla.
class TutorialAnchor extends StatefulWidget {
  const TutorialAnchor({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  static final _keys = <String, GlobalKey>{};

  /// Rectángulo de la zona [id] en coordenadas de [ancestor], si está en pantalla.
  static Rect? rectOf(String id, RenderBox ancestor) {
    final box = _keys[id]?.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;
  }

  @override
  State<TutorialAnchor> createState() => _TutorialAnchorState();
}

class _TutorialAnchorState extends State<TutorialAnchor> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    TutorialAnchor._keys[widget.id] = _key;
  }

  @override
  void didUpdateWidget(TutorialAnchor old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      _forget(old.id);
      TutorialAnchor._keys[widget.id] = _key;
    }
  }

  @override
  void dispose() {
    _forget(widget.id);
    super.dispose();
  }

  void _forget(String id) {
    if (TutorialAnchor._keys[id] == _key) TutorialAnchor._keys.remove(id);
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(key: _key, child: widget.child);
}
