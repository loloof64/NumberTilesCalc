import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int> _tilesValues = <int>[0, 120, 3, 1, 25, 75];

  @override
  Widget build(BuildContext context) {
    final numberTiles = _tilesValues
        .where((tile) => tile > 0)
        .map((tile) => NumberTile(value: tile))
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
            Flexible(
              child: Row(
                spacing: 8.0,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: numberTiles,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberTile extends StatelessWidget {
  final int value;
  const NumberTile({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      width: 55,
      height: 40,
      child: Center(
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w900,
            color: Colors.white.withAlpha(220),
          ),
        ),
      ),
    );
  }
}
