import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:videomeet/core/services/service_locator.dart' as service_locator;
import 'package:videomeet/data/services/locals/cache_service.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await service_locator.init(prefs);
    final cacheService = service_locator.getIt<CacheService>();
    final token = await cacheService.getToken();


    if (!mounted) return;

    if (token != null) {
      // User is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      // User is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.circle_outlined,
                color: Colors.black,
                size: 50,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}