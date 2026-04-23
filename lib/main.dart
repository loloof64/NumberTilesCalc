import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';

const Color primarySeedColor = Color.fromARGB(255, 236, 10, 104);
const Color secondarySeedColor = Color(0xFF3871BB);
const Color tertiarySeedColor = Color(0xFF6CA450);

// Make a light ColorScheme from the seeds.
final ColorScheme schemeLight = SeedColorScheme.fromSeeds(
  brightness: Brightness.light,
  primaryKey: primarySeedColor,
  secondaryKey: secondarySeedColor,
  tertiaryKey: tertiarySeedColor,
  tones: FlexTones.vivid(Brightness.light),
);

// Make a dark ColorScheme from the same seed colors.
final ColorScheme schemeDark = SeedColorScheme.fromSeeds(
  brightness: Brightness.dark,
  primaryKey: primarySeedColor,
  secondaryKey: secondarySeedColor,
  tertiaryKey: tertiarySeedColor,
  tones: FlexTones.vivid(Brightness.dark),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Tiles Calc',
      themeMode: ThemeMode.system,
      theme: ThemeData(colorScheme: schemeLight),
      darkTheme: ThemeData(colorScheme: schemeDark),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home"),
      ),
      body: Center(child: Text("Hello, World !")),
    );
  }
}
