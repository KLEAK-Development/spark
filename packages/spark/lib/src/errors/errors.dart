import 'dart:convert';
import 'package:shelf/shelf.dart';

/// Standard JSON Error Response DTO
class ApiError implements Exception {
  final String message;
  final String code;
  final int statusCode;

  /// Details can be a Map of field -> error object, or generic map
  final Map<String, dynamic>? details;

  ApiError({
    required this.message,
    required this.code,
    this.statusCode = 500,
    this.details,
  });

  Map<String, dynamic> toJson() => {
    'message': message,
    'code': code,
    if (details != null) 'details': details,
  };

  Response toResponse([int? statusCode]) {
    return Response(
      statusCode ?? this.statusCode,
      body: jsonEncode(toJson()),
      headers: {'content-type': 'application/json'},
    );
  }
}

/// Exception for Validation Failures
class SparkValidationException implements Exception {
  final Map<String, dynamic> errors;
  final String message;

  SparkValidationException(this.errors, {this.message = 'Validation Failed'});
}

/// Base HTTP Exception
class SparkHttpException implements Exception {
  final int statusCode;
  final String message;
  final String code;
  final Map<String, dynamic>? details;

  SparkHttpException(
    this.statusCode,
    this.message, {
    this.code = 'HTTP_ERROR',
    this.details,
  });
}
