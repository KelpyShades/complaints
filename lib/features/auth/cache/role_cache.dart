import 'package:shared_preferences/shared_preferences.dart';

/// Synchronous role cache backed by [SharedPreferences].
///
/// Call [preload] once in `main()` before [runApp].  After that,
/// [load] returns the cached role synchronously — no async gap
/// means no first-render flicker due to an unknown role.
abstract final class RoleCache {
  static const _key = 'user_role';
  static SharedPreferences? _prefs;

  /// Pre-warms the SharedPreferences instance.
  /// Must be awaited before [runApp].
  static Future<void> preload() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Synchronously reads the cached role.
  /// Returns `null` if no role has been saved yet.
  static String? load() => _prefs?.getString(_key);

  /// Persists [role] to shared preferences.
  static Future<void> save(String role) async {
    await _prefs?.setString(_key, role);
  }

  /// Clears the cached role. Call this on sign-out.
  static Future<void> clear() async {
    await _prefs?.remove(_key);
  }
}
