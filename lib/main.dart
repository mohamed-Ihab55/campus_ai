import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/core/theme/theme_provider.dart';
import 'package:campus_ai/core/utils/app_routes.dart';
import 'package:campus_ai/core/utils/constants.dart';
import 'package:campus_ai/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(create: (BuildContext context) { return ThemeProvider(); },
  child: const AICampusGuideApp()));
}

class AICampusGuideApp extends StatelessWidget {
  const AICampusGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      initialRoute: '/splash',
      routes: AppRoutes.routes,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
