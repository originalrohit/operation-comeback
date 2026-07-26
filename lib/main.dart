import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/notes_screen.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Warm up the database on launch so first screen loads instantly.
  await DatabaseHelper.instance.database;
  runApp(const OperationComebackApp());
}

class OperationComebackApp extends StatefulWidget {
  const OperationComebackApp({super.key});

  @override
  State<OperationComebackApp> createState() => _OperationComebackAppState();
}

class _OperationComebackAppState extends State<OperationComebackApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Operation Comeback',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: RootShell(onToggleTheme: toggleTheme),
    );
  }
}

class RootShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const RootShell({super.key, required this.onToggleTheme});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  late final List<Widget> _screens = [
    DashboardScreen(onToggleTheme: widget.onToggleTheme),
    const HabitsScreen(),
    const JournalScreen(),
    const NotesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(Icons.check_circle),
              label: 'Habits'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Journal'),
          NavigationDestination(
              icon: Icon(Icons.note_outlined),
              selectedIcon: Icon(Icons.note),
              label: 'Notes'),
        ],
      ),
    );
  }
}
