import 'package:flutter/material.dart';
import 'package:number_tiles_calc/core/operation.dart';
import 'package:number_tiles_calc/widgets/operations.dart';

class ExerciseSolutionTabs extends StatelessWidget {
  final List<Operation>? optimalSolution;
  final List<Operation> completedSolution;

  const ExerciseSolutionTabs({
    super.key,
    required this.optimalSolution,
    required this.completedSolution,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Optimal solution'),
              Tab(text: 'Completed solution'),
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
                  operations: completedSolution,
                  hasNoSolution: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
