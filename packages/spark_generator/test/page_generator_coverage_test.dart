import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:spark_generator/src/page_generator.dart';
import 'package:test/test.dart';

class SimpleBuildStep implements BuildStep {
  @override
  final AssetId inputId;
  SimpleBuildStep(this.inputId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Helper to resolve a page class and generate output.
Future<String> _generateForPage({
  required String fileName,
  required String source,
  String? sparkPageDef,
  AssetId? inputId,
}) async {
  late String result;
  await resolveSources(
    {
      'spark|lib/src/annotations/page.dart': '''
        class Page {
          final String path;
          final List<String> methods;
          const Page({required this.path, this.methods = const ['GET']});
        }
      ''',
      'spark|lib/src/page/spark_page.dart':
          sparkPageDef ??
          '''
        abstract class SparkPage<T> {
          List<dynamic> get middleware => [];
          Future<void> loader(dynamic request);
          dynamic render(dynamic data);
          dynamic get components => null;
        }
      ''',
      'spark|lib/spark.dart': '''
        library spark;
        export 'src/annotations/page.dart';
        export 'src/page/spark_page.dart';
      ''',
      'a|lib/$fileName': source,
    },
    (resolver) async {
      final libraryElement = await resolver.libraryFor(
        AssetId('a', 'lib/$fileName'),
      );

      // Find the annotated class (last concrete class in the file)
      final classes = libraryElement.children.whereType<ClassElement>().toList();
      final annotatedClass = classes.lastWhere(
        (e) => e.metadata.annotations.any((a) {
          final enclosing = a.element?.enclosingElement;
          return enclosing?.name == 'Page';
        }),
      );

      final annotation = annotatedClass.metadata.annotations.firstWhere((a) {
        final enclosing = a.element?.enclosingElement;
        return enclosing?.name == 'Page';
      });

      final constantReader = ConstantReader(annotation.computeConstantValue());
      final generator = PageGenerator();
      result = generator.generateForAnnotatedElement(
        annotatedClass,
        constantReader,
        SimpleBuildStep(inputId ?? AssetId('a', 'lib/$fileName')),
      );
    },
  );
  return result;
}

void main() {
  group('PageGenerator', () {
    test('generates handler with multiple HTTP methods', () async {
      final output = await _generateForPage(
        fileName: 'form_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/form', methods: ['GET', 'POST'])
          class FormPage extends SparkPage<void> {
          }
        ''',
      );

      expect(output, contains('Future<Response> _\$handleFormPage'));
      expect(output, contains("path: '/form'"));
      expect(output, contains("methods: <String>[GET, POST]"));
    });

    test('generates PageRedirect handling', () async {
      final output = await _generateForPage(
        fileName: 'redirect_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/old')
          class RedirectPage extends SparkPage<void> {
          }
        ''',
      );

      expect(output, contains('PageRedirect'));
      expect(output, contains(':final location'));
      expect(output, contains("'location': location"));
    });

    test('generates PageError handling', () async {
      final output = await _generateForPage(
        fileName: 'error_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/error')
          class ErrorPage extends SparkPage<void> {
          }
        ''',
      );

      expect(output, contains('PageError'));
      expect(output, contains(':final message'));
      expect(output, contains('_\$renderErrorResponse'));
    });

    test('generates middleware pipeline', () async {
      final output = await _generateForPage(
        fileName: 'protected_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/protected')
          class ProtectedPage extends SparkPage<void> {
          }
        ''',
      );

      expect(output, contains('var pipeline = const Pipeline()'));
      expect(output, contains('for (final middleware in page.middleware)'));
      expect(output, contains('pipeline = pipeline.addMiddleware(middleware)'));
      expect(output, contains('pipeline.addHandler(handler)(request)'));
    });

    test('generates multiple path parameters', () async {
      final output = await _generateForPage(
        fileName: 'nested_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/posts/:postId/comments/:commentId')
          class NestedPage extends SparkPage<void> {
          }
        ''',
      );

      expect(output, contains("path: '/posts/<postId>/comments/<commentId>'"));
      expect(output, contains('String postId'));
      expect(output, contains('String commentId'));
      expect(output, contains("'postId': postId"));
      expect(output, contains("'commentId': commentId"));
    });

    test('generates no path params for static route', () async {
      final output = await _generateForPage(
        fileName: 'about_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/about')
          class AboutPage extends SparkPage<void> {
          }
        ''',
      );

      expect(output, contains("pathParams: <String>[]"));
      // Handler should only take Request, no extra String params
      expect(
        output,
        contains('Future<Response> _\$handleAboutPage(\n  Request request,\n) async {'),
      );
    });

    test('generates null scriptName when page has no components', () async {
      final output = await _generateForPage(
        fileName: 'static_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/static')
          class StaticPage extends SparkPage<void> {
          }
        ''',
      );

      // scriptName should be null since no components getter override
      expect(output, contains('null, req.context'));
    });

    test('generates route info constant', () async {
      final output = await _generateForPage(
        fileName: 'info_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/info')
          class InfoPage extends SparkPage<void> {
          }
        ''',
      );

      expect(output, contains('const _\$InfoPageRoute = ('));
      expect(output, contains("path: '/info'"));
      expect(output, contains("className: 'InfoPage'"));
    });

    test('generates cookie destructuring in PageData branch', () async {
      final output = await _generateForPage(
        fileName: 'data_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/data')
          class DataPage extends SparkPage<void> {
          }
        ''',
      );

      expect(output, contains(':final cookies'));
      expect(output, contains(':final statusCode'));
      expect(output, contains(':final headers'));
      expect(output, contains(':final data'));
    });

    test('generates handler with CSP nonce access', () async {
      final output = await _generateForPage(
        fileName: 'nonce_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/nonce')
          class NoncePage extends SparkPage<void> {
          }
        ''',
      );

      expect(output, contains("req.context['spark.nonce'] as String?"));
    });

    test('generates cookie handling in PageRedirect branch', () async {
      final output = await _generateForPage(
        fileName: 'redirect2_page.dart',
        source: '''
          library a;
          import 'package:spark/spark.dart';

          @Page(path: '/redirect2')
          class Redirect2Page extends SparkPage<void> {
          }
        ''',
      );

      // Verify the redirect branch includes cookie-setting logic
      expect(
        output,
        contains('HttpHeaders.setCookieHeader: cookies.map((c) => c.toString()).toList()'),
      );
    });
  });
}
