import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/login_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'core/services/service_locator.dart' as di;

void main() async {
  // 1. Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize our dependencies
  await di.init();
  
  // 3. Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Provide the LoginProvider to the widget tree
    return ChangeNotifierProvider(
      create: (context) => di.getIt<LoginProvider>(),
      child: MaterialApp(
        title: 'Video Call App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Inter', // A good, clean sans-serif font
          
          textTheme: const TextTheme(
            // Style for "Login"
            headlineMedium: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),

          // Style for the black login button
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // Increased height
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),

          // Style for the text fields
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100], // The light grey background
            
            // This is the key: always show the label at the top
            floatingLabelBehavior: FloatingLabelBehavior.always, 

            // Style for the label ("Email", "Password")
            labelStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),

            // Style for the hint text (the greyed-out example)
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.normal,
            ),

            // Adjust padding to make space for the label
            contentPadding: const EdgeInsets.only(top: 24, bottom: 12, left: 16, right: 16),

            // Borders
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}