import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:number_tiles_calc/core/complete_user_solution.dart';
import 'package:number_tiles_calc/core/operation.dart';
import 'package:number_tiles_calc/core/optimal_solver.dart';
import 'package:number_tiles_calc/widgets/combine_tiles_dialog_panel.dart';
import 'package:number_tiles_calc/widgets/exercise_solution.dart';
import 'package:number_tiles_calc/widgets/number_tile.dart';
import 'package:number_tiles_calc/widgets/operations.dart';

const numberTilesExtensionPerStep = 15.3;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _isSolved = false;
  bool _targetReached = false;
  int _target = 997;
  List<int> _startTilesValues = <int>[25, 25, 10, 25, 3, 8];
  List<int> _tilesValues = [];
  List<Operation>? _operations = <Operation>[];
  List<Operation>? _solution = <Operation>[];
  double _numberTilesExtension = 0.0;

  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _animationController,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    _tilesValues = _startTilesValues.where((c) => true).toList();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _solve() {
    OptimalSolver solver = OptimalSolver(
      target: _target,
      tiles: _startTilesValues,
    );
    final solution = solver.solve();
    final newOperationsState = completeSolution(
      targetValue: _target,
      setOperations: _operations ?? [],
      remainingTiles: _tilesValues,
    );
    setState(() {
      _solution = solution;
      _operations = newOperationsState;
      _isSolved = true;
    });
  }

  void _clearContent() {
    setState(() {
      _tilesValues = _startTilesValues.where((c) => true).toList();
      _operations?.clear();
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
        _operations?.add(result.$1);
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
            !_isSolved
                ? OperationsWidget(
                    operations: _operations ?? [],
                    hasNoSolution: false,
                  )
                : Flexible(
                    child: ExerciseSolutionTabs(
                      optimalSolution: _solution,
                      completedSolution: _operations,
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          if (!_isSolved)
            Bubble(
              icon: Icons.delete,
              iconColor: Colors.white,
              title: "Clear",
              titleStyle: TextStyle(color: Colors.white),
              bubbleColor: Colors.red,
              onPress: _clearContent,
            ),
          if (!_isSolved)
            Bubble(
              icon: Icons.calculate,
              iconColor: Colors.white,
              title: "Solve",
              titleStyle: TextStyle(color: Colors.white),
              bubbleColor: Colors.green,
              onPress: _solve,
            ),
        ],
        iconData: Icons.ac_unit,
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        iconColor: Colors.white,
        backGroundColor: Colors.blueAccent,
        animation: _animation,
      ),
    );
  }
}
