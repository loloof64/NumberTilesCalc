import 'package:flutter/material.dart';
import 'package:number_tiles_calc/commons.dart';

const width = 55.0;
const height = 40.0;

class NumberTileWidget extends StatelessWidget {
  final bool isTarget;
  final int value;
  final double sizeExtension;
  final void Function() onClick;

  const NumberTileWidget({
    super.key,
    required this.value,
    required this.isTarget,
    required this.sizeExtension,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        color: isTarget
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        width: width + sizeExtension,
        height: height,
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
      ),
    );
  }
}
