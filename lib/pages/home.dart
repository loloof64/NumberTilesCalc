import 'package:flutter/material.dart';
import 'package:number_tiles_calc/core/operation.dart';
import 'package:number_tiles_calc/widgets/combine_tiles_dialog_panel.dart';
import 'package:number_tiles_calc/widgets/number_tile.dart';
import 'package:number_tiles_calc/widgets/operations.dart';

const numberTilesExtensionPerStep = 15.3;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _targetReached = false;
  int _target = 120;
  List<int> _startTilesValues = <int>[75, 25, 10, 25, 3, 8];
  List<int> _tilesValues = [];
  List<Operation> _operations = <Operation>[];
  double _numberTilesExtension = 0.0;

  @override
  void initState() {
    super.initState();
    _tilesValues = _startTilesValues.where((c) => true).toList();
  }

  void _clearContent() {
    setState(() {
      _tilesValues = _startTilesValues.where((c) => true).toList();
      _operations.clear();
      _numberTilesExtension = 0;
    });
  }

  Future<void> _startTilesCombination(int index) async {
    if (_targetReached) return;
    if (_tilesValues.length < 2) return;
    final result = await Navigator.of(context).push<(Operation, int)>(
      MaterialPageRoute(
        builder: (context2) {
          return AlertDialog(
            title: Text("Make your operation"),
            content: CombineTilesDialogPanel(
              tilesValues: _tilesValues,
              firstTileIndex: index,
              numberTilesSizeExtension: _numberTilesExtension,
            ),
          );
        },
      ),
    );

    if (result != null) {
      setState(() {
        _operations.add(result.$1);
        _tilesValues[index] = result.$1.apply();
        _tilesValues.removeAt(result.$2);
        _numberTilesExtension += numberTilesExtensionPerStep;
      });
      if (_isWon()) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("You won !")));
        setState(() {
          _targetReached = true;
        });
      }
    }
  }

  bool _isWon() => _tilesValues.contains(_target);

  @override
  Widget build(BuildContext context) {
    final tilesWidgets = _tilesValues
        .where((tile) => tile > 0)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => NumberTileWidget(
            value: entry.value,
            isTarget: false,
            sizeExtension: _numberTilesExtension,
            onClick: () => _startTilesCombination(entry.key),
          ),
        )
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
            NumberTileWidget(
              value: _target,
              isTarget: true,
              sizeExtension: 0,
              onClick: () {},
            ),
            Flexible(
              child: Row(
                spacing: 8.0,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: tilesWidgets,
              ),
            ),
            OperationsWidget(operations: _operations),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearContent,
        child: Icon(Icons.delete),
      ),
    );
  }
}
