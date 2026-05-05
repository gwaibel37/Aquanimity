import 'package:flutter_test/flutter_test.dart';
import 'package:aquaminity/models/treasure.dart';

void main() {
  group('Treasure model', () {
    test('toMap and fromMap preserve treasure values', () {
      final treasure = Treasure(
        name: 'Golden Trident',
        rarity: Rarity.legendary,
        description: 'A powerful relic from the deep.',
      );

      final map = treasure.toMap();
      expect(map['name'], 'Golden Trident');
      expect(map['rarity'], 'legendary');
      expect(map['description'], 'A powerful relic from the deep.');

      final restored = Treasure.fromMap(map);
      expect(restored.name, treasure.name);
      expect(restored.rarity, treasure.rarity);
      expect(restored.description, treasure.description);
    });

    test('generate returns guaranteed highest rarity when requested', () {
      final treasure = Treasure.generate(950, guaranteedHighestInBracket: true);
      expect(
        treasure.rarity,
        anyOf(Rarity.mythic, Rarity.legendary, Rarity.epic),
      );
      expect(treasure.description, isNotEmpty);
    });

    test(
      'generate returns a valid treasure with a valid rarity for low depth',
      () {
        final treasure = Treasure.generate(100);
        expect(
          treasure.rarity,
          anyOf(
            Rarity.common,
            Rarity.uncommon,
            Rarity.rare,
            Rarity.epic,
            Rarity.legendary,
            Rarity.mythic,
          ),
        );
        expect(treasure.name, isNotEmpty);
        expect(treasure.description, isNotEmpty);
      },
    );
  });
}
