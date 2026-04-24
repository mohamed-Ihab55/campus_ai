
import 'package:campus_ai/core/theme/app_theme.dart';
import 'package:campus_ai/core/utils/constants.dart';
import 'package:campus_ai/features/splash_feature/presentation/view/splash_screen.dart';
import 'package:campus_ai/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
    const AICampusGuideApp(),
  );
}

class AICampusGuideApp extends StatelessWidget {
  const AICampusGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
