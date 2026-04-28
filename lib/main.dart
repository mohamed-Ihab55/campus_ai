import 'package:campus_ai/app.dart';
import 'package:campus_ai/core/utils/constants.dart';
import 'package:campus_ai/features/academic_warning_feature/presentation/view/academic_warning_screen.dart';
import 'package:campus_ai/features/course_registration_feature/presentation/view/course_registration_screen.dart';
import 'package:campus_ai/features/dashboard_screen/presentation/view/dashboard_screen.dart';
import 'package:campus_ai/features/dashboard_screen/presentation/widgets/add_service.dart';
import 'package:campus_ai/features/departments_feature/presentation/view/departments_screen.dart';
import 'package:campus_ai/features/doctors_feature/presentation/view/doctors_screen.dart';
import 'package:campus_ai/features/elearn_web_view_feature/presentation/view/elearning_screen.dart';
import 'package:campus_ai/features/gpa_feature/presentation/view/gpa_calculator_screen.dart';
import 'package:campus_ai/features/lab_feature/presentation/view/labs_screen.dart';
import 'package:campus_ai/features/map_feature/presentation/view/map_screen.dart';
import 'package:campus_ai/features/news_feature/presentation/view/news_web_view.dart';
import 'package:campus_ai/features/splash_feature/presentation/view/splash_screen.dart';
import 'package:campus_ai/features/transcript_feature/presentation/view/transcript_screen.dart';
import 'package:campus_ai/features/ums_webview_feature/presentation/view/ums_web_view.dart';
import 'package:campus_ai/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    return MaterialApp(
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const MainNavigationScreen(),
        '/doctor': (context) => const DoctorsScreen(),
        '/map': (context) => const MapScreen(),
        '/gpa': (context) => const GpaCalculatorScreen(),
        '/ums': (context) => const UmsWebView(),
        '/news': (context) => const NewsWebView(),
        '/elearn': (context) => const ElearningScreen(),
        '/department': (context) => const DepartmentsScreen(),
        '/labs': (context) => const LabsScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // '/edit-avatar-colors': (context) => const EditAvatarColorScreen(),
        '/add_services': (context) => const AddServiceScreen(),
        '/transcript': (context) => const TranscriptScreen(),
        '/warning': (context) => const AcademicWarningScreen(),
        '/course_register': (context) => const CourseRegistrationScreen(),
      },
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
    );
  }
}
