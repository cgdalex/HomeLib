import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'providers/book_collection_provider.dart';
import 'providers/library_provider.dart';

Future<void> main() async {
  // Makes sure Flutter is ready before loading the .env file.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Loads the API key from the .env file.
    await dotenv.load(fileName: '.env');
  } catch (error) {
    // If .env fails to load, the app will still open.
    // This helps prevent a blank screen during testing.
    debugPrint('Could not load .env file: $error');
  }

  runApp(
    // MultiProvider lets the app use more than one provider at the same time.
    MultiProvider(
      providers: [
        // This provider controls the search-page add/checkmark behavior.
        ChangeNotifierProvider(
          create: (context) => BookCollectionProvider(),
        ),

        // This provider controls the main library and wish list.
        ChangeNotifierProvider(
          create: (context) => LibraryProvider(),
        ),
      ],
      child: const HomeLibApp(),
    ),
  );
}

class HomeLibApp extends StatelessWidget {
  const HomeLibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLIB',
      debugShowCheckedModeBanner: false,

      // Dark Plex-style global theme.
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101010),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101010),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Starts the app on the navigation wrapper.
      home: const MainNavigation(),
    );
  }
}

// This widget handles switching between the Search screen and Library screen.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Tracks which page is currently selected.
  // 0 = Search page
  // 1 = My Library page
  int _selectedIndex = 0;

  // These are the screens that the sidebar switches between.
  final List<Widget> _pages = [
    const HomeScreen(),
    const LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),

      // Row places the sidebar navigation and main content side by side.
      body: Row(
        children: [
          // Dark Plex-style sidebar navigation.
          NavigationRail(
            selectedIndex: _selectedIndex,

            // Runs when the user clicks Search or My Library.
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },

            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFF181818),
            indicatorColor: Colors.amber.shade700.withOpacity(0.18),

            selectedIconTheme: IconThemeData(
              color: Colors.amber.shade700,
            ),
            unselectedIconTheme: IconThemeData(
              color: Colors.grey.shade500,
            ),
            selectedLabelTextStyle: TextStyle(
              color: Colors.amber.shade700,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),

            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text('Search'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books),
                label: Text('My Library'),
              ),
            ],
          ),

          // Dark divider between sidebar and screen content.
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: Color(0xFF2A2A2A),
          ),

          // Main screen area.
          // IndexedStack keeps both screens alive when switching tabs.
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}