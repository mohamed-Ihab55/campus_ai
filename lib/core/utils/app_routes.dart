import 'package:flutter/material.dart';
import '../../app.dart';
import '../../features/academic_warning_feature/presentation/view/academic_warning_screen.dart';
import '../../features/course_registration_feature/presentation/view/course_registration_screen.dart';
import '../../features/dashboard_screen/presentation/view/dashboard_screen.dart';
import '../../features/dashboard_screen/presentation/widgets/add_service.dart';
import '../../features/departments_feature/presentation/view/departments_screen.dart';
import '../../features/doctors_feature/presentation/view/doctors_screen.dart';
import '../../features/elearn_web_view_feature/presentation/view/elearning_screen.dart';
import '../../features/gpa_feature/presentation/view/gpa_calculator_screen.dart';
import '../../features/lab_feature/presentation/view/labs_screen.dart';
import '../../features/map_feature/presentation/view/map_screen.dart';
import '../../features/news_feature/presentation/view/news_web_view.dart';
import '../../features/splash_feature/presentation/view/splash_screen.dart';
import '../../features/transcript_feature/presentation/view/transcript_screen.dart';
import '../../features/ums_webview_feature/presentation/view/ums_web_view.dart';
class AppRoutes {
  static Map<String,WidgetBuilder> routes={
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
};}