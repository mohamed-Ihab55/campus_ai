class AppConstants {
  // App Info
  static const String appName = 'AI Campus Guide';
  static const String appTagline = 'Your smart companion for navigating the campus';

  // Campus Location (Ain Shams University, Abbassia)
  static const double campusLat = 30.0778;
  static const double campusLng = 31.2859;
  static const double defaultZoom = 17.0;

  // Timing
  static const Duration splashDuration = Duration(milliseconds: 1500);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Firebase Collections
  static const String locationsCollection = 'locations';
  static const String categoriesCollection = 'categories';

  // Categories
  static const List<String> defaultCategories = [
    'Student Services',
    'Departments',
    'Labs',
    'Administration',
    'Facilities',
  ];

  // Search
  static const int searchMinLength = 2;
  static const int maxSearchResults = 50;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
}

