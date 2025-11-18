class AppConfig {
  const AppConfig._();

  /// Base URL of the deployed Google Apps Script Web App.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Optional secret that the Apps Script validates per request.
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  /// Toggle for running the app with local mock data. Defaults to true so the
  /// UI is usable before the backend is ready.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );

  /// Global timeout for network calls.
  static const Duration requestTimeout = Duration(seconds: 12);

  /// Window for highlighting upcoming renewals on the dashboard.
  static const int dueSoonWindowInDays = 14;
}
