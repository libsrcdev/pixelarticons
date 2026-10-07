import 'package:pixelarticons_tool/src/font_generator.dart';
import 'package:test/test.dart';

void main() {
  test('identifiers retain lowercase naming and escape Dart keywords', () {
    expect(iconIdentifier('card-plus.svg'), 'cardplus');
    expect(iconIdentifier('4k.svg'), 'k4k');
    expect(iconIdentifier('switch.svg'), 'kswitch');
    expect(iconIdentifier('s-w-i-t-c-h.svg'), 'kswitch');
  });
}
