import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/diary_screen.dart';
import 'ui/screens/food_search_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/widgets/pixel_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const GeidaApp(),
    ),
  );
}

class GeidaApp extends StatelessWidget {
  const GeidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geida - Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routes: {
        '/home': (_) => const HomeShell(),
      },
      home: Consumer<AppState>(
        builder: (context, state, _) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentGreen,
                ),
              ),
            );
          }
          if (!state.hasProfile) {
            return const Scaffold(
              body: ProfileScreen(isFirstSetup: true),
            );
          }
          return const HomeShell();
        },
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    FoodSearchScreen(),
    DiaryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: PixelNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
