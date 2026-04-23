import 'package:number_tiles_calc/core/operation.dart';

class OptimalSolver {
  final int target;
  List<Operation>? bestSolution;
  int bestDepth = 999999;
  List<int> tiles;

  final Set<String> memo = {};

  OptimalSolver({required this.target, required this.tiles});

  List<Operation>? solve() {
    _dfs(tiles, []);
    return bestSolution;
  }

  void _dfs(List<int> nums, List<Operation> path) {
    // Early pruning by depth
    if (path.length >= bestDepth) return;

    // Check if target reached
    for (final n in nums) {
      if (n == target) {
        bestDepth = path.length;
        bestSolution = List.from(path);
        return;
      }
    }

    // Memoization key
    final sorted = List<int>.from(nums)..sort();
    final key = sorted.join(',');

    if (memo.contains(key)) return;
    memo.add(key);

    // Try all pairs
    for (int i = 0; i < nums.length; i++) {
      for (int j = i + 1; j < nums.length; j++) {
        final a = nums[i];
        final b = nums[j];

        final rest = <int>[];
        for (int k = 0; k < nums.length; k++) {
          if (k != i && k != j) rest.add(nums[k]);
        }

        for (final entry in _compute(a, b)) {
          final result = entry.$1;
          final op = entry.$2;

          final newNums = [...rest, result];

          if (op == Operator.add || op == Operator.mult) {
            path.add(Operation(operand1: a, operand2: b, operator: op));
          } else {
            if (a > b) {
              path.add(Operation(operand1: a, operand2: b, operator: op));
            } else {
              path.add(Operation(operand1: b, operand2: a, operator: op));
            }
          }
          _dfs(newNums, path);
          path.removeLast();
        }
      }
    }
  }

  List<(int, Operator)> _compute(int a, int b) {
    final results = <(int, Operator)>[];

    // Addition
    results.add((a + b, Operator.add));

    // Multiplication (skip useless)
    if (a != 1 && b != 1) {
      results.add((a * b, Operator.mult));
    }

    // Subtraction (positive only)
    if (a > b) {
      results.add((a - b, Operator.sub));
    } else if (b > a) {
      results.add((b - a, Operator.sub));
    }

    // Division (integer only)
    if (b != 0 && a % b == 0) {
      results.add((a ~/ b, Operator.div));
    }
    if (a != 0 && b % a == 0) {
      results.add((b ~/ a, Operator.div));
    }

    return results;
  }
}
