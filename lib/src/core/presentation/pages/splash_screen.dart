import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ValueNotifier<bool> _isTimeElapsed = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _isTimeElapsed.value = true;
      }
    });
  }

  @override
  void dispose() {
    _isTimeElapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isTimeElapsed,
      builder: (context, isTimeElapsed, child) {
        if (isTimeElapsed) {
          Future.microtask(() {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 800),
                pageBuilder: (_, __, ___) => const AppShell(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Lottie.asset(
              'assets/lotties/Blogging.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback while the user adds the lottie file
                return const Icon(
                  Icons.newspaper,
                  size: 100,
                  color: Colors.blue,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
