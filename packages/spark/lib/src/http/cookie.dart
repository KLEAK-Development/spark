/// HTTP Cookie helper.
library;

/// Represents the SameSite attribute of a cookie.
enum SameSite {
  /// The cookie is withheld on cross-site requests.
  strict('Strict'),

  /// The cookie is sent on some cross-site requests (default).
  lax('Lax'),

  /// The cookie is sent on all requests.
  none('None');

  final String value;
  const SameSite(this.value);
}

/// Represents an HTTP Cookie.
class Cookie {
  /// The name of the cookie.
  final String name;

  /// The value of the cookie.
  final String value;

  /// The expiry date of the cookie.
  final DateTime? expires;

  /// The maximum age of the cookie in seconds.
  final int? maxAge;

  /// The domain the cookie belongs to.
  final String? domain;

  /// The path the cookie belongs to.
  final String? path;

  /// Whether the cookie is secure (HTTPS only).
  final bool secure;

  /// Whether the cookie is HTTP only (not accessible via JavaScript).
  final bool httpOnly;

  /// The SameSite policy for the cookie.
  final SameSite? sameSite;

  /// Creates a new [Cookie].
  const Cookie(
    this.name,
    this.value, {
    this.expires,
    this.maxAge,
    this.domain,
    this.path,
    this.secure = false,
    this.httpOnly = false,
    this.sameSite,
  });

  /// Formats the cookie as a Set-Cookie header value.
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$name=$value');

    if (expires != null) {
      buffer.write('; Expires=${_formatHttpDate(expires!)}');
    }
    if (maxAge != null) {
      buffer.write('; Max-Age=$maxAge');
    }
    if (domain != null) {
      buffer.write('; Domain=$domain');
    }
    if (path != null) {
      buffer.write('; Path=$path');
    }
    if (secure) {
      buffer.write('; Secure');
    }
    if (httpOnly) {
      buffer.write('; HttpOnly');
    }
    if (sameSite != null) {
      buffer.write('; SameSite=${sameSite!.value}');
    }

    return buffer.toString();
  }

  // Simple HTTP date implementation to avoid dart:io dependency in shared code
  String _formatHttpDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final d = date.toUtc();
    return '${days[d.weekday - 1]}, ${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')} GMT';
  }
}
