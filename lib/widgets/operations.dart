import 'package:flutter/material.dart';
import 'package:number_tiles_calc/commons.dart';
import 'package:number_tiles_calc/core/operation.dart';

const solutionHeight = 200.0;
final solutionTextWidth = 250.0;

class OperationsWidget extends StatelessWidget {
  final bool hasNoSolution;
  final List<Operation> operations;
  const OperationsWidget({
    super.key,
    required this.hasNoSolution,
    required this.operations,
  });

  @override
  Widget build(BuildContext context) {
    final lines = operations
        .map(
          (op) => SizedBox(
            width: solutionTextWidth,
            child: Text(
              op.toString(),
              style: TextStyle(
                color: Colors.white.withAlpha(220),
                fontSize: fontSize,
              ),
            ),
          ),
        )
        .toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          color: hasNoSolution
              ? Colors.red
              : Theme.of(context).colorScheme.tertiary,
          width: double.infinity,
          height: solutionHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...lines,
              if (hasNoSolution)
                Text(
                  "No solution !",
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
