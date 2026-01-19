/// global configuration for the OpenAPI specification.
///
/// Use this annotation to provide global metadata like title, version,
/// and security requirements for the generated OpenAPI spec.
class OpenApi {
  /// The title of the API.
  final String? title;

  /// The version of the API.
  final String? version;

  /// A description of the API.
  final String? description;

  /// A list of servers providing the API.
  final List<String>? servers;

  /// Global security requirements for the API.
  final List<Map<String, List<String>>>? security;

  /// Global security schemes for the API.
  final Map<String, SecurityScheme>? securitySchemes;

  /// Creates a new global OpenAPI configuration.
  const OpenApi({
    this.title,
    this.version,
    this.description,
    this.servers,
    this.security,
    this.securitySchemes,
  });
}

/// Defines a security scheme for the API.
class SecurityScheme {
  final String type;
  final String? description;
  final String? name;
  final String? inLocation;
  final String? scheme;
  final String? bearerFormat;
  final Map<String, SecuritySchemeFlow>? flows;
  final String? openIdConnectUrl;

  const SecurityScheme._({
    required this.type,
    this.description,
    this.name,
    this.inLocation,
    this.scheme,
    this.bearerFormat,
    this.flows,
    this.openIdConnectUrl,
  });

  /// Creates an API Key security scheme.
  const SecurityScheme.apiKey({
    required String name,
    required String inLocation,
    String? description,
  }) : this._(
         type: 'apiKey',
         name: name,
         inLocation: inLocation,
         description: description,
       );

  /// Creates an HTTP security scheme (e.g., Basic, Bearer).
  const SecurityScheme.http({
    required String scheme,
    String? bearerFormat,
    String? description,
  }) : this._(
         type: 'http',
         scheme: scheme,
         bearerFormat: bearerFormat,
         description: description,
       );

  /// Creates an OAuth2 security scheme.
  const SecurityScheme.oauth2({
    required Map<String, SecuritySchemeFlow> flows,
    String? description,
  }) : this._(type: 'oauth2', flows: flows, description: description);

  /// Creates an OpenID Connect security scheme.
  const SecurityScheme.openIdConnect({
    required String openIdConnectUrl,
    String? description,
  }) : this._(
         type: 'openIdConnect',
         openIdConnectUrl: openIdConnectUrl,
         description: description,
       );
}

/// Defines an OAuth2 flow.
class SecuritySchemeFlow {
  final String? authorizationUrl;
  final String? tokenUrl;
  final String? refreshUrl;
  final Map<String, String>? scopes;

  const SecuritySchemeFlow({
    this.authorizationUrl,
    this.tokenUrl,
    this.refreshUrl,
    this.scopes,
  });
}

/// Describes a single operation parameter.
class Parameter {
  /// The name of the parameter.
  final String name;

  /// The location of the parameter.
  final String inLocation;

  /// A brief description of the parameter.
  final String? description;

  /// Determines whether this parameter is mandatory.
  final bool? required;

  /// Specifies that a parameter is deprecated and SHOULD be transitioned out of usage.
  final bool? deprecated;

  /// The schema defining the type used for the parameter.
  final Map<String, dynamic>? schema;

  /// The Dart type used to generate the schema.
  final Type? type;

  /// Sets the ability to pass empty-valued parameters.
  final bool? allowEmptyValue;

  /// Describes how the parameter value will be serialized depending on the type of the parameter value.
  final String? style;

  /// When this is true, parameter values of type `array` or `object` generate separate parameters for each value of the array or key-value pair of the map.
  final bool? explode;

  /// Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986.
  final bool? allowReserved;

  /// Example of the parameter's potential value.
  final Object? example;

  const Parameter({
    required this.name,
    required this.inLocation,
    this.description,
    this.required,
    this.deprecated,
    this.schema,
    this.type,
    this.allowEmptyValue,
    this.style,
    this.explode,
    this.allowReserved,
    this.example,
  });
}

/// Allows referencing an external resource for extended documentation.
class ExternalDocumentation {
  /// A short description of the target documentation.
  final String? description;

  /// The URL for the target documentation.
  final String url;

  const ExternalDocumentation({this.description, required this.url});
}
