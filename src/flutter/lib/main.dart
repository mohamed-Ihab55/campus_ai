import 'package:campus_ai/core/utils/app_routes.dart';
import 'package:campus_ai/core/utils/constants.dart';
import 'package:campus_ai/features/chat_bot_feature/data/cubit/chat_cubit.dart';
import 'package:campus_ai/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AICampusGuideApp());
}

class AICampusGuideApp extends StatelessWidget {
  const AICampusGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (context) =>  ChatCubit()..loadCurrentSession(),
      child: MaterialApp(
        initialRoute: '/splash',
        routes: AppRoutes.routes,
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
