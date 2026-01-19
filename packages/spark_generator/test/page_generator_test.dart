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

void main() {
  group('PageGenerator', () {
    test('generates handler for simple page', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/page.dart': '''
          class Page {
            final String path;
            final List<String> methods;
            const Page({required this.path, this.methods = const ['GET']});
          }
        ''',
          'spark|lib/src/page/spark_page.dart': '''
           abstract class SparkPage<T> {
            List<dynamic> get middleware => [];
            Future<void> loader(dynamic request);
            dynamic render(dynamic data);
            dynamic get components => [];
          }
        ''',
          'spark|lib/spark.dart': '''
          library spark;
          export 'src/annotations/page.dart';
          export 'src/page/spark_page.dart';
        ''',
          'a|lib/home_page.dart': '''
          library a;
          import 'package:spark/spark.dart';
          
          @Page(path: '/')
          class HomePage extends SparkPage<void> {
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/home_page.dart'),
          );
          // PageGenerator expects package:spark/src/annotations/page.dart#Page
          // We can pass the annotation reader manually, but we need the annotation to be recognized.
          // GeneratorForAnnotation typically checks type.
          // But here we invoke generateForAnnotatedElement manually.
          // We just need to find the annotation on the element.
          // We can use TypeChecker with the mocked URL.

          final children = (libraryElement as dynamic).children as List;
          final homePage = children.firstWhere(
            (e) => (e as dynamic).name == 'HomePage',
          );

          final annotations =
              (homePage as dynamic).metadata.annotations as List;
          final annotation = annotations.firstWhere((a) {
            final element = (a as dynamic).element;
            final enclosing = (element as dynamic)?.enclosingElement;
            return (enclosing as dynamic)?.name == 'Page';
          });

          final constantReader = ConstantReader(
            (annotation as dynamic).computeConstantValue(),
          );

          final generator = PageGenerator();
          final output = generator.generateForAnnotatedElement(
            homePage,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/home_page.dart')),
          );

          expect(output, contains('Future<Response> _\$handleHomePage'));
          expect(output, contains("path: '/'"));
        },
      );
    });

    test('generates handler with path parameters', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/page.dart': '''
          class Page {
            final String path;
            final List<String> methods;
            const Page({required this.path, this.methods = const ['GET']});
          }
        ''',
          'spark|lib/src/page/spark_page.dart': '''
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
          'a|lib/user_page.dart': '''
          library a;
          import 'package:spark/spark.dart';
          
          @Page(path: '/users/:id')
          class UserPage extends SparkPage<String> {
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/user_page.dart'),
          );
          final children = (libraryElement as dynamic).children as List;
          final userPage = children.firstWhere(
            (e) => (e as dynamic).name == 'UserPage',
          );

          final annotations =
              (userPage as dynamic).metadata.annotations as List;
          final annotation = annotations.firstWhere((a) {
            final element = (a as dynamic).element;
            final enclosing = (element as dynamic)?.enclosingElement;
            return (enclosing as dynamic)?.name == 'Page';
          });
          final constantReader = ConstantReader(
            (annotation as dynamic).computeConstantValue(),
          );

          final generator = PageGenerator();
          final output = generator.generateForAnnotatedElement(
            userPage,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/user_page.dart')),
          );

          expect(output, contains('Future<Response> _\$handleUserPage'));
          expect(output, contains("path: '/users/<id>'"));
          expect(output, contains('String id'));
          expect(output, contains("'id': id"));
        },
      );
    });
    test('generates script included for page inheriting components', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/page.dart': '''
          class Page {
            final String path;
            final List<String> methods;
            const Page({required this.path, this.methods = const ['GET']});
          }
        ''',
          'spark|lib/src/page/spark_page.dart': '''
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
          'a|lib/inheritance_page.dart': '''
          library a;
          import 'package:spark/spark.dart';
          
          abstract class ParentPage extends SparkPage<void> {
             @override
             dynamic get components => ['comp'];
          }

          @Page(path: '/child')
          class ChildPage extends ParentPage {
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/inheritance_page.dart'),
          );
          final children = (libraryElement as dynamic).children as List;
          final childPage = children.firstWhere(
            (e) => (e as dynamic).name == 'ChildPage',
          );

          final annotations =
              (childPage as dynamic).metadata.annotations as List;
          final annotation = annotations.firstWhere((a) {
            final element = (a as dynamic).element;
            final enclosing = (element as dynamic)?.enclosingElement;
            return (enclosing as dynamic)?.name == 'Page';
          });
          final constantReader = ConstantReader(
            (annotation as dynamic).computeConstantValue(),
          );

          final generator = PageGenerator();
          final output = generator.generateForAnnotatedElement(
            childPage,
            constantReader,
            // Simulate file path to check relative path logic if needed,
            // but here we just check if a script name is generated at all.
            SimpleBuildStep(AssetId('a', 'lib/inheritance_page.dart')),
          );

          // It should contain the script name derived from the file name.
          // Since input is lib/inheritance_page.dart, script is inheritance_page.dart.js
          expect(output, contains('inheritance_page.dart.js'));
        },
      );
    });
  });
}
