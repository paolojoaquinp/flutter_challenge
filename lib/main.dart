import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/app_shell.dart';
import 'src/core/design/tokens/palette.dart';
import 'src/core/helpers/hive_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper().init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Challenge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Palette.background,
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
