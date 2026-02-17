import 'package:analyzer/dart/element/element.dart';
import 'package:spark_generator/src/component_generator.dart';
import 'package:test/test.dart';
import 'dart:io';

class TestComponentGenerator extends ComponentGenerator {
  String? testGetMethodSource(String methodName, String sourceFilePath) {
    final mockMethod = MockMethodElement(methodName);
    return super.getMethodSource(mockMethod, sourceFilePath);
  }
}

class MockMethodElement implements MethodElement {
  @override
  final String? name;
  MockMethodElement(this.name);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('Method Body Extraction', () {
    late Directory tempDir;
    late TestComponentGenerator generator;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('spark_gen_test');
      generator = TestComponentGenerator();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('extracts method with named parameters correctly', () async {
      final sourceFile = File('${tempDir.path}/test_base.dart');
      await sourceFile.writeAsString('''
class Test {
  Future<void> _getCurrentPosition({bool highAccuracy = true}) async {
    print('body');
  }
  
  void anotherMethod() {}
}
''');

      final source = generator.testGetMethodSource(
        '_getCurrentPosition',
        sourceFile.path,
      );

      expect(
        source,
        contains(
          "Future<void> _getCurrentPosition({bool highAccuracy = true}) async {",
        ),
      );
      expect(source, contains("print('body');"));
      expect(source, contains("}"));
      // Ensure it has the full body and closing brace
      expect(source?.trim().endsWith('}'), isTrue);
    });

    test('extracts method with multiple sets of braces correctly', () async {
      final sourceFile = File('${tempDir.path}/test_base.dart');
      await sourceFile.writeAsString('''
class Test {
  void complexMethod({Map m = const {'a': 1}}) {
    if (true) {
      print('nested');
    }
  }
}
''');

      final source = generator.testGetMethodSource(
        'complexMethod',
        sourceFile.path,
      );

      expect(
        source,
        contains("void complexMethod({Map m = const {'a': 1}}) {"),
      );
      expect(source, contains("print('nested');"));
      expect(source?.trim().endsWith('}'), isTrue);
      // Count braces: one for Map, one for if, one for method = 3 opening, 3 closing.
      // The extracted source should have the whole thing.
    });

    test('extracts arrow function with named parameters correctly', () async {
      final sourceFile = File('${tempDir.path}/test_base.dart');
      await sourceFile.writeAsString('''
class Test {
  String format({String prefix = ''}) => '\$prefix: value';
}
''');

      final source = generator.testGetMethodSource('format', sourceFile.path);

      expect(
        source,
        contains("String format({String prefix = ''}) => '\$prefix: value';"),
      );
    });
  });
}

// Mocking MethodElement properly to avoid type errors if possible,
// or just use dynamic if the generator uses it dynamically.
// Looking at the generator, it uses method.name.
