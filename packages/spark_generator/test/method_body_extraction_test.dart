import 'package:analyzer/dart/element/element.dart';
import 'package:spark_generator/src/component_generator.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'package:build/build.dart';

class TestComponentGenerator extends ComponentGenerator {
  Future<String?> testGetMethodSource(
    String methodName,
    AssetId inputId,
    String contents,
  ) async {
    final mockMethod = MockMethodElement(methodName);
    final mockBuildStep = MockBuildStep(inputId, contents);
    return await super.getMethodSource(mockMethod, mockBuildStep);
  }
}

class MockBuildStep implements BuildStep {
  @override
  final AssetId inputId;
  final String contents;
  MockBuildStep(this.inputId, this.contents);

  @override
  Future<String> readAsString(AssetId id, {Encoding encoding = utf8}) async {
    if (id == inputId) return contents;
    throw UnimplementedError();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
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
    late TestComponentGenerator generator;

    setUp(() async {
      generator = TestComponentGenerator();
    });

    test('extracts method with named parameters correctly', () async {
      final contents = '''
class Test {
  Future<void> _getCurrentPosition({bool highAccuracy = true}) async {
    print('body');
  }

  void anotherMethod() {}
}
''';
      final source = await generator.testGetMethodSource(
        '_getCurrentPosition',
        AssetId('a', 'lib/test_lib_base.dart'),
        contents,
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
      final contents = '''
class Test {
  void complexMethod({Map m = const {'a': 1}}) {
    if (true) {
      print('nested');
    }
  }
}
''';
      final source = await generator.testGetMethodSource(
        'complexMethod',
        AssetId('a', 'lib/test_lib_base.dart'),
        contents,
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
      final contents = '''
class Test {
  String format({String prefix = ''}) => '\$prefix: value';
}
''';
      final source = await generator.testGetMethodSource(
        'format',
        AssetId('a', 'lib/test_lib_base.dart'),
        contents,
      );

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
