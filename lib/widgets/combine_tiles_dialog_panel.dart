import 'package:flutter/material.dart';
import 'package:number_tiles_calc/core/operation.dart';
import 'package:number_tiles_calc/widgets/number_tile.dart';
import 'package:number_tiles_calc/widgets/operator_tile.dart';

class CombineTilesDialogPanel extends StatefulWidget {
  final List<int> tilesValues;
  final int firstTileIndex;
  final double numberTilesSizeExtension;
  const CombineTilesDialogPanel({
    super.key,
    required this.tilesValues,
    required this.firstTileIndex,
    required this.numberTilesSizeExtension,
  });

  @override
  State<CombineTilesDialogPanel> createState() =>
      _CombineTilesDialogPanelState();
}

class _CombineTilesDialogPanelState extends State<CombineTilesDialogPanel> {
  Operator? _selectedOperator;

  void _updateOperator(Operator oper) {
    setState(() {
      _selectedOperator = oper;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstTileValue = widget.tilesValues[widget.firstTileIndex];

    final remainingTiles = widget.tilesValues
        .asMap()
        .entries
        .where((entry) => entry.key != widget.firstTileIndex)
        .map(
          (entry) => NumberTileWidget(
            value: entry.value,
            isTarget: false,
            sizeExtension: widget.numberTilesSizeExtension,
            onClick: () {
              if (_selectedOperator == null) return;
              final operation = Operation(
                operand1: widget.tilesValues[widget.firstTileIndex],
                operand2: entry.value,
                operator: _selectedOperator!,
              );
              if (!operation.isValid()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Result must be a positive integer !"),
                  ),
                );
                Navigator.of(context).pop(null);
                return;
              }
              Navigator.of(context).pop((operation, entry.key));
            },
          ),
        )
        .toList();

    final operators = Operator.values
        .map(
          (oper) => OperatorTileWidget(
            operator: oper,
            onClick: () => _updateOperator(oper),
          ),
        )
        .toList();

    return Row(
      spacing: 8.0,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberTileWidget(
                value: firstTileValue,
                isTarget: false,
                sizeExtension: widget.numberTilesSizeExtension,
                onClick: () {},
              ),
            ],
          ),
        ),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _selectedOperator == null
                ? operators
                : <Widget>[
                    OperatorTileWidget(
                      operator: _selectedOperator!,
                      onClick: () {},
                    ),
                  ],
          ),
        ),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: remainingTiles,
          ),
        ),
      ],
    );
  }
}
