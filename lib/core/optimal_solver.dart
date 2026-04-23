import 'package:number_tiles_calc/core/operation.dart';

class OptimalSolver {
  final int target;
  final List<int> tiles;

  List<Operation>? bestSolution;
  int bestDepth = 999999;

  // Memo now stores the minimum depth seen for a state
  final Map<String, int> memo = {};

  OptimalSolver({required this.target, required this.tiles});

  List<Operation>? solve() {
    _dfs(tiles, []);
    return bestSolution;
  }

  void _dfs(List<int> nums, List<Operation> path) {
    // Prune by depth
    if (path.length >= bestDepth) return;

    // Check if target reached
    for (final n in nums) {
      if (n == target) {
        bestDepth = path.length;
        bestSolution = List.from(path);
        return;
      }
    }

    // Canonical state
    final sorted = List<int>.from(nums)..sort();
    final key = sorted.join(',');

    // Memo with depth check
    if (memo.containsKey(key) && memo[key]! <= path.length) {
      return;
    }
    memo[key] = path.length;

    // Explore pairs
    for (int i = 0; i < nums.length; i++) {
      for (int j = i + 1; j < nums.length; j++) {
        final a = nums[i];
        final b = nums[j];

        // Remaining tiles
        final rest = <int>[];
        for (int k = 0; k < nums.length; k++) {
          if (k != i && k != j) rest.add(nums[k]);
        }

        // Generate results
        for (final entry in _compute(a, b)) {
          final result = entry.$1;
          final opType = entry.$2;

          // Build correct operation (order matters for sub/div)
          late Operation op;

          if (opType == Operator.add || opType == Operator.mult) {
            op = Operation(operand1: a, operand2: b, operator: opType);
          } else {
            if (a > b) {
              op = Operation(operand1: a, operand2: b, operator: opType);
            } else {
              op = Operation(operand1: b, operand2: a, operator: opType);
            }
          }

          final newNums = [...rest, result];

          path.add(op);
          _dfs(newNums, path);
          path.removeLast();
        }
      }
    }
  }

  List<(int, Operator)> _compute(int a, int b) {
    final results = <(int, Operator)>[];

    // Addition (skip useless 0)
    if (a != 0 && b != 0) {
      results.add((a + b, Operator.add));
    }

    // Multiplication (skip useless 1)
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
