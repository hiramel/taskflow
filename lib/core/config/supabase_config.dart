import 'package:supabase_flutter/supabase_flutter.dart';

/// Central place for TaskFlow Supabase configuration.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL.
  static const String projectUrl =
      'https://djesmhnogaekzduuisyz.supabase.co';

  /// Supabase publishable key.
  static const String publishableKey =
      'sb_publishable_N-U_x-QY97ChhyINCiF8ag_3YL62xBU';

  /// Initializes Supabase with the TaskFlow project credentials.
  static Future<void> initialize() {
    return Supabase.initialize(
      url: projectUrl,
      publishableKey: publishableKey,
    );
  }
}
