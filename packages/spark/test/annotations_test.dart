import 'package:spark_framework/spark.dart';
import 'package:test/test.dart';

void main() {
  group('Page annotation', () {
    test('stores path', () {
      const page = Page(path: '/users/:id');
      expect(page.path, '/users/:id');
    });

    test('defaults methods to GET', () {
      const page = Page(path: '/');
      expect(page.methods, ['GET']);
    });

    test('accepts custom methods', () {
      const page = Page(path: '/form', methods: ['GET', 'POST']);
      expect(page.methods, ['GET', 'POST']);
    });
  });

  group('Component annotation', () {
    test('stores tag name', () {
      const component = Component(tag: 'my-counter');
      expect(component.tag, 'my-counter');
    });
  });

  group('Attribute annotation', () {
    test('can be constructed', () {
      const attr = Attribute();
      expect(attr, isA<Attribute>());
    });
  });

  group('Endpoint annotation', () {
    test('stores required fields', () {
      const endpoint = Endpoint(path: '/api/users', method: 'GET');
      expect(endpoint.path, '/api/users');
      expect(endpoint.method, 'GET');
    });

    test('defaults optional fields to null', () {
      const endpoint = Endpoint(path: '/api', method: 'GET');
      expect(endpoint.summary, isNull);
      expect(endpoint.description, isNull);
      expect(endpoint.tags, isNull);
      expect(endpoint.deprecated, isNull);
      expect(endpoint.security, isNull);
      expect(endpoint.operationId, isNull);
      expect(endpoint.externalDocs, isNull);
      expect(endpoint.parameters, isNull);
      expect(endpoint.contentTypes, isNull);
      expect(endpoint.statusCode, isNull);
    });

    test('stores all optional fields', () {
      const endpoint = Endpoint(
        path: '/api/users',
        method: 'POST',
        summary: 'Create user',
        description: 'Creates a new user account',
        tags: ['users'],
        deprecated: false,
        security: [
          {'bearerAuth': <String>[]},
        ],
        operationId: 'createUser',
        externalDocs: ExternalDocumentation(
          url: 'https://docs.example.com',
          description: 'More info',
        ),
        parameters: [Parameter(name: 'limit', inLocation: 'query')],
        contentTypes: ['application/json'],
        statusCode: 201,
      );
      expect(endpoint.summary, 'Create user');
      expect(endpoint.description, 'Creates a new user account');
      expect(endpoint.tags, ['users']);
      expect(endpoint.deprecated, isFalse);
      expect(endpoint.security, hasLength(1));
      expect(endpoint.operationId, 'createUser');
      expect(endpoint.externalDocs, isNotNull);
      expect(endpoint.externalDocs!.url, 'https://docs.example.com');
      expect(endpoint.externalDocs!.description, 'More info');
      expect(endpoint.parameters, hasLength(1));
      expect(endpoint.contentTypes, ['application/json']);
      expect(endpoint.statusCode, 201);
    });
  });

  group('Validators', () {
    test('NotEmpty stores message', () {
      const v = NotEmpty(message: 'Required');
      expect(v.message, 'Required');
      expect(v, isA<Validator>());
    });

    test('NotEmpty defaults message to null', () {
      const v = NotEmpty();
      expect(v.message, isNull);
    });

    test('Email stores message', () {
      const v = Email(message: 'Invalid email');
      expect(v.message, 'Invalid email');
      expect(v, isA<Validator>());
    });

    test('Email defaults message to null', () {
      const v = Email();
      expect(v.message, isNull);
    });

    test('Min stores value and message', () {
      const v = Min(5, message: 'Too small');
      expect(v.value, 5);
      expect(v.message, 'Too small');
      expect(v, isA<Validator>());
    });

    test('Min works with doubles', () {
      const v = Min(1.5);
      expect(v.value, 1.5);
      expect(v.message, isNull);
    });

    test('Max stores value and message', () {
      const v = Max(100, message: 'Too big');
      expect(v.value, 100);
      expect(v.message, 'Too big');
      expect(v, isA<Validator>());
    });

    test('Max defaults message to null', () {
      const v = Max(50);
      expect(v.message, isNull);
    });

    test('Length stores min, max, and message', () {
      const v = Length(min: 3, max: 20, message: 'Bad length');
      expect(v.min, 3);
      expect(v.max, 20);
      expect(v.message, 'Bad length');
      expect(v, isA<Validator>());
    });

    test('Length allows only min', () {
      const v = Length(min: 1);
      expect(v.min, 1);
      expect(v.max, isNull);
    });

    test('Length allows only max', () {
      const v = Length(max: 255);
      expect(v.min, isNull);
      expect(v.max, 255);
    });

    test('Pattern stores pattern and message', () {
      const v = Pattern(r'^\d+$', message: 'Digits only');
      expect(v.pattern, r'^\d+$');
      expect(v.message, 'Digits only');
      expect(v, isA<Validator>());
    });

    test('IsNumeric stores message', () {
      const v = IsNumeric(message: 'Must be numeric');
      expect(v.message, 'Must be numeric');
      expect(v, isA<Validator>());
    });

    test('IsNumeric defaults message to null', () {
      const v = IsNumeric();
      expect(v.message, isNull);
    });

    test('IsDate stores message', () {
      const v = IsDate(message: 'Invalid date');
      expect(v.message, 'Invalid date');
      expect(v, isA<Validator>());
    });

    test('IsBooleanString stores message', () {
      const v = IsBooleanString(message: 'Must be boolean');
      expect(v.message, 'Must be boolean');
      expect(v, isA<Validator>());
    });

    test('IsString stores message', () {
      const v = IsString(message: 'Must be string');
      expect(v.message, 'Must be string');
      expect(v, isA<Validator>());
    });
  });

  group('OpenApi annotation', () {
    test('stores all fields', () {
      const api = OpenApi(
        title: 'My API',
        version: '1.0.0',
        description: 'An API',
        servers: ['https://api.example.com'],
      );
      expect(api.title, 'My API');
      expect(api.version, '1.0.0');
      expect(api.description, 'An API');
      expect(api.servers, ['https://api.example.com']);
    });

    test('defaults all fields to null', () {
      const api = OpenApi();
      expect(api.title, isNull);
      expect(api.version, isNull);
      expect(api.description, isNull);
      expect(api.servers, isNull);
      expect(api.security, isNull);
      expect(api.securitySchemes, isNull);
    });
  });

  group('SecurityScheme', () {
    test('apiKey sets correct type and fields', () {
      const scheme = SecurityScheme.apiKey(
        name: 'X-API-Key',
        inLocation: 'header',
        description: 'API key auth',
      );
      expect(scheme.type, 'apiKey');
      expect(scheme.name, 'X-API-Key');
      expect(scheme.inLocation, 'header');
      expect(scheme.description, 'API key auth');
    });

    test('http bearer sets correct type and fields', () {
      const scheme = SecurityScheme.http(
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'JWT auth',
      );
      expect(scheme.type, 'http');
      expect(scheme.scheme, 'bearer');
      expect(scheme.bearerFormat, 'JWT');
      expect(scheme.description, 'JWT auth');
    });

    test('oauth2 sets correct type and flows', () {
      const scheme = SecurityScheme.oauth2(
        flows: {
          'authorizationCode': SecuritySchemeFlow(
            authorizationUrl: 'https://auth.example.com/authorize',
            tokenUrl: 'https://auth.example.com/token',
            scopes: {'read': 'Read access', 'write': 'Write access'},
          ),
        },
      );
      expect(scheme.type, 'oauth2');
      expect(scheme.flows, isNotNull);
      expect(scheme.flows!['authorizationCode'], isNotNull);
      expect(
        scheme.flows!['authorizationCode']!.authorizationUrl,
        'https://auth.example.com/authorize',
      );
      expect(scheme.flows!['authorizationCode']!.scopes, {
        'read': 'Read access',
        'write': 'Write access',
      });
    });

    test('openIdConnect sets correct type and url', () {
      const scheme = SecurityScheme.openIdConnect(
        openIdConnectUrl:
            'https://auth.example.com/.well-known/openid-configuration',
      );
      expect(scheme.type, 'openIdConnect');
      expect(
        scheme.openIdConnectUrl,
        'https://auth.example.com/.well-known/openid-configuration',
      );
    });
  });

  group('SecuritySchemeFlow', () {
    test('stores all fields', () {
      const flow = SecuritySchemeFlow(
        authorizationUrl: 'https://auth.example.com/authorize',
        tokenUrl: 'https://auth.example.com/token',
        refreshUrl: 'https://auth.example.com/refresh',
        scopes: {'read': 'Read', 'write': 'Write'},
      );
      expect(flow.authorizationUrl, 'https://auth.example.com/authorize');
      expect(flow.tokenUrl, 'https://auth.example.com/token');
      expect(flow.refreshUrl, 'https://auth.example.com/refresh');
      expect(flow.scopes, {'read': 'Read', 'write': 'Write'});
    });

    test('defaults all fields to null', () {
      const flow = SecuritySchemeFlow();
      expect(flow.authorizationUrl, isNull);
      expect(flow.tokenUrl, isNull);
      expect(flow.refreshUrl, isNull);
      expect(flow.scopes, isNull);
    });
  });

  group('Parameter', () {
    test('stores required fields', () {
      const param = Parameter(name: 'limit', inLocation: 'query');
      expect(param.name, 'limit');
      expect(param.inLocation, 'query');
    });

    test('stores all optional fields', () {
      const param = Parameter(
        name: 'page',
        inLocation: 'query',
        description: 'Page number',
        required: true,
        deprecated: false,
        schema: {'type': 'integer'},
        allowEmptyValue: false,
        style: 'form',
        explode: true,
        allowReserved: false,
        example: 1,
      );
      expect(param.description, 'Page number');
      expect(param.required, isTrue);
      expect(param.deprecated, isFalse);
      expect(param.schema, {'type': 'integer'});
      expect(param.allowEmptyValue, isFalse);
      expect(param.style, 'form');
      expect(param.explode, isTrue);
      expect(param.allowReserved, isFalse);
      expect(param.example, 1);
    });

    test('defaults optional fields to null', () {
      const param = Parameter(name: 'id', inLocation: 'path');
      expect(param.description, isNull);
      expect(param.required, isNull);
      expect(param.deprecated, isNull);
      expect(param.schema, isNull);
      expect(param.type, isNull);
      expect(param.allowEmptyValue, isNull);
      expect(param.style, isNull);
      expect(param.explode, isNull);
      expect(param.allowReserved, isNull);
      expect(param.example, isNull);
    });
  });

  group('ExternalDocumentation', () {
    test('stores url and description', () {
      const docs = ExternalDocumentation(
        url: 'https://docs.example.com',
        description: 'Full API docs',
      );
      expect(docs.url, 'https://docs.example.com');
      expect(docs.description, 'Full API docs');
    });

    test('defaults description to null', () {
      const docs = ExternalDocumentation(url: 'https://docs.example.com');
      expect(docs.description, isNull);
    });
  });
}
