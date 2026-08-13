import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_settings.dart';
import 'core/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/settings/settings_screen.dart';

class FlickPadApp extends StatelessWidget {
  const FlickPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final useDynamic = settings.useDynamicColor && lightDynamic != null && darkDynamic != null;

        final lightScheme = useDynamic
            ? lightDynamic.harmonized()
            : AppTheme.fallbackScheme(settings.accentColor, Brightness.light);
        final darkScheme = useDynamic
            ? darkDynamic.harmonized()
            : AppTheme.fallbackScheme(settings.accentColor, Brightness.dark);

        return MaterialApp(
          title: 'FlickPad',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(lightScheme),
          darkTheme: AppTheme.build(darkScheme),
          themeMode: ThemeMode.system,
          home: const RootNav(),
        );
      },
    );
  }
}

// Bottom navigation shell holding the 4 main tabs
class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    FavoritesScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Favoris'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Recherche'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ),
    );
  }
}
