import 'package:flutter/material.dart';
import 'package:number_tiles_calc/core/operation.dart';
import 'package:number_tiles_calc/widgets/operations.dart';
import 'package:number_tiles_calc/i18n/strings.g.dart';

class ExerciseSolutionTabs extends StatelessWidget {
  final bool hasWon;
  final List<Operation>? optimalSolution;
  final List<Operation> userStartSolution;
  final List<Operation>? completedSolution;

  const ExerciseSolutionTabs({
    super.key,
    required this.hasWon,
    required this.optimalSolution,
    required this.userStartSolution,
    required this.completedSolution,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: t.widgets.exercise_solution.optimal),
              Tab(
                text: hasWon
                    ? t.widgets.exercise_solution.your_solution
                    : t.widgets.exercise_solution.completed,
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                (optimalSolution == null)
                    ? OperationsWidget(operations: [], hasNoSolution: true)
                    : OperationsWidget(
                        operations: optimalSolution!,
                        hasNoSolution: false,
                      ),
                OperationsWidget(
                  operations: completedSolution ?? userStartSolution,
                  hasNoSolution: completedSolution == null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
