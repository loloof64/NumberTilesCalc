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
      sub => operand1 >= operand2,
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

  int apply() => operator.applyTo(operand1, operand2);

  bool isValid() => operator.isValidFor(operand1, operand2);

  @override
  String toString() {
    return "$operand1 $operator $operand2 = ${operator.applyTo(operand1, operand2)}";
  }
}
