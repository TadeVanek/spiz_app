import 'package:flutter_test/flutter_test.dart';
import 'package:spiz_app/models/food_item.dart';

void main() {
  test('czPlural správně skloňuje', () {
    expect(czPlural(1, 'den', 'dny', 'dní'), 'den');
    expect(czPlural(3, 'den', 'dny', 'dní'), 'dny');
    expect(czPlural(5, 'den', 'dny', 'dní'), 'dní');
    expect(czPlural(0, 'den', 'dny', 'dní'), 'dní');
  });
}
