import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'providers/book_collection_provider.dart';

// If your buddy needs their provider too, they can uncomment this import
// after confirming the class name inside library_provider.dart.
// import 'providers/library_provider.dart';

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
    // MultiProvider lets the app use more than one provider.
    // This is useful because you have your book collection provider,
    // and your buddy may also have their own library provider.
    MultiProvider(
      providers: [
        // This provider stores the books added from the search screen.
        ChangeNotifierProvider(
          create: (context) => BookCollectionProvider(),
        ),

        // Your buddy can add their provider right here.
        // Example:
        //
        // ChangeNotifierProvider(
        //   create: (context) => LibraryProvider(),
        // ),
        //
        // They also need to uncomment the import near the top:
        // import 'providers/library_provider.dart';
      ],

      // The actual app starts here after the providers are created.
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
      home: const HomeScreen(),
    );
  }
}