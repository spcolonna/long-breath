import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/run/ghost.dart';
import '../l10n/app_localizations.dart';
import 'controllers/run_controller.dart';
import 'providers.dart';

/// Nombre de un rival en la subida: el Discípulo Perdido lleva el número
/// del caído cuya cinta lleva.
extension FoeName on WidgetRef {
  String foe(BuildContext context, String id) {
    final g = read(runControllerProvider)?.ghost;
    return id == ghostEnemy && g != null
        ? AppLocalizations.of(context).ghostName(g.n)
        : read(textProvider).enemy(id);
  }
}
