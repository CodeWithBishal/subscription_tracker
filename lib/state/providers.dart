import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../services/api_client.dart';
import '../services/google_apps_script_service.dart';
import '../services/local_cache_service.dart';
import '../services/mock_google_apps_script_service.dart';
import '../services/sheets_data_source.dart';
import 'tracker_notifier.dart';
import 'tracker_repository.dart';
import 'tracker_state.dart';

final sheetsDataSourceProvider = Provider<SheetsDataSource>((ref) {
  if (AppConfig.useMockData || AppConfig.apiBaseUrl.isEmpty) {
    return MockGoogleAppsScriptService();
  }
  final client = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    apiKey: AppConfig.apiKey,
  );
  ref.onDispose(client.dispose);
  return GoogleAppsScriptService(client);
});

final localCacheProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});

final trackerRepositoryProvider = Provider<TrackerRepository>((ref) {
  final remote = ref.watch(sheetsDataSourceProvider);
  final cache = ref.watch(localCacheProvider);
  return TrackerRepository(remote, cache);
});

final trackerNotifierProvider =
    StateNotifierProvider<TrackerNotifier, TrackerState>((ref) {
      final repository = ref.watch(trackerRepositoryProvider);
      return TrackerNotifier(repository);
    });
