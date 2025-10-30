import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:videomeet/core/services/service_locator.dart'; 
import 'package:videomeet/presentation/providers/login_provider.dart';
import 'package:videomeet/presentation/providers/user_list_provider.dart';
import 'package:videomeet/presentation/providers/video_call_provider.dart';
import 'package:videomeet/presentation/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // All your providers wrap the MaterialApp
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<LoginProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<UserListProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<VideoCallProvider>()),
      ],
      child: MaterialApp(
        title: 'VideoMeet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
         
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const SplashScreen(),
       
      ),
    );
  }
}