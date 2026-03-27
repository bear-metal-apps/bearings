import 'package:flutter/material.dart';

LinearGradient pawfinderPageGradient(BuildContext context, {bool vivid = false}) {
  final scheme = Theme.of(context).colorScheme;
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      scheme.primaryContainer.withValues(alpha: vivid ? 0.30 : 0.22),
      scheme.surface,
      scheme.tertiaryContainer.withValues(alpha: vivid ? 0.24 : 0.14),
    ],
  );
}

Widget pawfinderGradientBackground({
  required BuildContext context,
  required Widget child,
  bool vivid = false,
}) {
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: pawfinderPageGradient(context, vivid: vivid),
    ),
    child: child,
  );
}

Widget pawfinderAppBarFlexibleSpace(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          scheme.primaryContainer.withValues(alpha: 0.85),
          scheme.surface.withValues(alpha: 0.92),
          scheme.secondaryContainer.withValues(alpha: 0.72),
        ],
      ),
    ),
  );
}
