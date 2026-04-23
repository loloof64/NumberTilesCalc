import 'package:flutter/material.dart';

const fontSize = 22.0;
const solutionHeight = 200.0;
const solutionTextWidth = 150.0;

enum Operator {
  add,
  sub,
  mult,
  div;

  @override
  String toString() {
    return switch (this) {
      add => "+",
      sub => "-",
      mult => "*",
      div => "/",
    };
  }

  int applyTo(int operand1, int operand2) {
    return switch (this) {
      add => operand1 + operand2,
      sub => operand1 - operand2,
      mult => operand1 * operand2,
      div => operand1 / operand2,
    }.toInt();
  }

  bool isValidFor(int operand1, int operand2) {
    return switch (this) {
      add => true,
      mult => true,
      sub => operand2 >= operand1,
      div => (operand1 % operand2) == 0,
    };
  }
}

class Operation {
  final int operand1;
  final int operand2;
  final Operator operator;

  Operation({
    required this.operand1,
    required this.operand2,
    required this.operator,
  });

  @override
  String toString() {
    return "$operand1 $operator $operand2 = ${operator.applyTo(operand1, operand2)}";
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _target = 120;
  List<int> _tilesValues = <int>[75, 25, 10, 25, 3, 8];
  List<Operation> _operations = <Operation>[];

  @override
  Widget build(BuildContext context) {
    final numberTiles = _tilesValues
        .where((tile) => tile > 0)
        .map((tile) => NumberTile(value: tile, isTarget: false))
        .toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home"),
      ),
      body: Center(
        child: Column(
          spacing: 10.0,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NumberTile(value: _target, isTarget: true),
            Flexible(
              child: Row(
                spacing: 8.0,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: numberTiles,
              ),
            ),
            OperationsWidget(operations: _operations),
          ],
        ),
      ),
    );
  }
}

class NumberTile extends StatelessWidget {
  final bool isTarget;
  final int value;
  const NumberTile({super.key, required this.value, required this.isTarget});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isTarget
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      width: 55,
      height: 40,
      child: Center(
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.white.withAlpha(220),
          ),
        ),
      ),
    );
  }
}

class OperationsWidget extends StatelessWidget {
  final List<Operation> operations;
  const OperationsWidget({super.key, required this.operations});

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        color: Theme.of(context).colorScheme.tertiary,
        width: double.infinity,
        height: solutionHeight,
        child: Column(
          spacing: 8.0,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: lines,
        ),
      ),
    );
  }
}
