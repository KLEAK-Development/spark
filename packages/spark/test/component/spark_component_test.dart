import 'package:spark_framework/spark.dart';
import 'package:test/test.dart';

class SimpleComponent extends SparkComponent {
  @override
  String get tagName => 'simple-comp';

  @override
  Element build() => div(['Hello']);

  @override
  Map<String, String> get dumpedAttributes => {'data-test': 'true'};

  @override
  Stylesheet? get adoptedStyleSheets =>
      css({':host': Style.typed(display: CssDisplay.block)});
}

void main() {
  group('SparkComponent', () {
    test('render produces correct HTML with DSD and styles', () {
      final component = SimpleComponent();
      final htmlNode = component.render();
      final html = htmlNode.toHtml();

      if (kIsBrowser) {
        expect(html, equals('<simple-comp data-test="true"></simple-comp>'));
      } else {
        expect(html, contains('<simple-comp data-test="true">'));
        expect(html, contains('<template shadowrootmode="open">'));
        expect(html, contains('<style>'));
        expect(html, contains(':host {'));
        expect(html, contains('display: block;'));
        expect(html, contains('<div>Hello</div>'));
      }
    });

    test('scheduleUpdate does nothing on server', () {
      final component = SimpleComponent();
      expect(() => component.scheduleUpdate(), returnsNormally);
    });

    test('update does nothing on server (not hydrated)', () {
      final component = SimpleComponent();
      expect(() => component.update(), returnsNormally);
    });
  });
}
