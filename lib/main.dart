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
    print('Could not load .env file: $error');
  }

  runApp(
    // MultiProvider lets the app use more than one provider at the same time.
    // This is important because we want to use our provider without changing
    // your buddy's library_provider.dart file.
    MultiProvider(
      providers: [
        // ADDED/KEEP THIS:
        // This is our provider for books added from the search screen.
        // This provider will handle saving added books between refreshes.
        ChangeNotifierProvider(
          create: (context) => BookCollectionProvider(),
        ),

        // KEEP THIS:
        // This is your buddy's provider.
        // We are including it so their screen can still use it,
        // but we are not editing their library_provider.dart file.
        ChangeNotifierProvider(
          create: (context) => LibraryProvider(),
        ),
      ],

      // The actual app starts here after both providers are created.
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
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
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
  // The order must match the NavigationRail destinations below.
  final List<Widget> _pages = [
    const HomeScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Row places the sidebar navigation and main content side by side.
      body: Row(
        children: [
          // Sidebar navigation.
          NavigationRail(
            selectedIndex: _selectedIndex,

            // Runs when the user clicks Search or My Library.
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },

            // Shows text labels for each destination.
            labelType: NavigationRailLabelType.all,

            // Light indigo styling to match the app theme.
            backgroundColor: Colors.indigo.withOpacity(0.05),
            indicatorColor: Colors.indigo.withOpacity(0.2),

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

          // Vertical divider between sidebar and screen content.
          const VerticalDivider(thickness: 1, width: 1),

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