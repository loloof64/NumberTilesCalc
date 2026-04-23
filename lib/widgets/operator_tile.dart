import 'package:flutter/material.dart';
import 'package:number_tiles_calc/commons.dart';
import 'package:number_tiles_calc/core/operation.dart';

class OperatorTileWidget extends StatelessWidget {
  final Operator operator;
  final void Function() onClick;

  const OperatorTileWidget({
    super.key,
    required this.operator,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        width: 55,
        height: 40,
        child: Center(
          child: Text(
            operator.toString(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white.withAlpha(220),
            ),
          ),
        ),
      ),
    );
  }
}
