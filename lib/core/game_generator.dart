import 'dart:math';

class GameGenerator {
  final Random _random = Random();
  final TileGenerator _tileGenerator = TileGenerator();

  int target = 0;
  List<int> tiles = [];

  (int, List<int>) generate() {
    final bigTileCount = _random.nextInt(5);
    final tiles = _tileGenerator.generateTiles(bigTileCount);
    final target = _random.nextInt(999) + 1;
    return (target, tiles);
  }
}

class TileGenerator {
  final Random _random = Random();

  List<int> generateTiles(int bigCount) {
    assert(bigCount >= 0 && bigCount <= 4);

    // Big tiles (unique)
    final bigTiles = [25, 50, 75, 100]..shuffle(_random);

    // Small tiles (each twice)
    final smallPool = <int>[];
    for (int i = 1; i <= 9; i++) {
      smallPool.add(i);
      smallPool.add(i);
    }
    smallPool.shuffle(_random);

    final result = <int>[];

    // Pick big tiles
    result.addAll(bigTiles.take(bigCount));

    // Pick small tiles
    result.addAll(smallPool.take(6 - bigCount));

    result.shuffle(_random);

    return result;
  }
}
