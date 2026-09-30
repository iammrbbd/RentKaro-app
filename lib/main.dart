import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/splash/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: SplashApp(),
    ),
  );
}

class SplashApp extends StatefulWidget {
  const SplashApp({super.key});

  @override
  State<SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  bool _showApp = false;

  void _finishSplash() {
    if (!mounted) return;

    setState(() {
      _showApp = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Once splash finishes, start the actual RentKaro app.
    if (_showApp) {
      return const RentKaroApp();
    }

    // Splash needs MaterialApp because Scaffold,
    // Directionality and MediaQuery depend on it.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RentKaro',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(
        onFinished: _finishSplash,
      ),
    );
  }
}