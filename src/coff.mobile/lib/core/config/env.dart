/// Override at build/run time:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000/
/// 10.0.2.2 is the host machine as seen from the Android emulator.
abstract final class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/',
  );

  /// Transactions have no currency yet, so the dashboard formats everything
  /// with this one (e.g. --dart-define=CURRENCY=PHP).
  static const currencyCode = String.fromEnvironment(
    'CURRENCY',
    defaultValue: 'USD',
  );
}
