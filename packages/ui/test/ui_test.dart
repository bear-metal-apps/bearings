import 'package:flutter_test/flutter_test.dart';

import 'package:ui/ui.dart';

void main() {
  test('exports shared widget types', () {
    expect(TextDivider.new, isNotNull);
    expect(TileableCard.new, isNotNull);
    expect(TileableCardView.new, isNotNull);
  });
}
