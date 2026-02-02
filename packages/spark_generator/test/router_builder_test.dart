import 'package:build_test/build_test.dart';
import 'package:spark_generator/src/router_builder.dart';
import 'package:test/test.dart';

void main() {
  group('RouterBuilder', () {
    test('generates router and server config with new fields', () async {
      final builder = RouterBuilder();

      await testBuilder(
        builder,
        {
          'a|lib/pages/home_page.dart': '''
            import 'package:spark/spark.dart';

            @Page(path: '/')
            class HomePage extends SparkPage<void> {
              @override
              String render(void data, PageRequest request) => 'Hello';
            }
          ''',
          'a|lib/pages/home_page.spark.g.part': '''
// **************************************************************************
// PageGenerator
// **************************************************************************

const _\$HomePageRoute = (
  path: '/',
  methods: <String>['GET', 'HEAD'],
  pathParams: <String>[],
);

Future<Response> _\$handleHomePage(Request request) async {
  return Response.ok('Helper');
}
''',
        },
        outputs: {
          'a|lib/spark_router.g.dart': decodedMatches(
            contains('class SparkServerConfig'),
          ),
        },
      );
    });

    test(
      'validates full content of generated file including HTTPS logic',
      () async {
        final builder = RouterBuilder();

        await testBuilder(
          builder,
          {
            'a|lib/pages/home_page.dart': '',
            'a|lib/pages/home_page.spark.g.part': '''
const _\$HomePageRoute = (
  path: '/',
  methods: <String>['GET'],
  pathParams: <String>[],
);

Future<Response> _\$handleHomePage(Request request) async { return Response.ok('ok'); }
''',
          },
          outputs: {
            'a|lib/spark_router.g.dart': decodedMatches(
              allOf([
                contains('final Object host;'),
                contains('final SecurityContext? securityContext;'),
                contains('final bool shared;'),
                contains('final bool redirectToHttps;'),
                contains('final int? isolates;'),
                contains("import 'dart:isolate';"),
                contains(
                  'if (config.redirectToHttps && config.securityContext != null)',
                ),
                contains('Isolate.spawnUri('),
                contains('SPARK_WORKER_ID'),
                contains('await shelf_io.serve('), // The redirect server
                contains('securityContext: config.securityContext,'),
                contains(
                  'shared: config.shared || (config.isolates != null && config.isolates! > 1),',
                ),
                contains('lang: page.lang,'),
                // CSP Assertions
                contains("final nonce = base64Url.encode(nonceBytes)"),
                contains("'spark.nonce': nonce"),
                contains("response.headers['content-security-policy']"),
                contains("script-src 'nonce-\$nonce'"),
                contains("style-src 'nonce-\$nonce'"),
                contains(
                  'String? nonce,',
                ), // nonce parameter in _$renderPageResponse
                contains('nonce: nonce,'), // passed to renderPage
              ]),
            ),
          },
        );
      },
    );

    test('generates handler using Cascade for correct order', () async {
      final builder = RouterBuilder();

      await testBuilder(
        builder,
        {
          'a|lib/pages/home_page.dart': '',
          'a|lib/pages/home_page.spark.g.part': '''
const _\$HomePageRoute = (
  path: '/',
  methods: <String>['GET'],
  pathParams: <String>[],
);

Future<Response> _\$handleHomePage(Request request) async { return Response.ok('ok'); }
''',
        },
        outputs: {
          'a|lib/spark_router.g.dart': decodedMatches(
            allOf([
              contains('var cascade = Cascade();'),
              contains(
                'cascade = cascade.add(createStaticHandler(',
              ), // Static assets first
              contains('cascade = cascade.add(router.call);'), // Then router
              contains(
                'cascade = cascade.add(config!.notFoundHandler!);',
              ), // Then 404
              contains('return cascade.handler;'),
            ]),
          ),
        },
      );
    });

    test('generates notFoundPage logic', () async {
      final builder = RouterBuilder();

      await testBuilder(
        builder,
        {
          'a|lib/pages/home_page.dart': '',
          'a|lib/pages/home_page.spark.g.part': '''
const _\$HomePageRoute = (
  path: '/',
  methods: <String>['GET'],
  pathParams: <String>[],
);

Future<Response> _\$handleHomePage(Request request) async { return Response.ok('ok'); }
''',
        },
        outputs: {
          'a|lib/spark_router.g.dart': decodedMatches(
            allOf([
              contains('final SparkPage<dynamic>? notFoundPage;'),
              contains('if (config!.notFoundHandler != null) {'),
              contains('} else if (config!.notFoundPage != null) {'),
              contains('final page = config!.notFoundPage!;'),
              contains('_\$renderPageResponse('),
              contains("request.context['spark.nonce'] as String?,"),
            ]),
          ),
        },
      );
    });
  });
}
