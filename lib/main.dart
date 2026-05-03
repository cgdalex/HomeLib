import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // 1. Add this import
import 'screens/home_screen.dart';
import 'screens/library_screen.dart'; // 2. Add your new screen
import 'providers/library_provider.dart'; // 3. Add your provider

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  runApp(
    // 4. Wrap the whole app in the Provider
    ChangeNotifierProvider(
      create: (context) => LibraryProvider(),
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
      // 5. Change home to our new Navigation Wrapper
      home: const MainNavigation(),
    );
  }
}

// 6. This widget handles the switching between Search and Library
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    LibraryScreen(), // Removed const as discussed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use a Row to put the Nav and the Content side-by-side
      body: Row(
        children: [
          // 1. The Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all, // Shows text under icons
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
          
          // A vertical line to separate the nav from the content
          const VerticalDivider(thickness: 1, width: 1),

          // 2. The Main Content
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