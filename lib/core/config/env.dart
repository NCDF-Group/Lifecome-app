/// Backend base URL. Override at build/run time with
/// `--dart-define=API_BASE_URL=http://localhost:3000/api/v1` to point at a local backend
/// instead of the deployed one.
class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://lifecome-backend.onrender.com/api/v1',
  );
}
