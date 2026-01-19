/// Categories of errors in the dev environment.
enum DevErrorType {
  /// Build errors from build_runner (Dart analyzer errors, code generation failures).
  build('Build Error'),

  /// Server process errors (crashes, unexpected exits).
  server('Server Error'),

  /// Hot reload failures.
  hotReload('Hot Reload Error'),

  /// VM Service connection issues.
  vmService('VM Service Error'),

  /// Startup or operation timeouts.
  timeout('Timeout Error'),

  /// Live reload server errors.
  liveReload('Live Reload Error');

  const DevErrorType(this.label);

  /// Human-readable label for this error type.
  final String label;
}
