import 'package:flutter_test/flutter_test.dart';
import 'package:aquaminity/screens/stats_screen.dart';

void main() {
  group('RankSystem', () {
    test('getRank returns COPPER IV for 0 meters', () {
      final rank = RankSystem.getRank(0);
      expect(rank.category, 'COPPER');
      expect(rank.subTier, 'IV');
    });

    test('getRank returns CHAMPION for high depth values', () {
      final rank = RankSystem.getRank(35000);
      expect(rank.category, 'CHAMPION');
      expect(rank.subTier, 'N1');
    });

    test('getRank returns correct tier boundaries', () {
      expect(RankSystem.getRank(800).category, 'COPPER');
      expect(RankSystem.getRank(800).subTier, '★');
      expect(RankSystem.getRank(2500).category, 'BRONZE');
      expect(RankSystem.getRank(7500).category, 'GOLD');
      expect(RankSystem.getRank(11000).category, 'PLATINUM');
      expect(RankSystem.getRank(22000).category, 'DIAMOND');
    });
  });
}
