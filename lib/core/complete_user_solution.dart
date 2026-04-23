import 'package:number_tiles_calc/core/operation.dart';
import 'package:number_tiles_calc/core/optimal_solver.dart';

List<Operation>? completeSolution({
  required int targetValue,
  required List<Operation> setOperations,
  required List<int> remainingTiles,
}) {
  // If user already reached the target → nothing to add
  if (remainingTiles.contains(targetValue)) {
    return setOperations;
  }

  final solver = OptimalSolver(
    target: targetValue,
    tiles: List.from(remainingTiles),
  );

  final completion = solver.solve();

  if (completion == null) {
    // No exact solution possible → you can decide what to do later
    return null;
  }

  // Merge user operations + computed completion
  return [...setOperations, ...completion];
}
