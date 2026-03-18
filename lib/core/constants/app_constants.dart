// This is for example only
class AppConstants {
  // App Information
  static const String appName = 'My Flutter App';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API Constants
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'app_language';

  // Pagination
  static const int defaultPageSize = 20;
  static const int initialPage = 1;

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // Debounce Time
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Localization
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'gu', 'hi'];
}

class AppDimensions {
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Margin
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusExtraLarge = 24.0;

  // Button Height
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Icon Size
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
}