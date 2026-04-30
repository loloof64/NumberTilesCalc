import 'dart:async';

import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:number_tiles_calc/core/complete_user_solution.dart';
import 'package:number_tiles_calc/core/game_generator.dart';
import 'package:number_tiles_calc/core/operation.dart';
import 'package:number_tiles_calc/core/optimal_solver.dart';
import 'package:number_tiles_calc/widgets/combine_tiles_dialog_panel.dart';
import 'package:number_tiles_calc/widgets/exercise_solution.dart';
import 'package:number_tiles_calc/widgets/number_tile.dart';
import 'package:number_tiles_calc/widgets/operations.dart';
import 'package:number_tiles_calc/i18n/strings.g.dart';

const numberTilesExtensionPerStep = 15.3;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _hasWon = false;
  bool _isSolved = false;
  bool _targetReached = false;
  final GameGenerator _gameGenerator = GameGenerator();
  int _target = 0;
  List<int> _startTilesValues = <int>[];
  List<int> _tilesValues = [];
  List<Operation> _operations = <Operation>[];
  List<Operation>? _solution = <Operation>[];
  List<Operation>? _completedSolution = <Operation>[];
  double _numberTilesExtension = 0.0;

  // Timer: null = disabled, otherwise duration in seconds (1–120)
  int? _timerSeconds;
  int _remainingSeconds = 0;
  Timer? _countdownTimer;

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
    _startNewGame();
    super.initState();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    if (_timerSeconds == null) return;
    setState(() {
      _remainingSeconds = _timerSeconds!;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        _onTimerExpired();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _onTimerExpired() {
    _solve();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.pages.home.timer.time_up)),
    );
  }

  void _startNewGame() {
    _stopTimer();
    final (target, tiles) = _gameGenerator.generate();
    setState(() {
      _hasWon = false;
      _operations = [];
      _solution = [];
      _completedSolution = [];
      _numberTilesExtension = 0;
      _startTilesValues = tiles.map((c) => c).toList();
      _tilesValues = tiles.map((c) => c).toList();
      _target = target;
      _isSolved = false;
      _targetReached = false;
    });
    _startTimer();
  }

  void _solve() {
    _stopTimer();
    OptimalSolver solver = OptimalSolver(
      target: _target,
      tiles: _startTilesValues,
    );
    final solution = solver.solve();
    final completedSolution = completeSolution(
      targetValue: _target,
      setOperations: _operations,
      remainingTiles: _tilesValues,
    );
    setState(() {
      _solution = solution;
      _completedSolution = completedSolution;
      _isSolved = true;
    });
  }

  void _clearContent() {
    setState(() {
      _tilesValues = _startTilesValues.where((c) => true).toList();
      _operations.clear();
      _numberTilesExtension = 0;
    });
  }

  Future<void> _showTimerSettings() async {
    bool enabled = _timerSeconds != null;
    int sliderValue = _timerSeconds ?? 60;

    final result = await showDialog<(bool, int)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(t.pages.home.timer.set_timer),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.pages.home.timer.enable),
                    Switch(
                      value: enabled,
                      onChanged: (value) {
                        setDialogState(() => enabled = value);
                      },
                    ),
                  ],
                ),
                if (enabled) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(sliderValue),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    min: 1,
                    max: 120,
                    divisions: 119,
                    value: sliderValue.toDouble(),
                    label: _formatTime(sliderValue),
                    onChanged: (value) {
                      setDialogState(() => sliderValue = value.round());
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('00:01'),
                      Text('02:00'),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop((enabled, sliderValue)),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          );
        },
      ),
    );

    // Traitement après fermeture complète du dialogue
    if (result != null) {
      final newSeconds = result.$1 ? result.$2 : null;
      setState(() => _timerSeconds = newSeconds);
      if (newSeconds == null) {
        _stopTimer();
      } else if (!_isSolved) {
        _startTimer();
      }
    }
  }

  Future<void> _startTilesCombination(int index) async {
    if (_targetReached) return;
    if (_tilesValues.length < 2) return;
    final result = await Navigator.of(context).push<(Operation, int)>(
      MaterialPageRoute(
        builder: (context2) {
          return AlertDialog(
            title: Text(t.pages.home.title),
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
        setState(() {
          _hasWon = true;
        });
        _solve();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.pages.home.misc.you_won)));
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
        title: Text(t.pages.home.title),
        actions: [
          if (!_isSolved && _timerSeconds != null)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Center(
                child: Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _remainingSeconds <= 10
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: _showTimerSettings,
            tooltip: t.pages.home.timer.set_timer,
          ),
        ],
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
                    operations: _operations,
                    hasNoSolution: false,
                  )
                : Flexible(
                    child: ExerciseSolutionTabs(
                      hasWon: _hasWon,
                      optimalSolution: _solution,
                      userStartSolution: _operations,
                      completedSolution: _completedSolution,
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
              title: t.pages.home.fab.clear,
              titleStyle: TextStyle(color: Colors.white),
              bubbleColor: Colors.red,
              onPress: _clearContent,
            ),
          if (!_isSolved)
            Bubble(
              icon: Icons.calculate,
              iconColor: Colors.white,
              title: t.pages.home.fab.solve,
              titleStyle: TextStyle(color: Colors.white),
              bubbleColor: Colors.green,
              onPress: _solve,
            ),
          if (_isSolved)
            Bubble(
              icon: Icons.games_outlined,
              iconColor: Colors.white,
              title: t.pages.home.fab.new_game,
              titleStyle: TextStyle(color: Colors.white),
              bubbleColor: Colors.blueAccent,
              onPress: _startNewGame,
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
