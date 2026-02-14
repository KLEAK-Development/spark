import 'package:test/test.dart';
import 'package:spark_css/spark_css.dart';
import 'package:spark_framework/src/component/web_component.dart';

void main() {
  group('AdoptedStyleSheets', () {
    setUp(() {
      // Clear cache before each test
      clearStyleSheetCache();
    });

    test('createStyleSheet creates a CSSStyleSheet', () {
      const css = ':host { display: block; }';
      final sheet = createStyleSheet(css);
      expect(sheet, isNotNull);
    });

    test('createStyleSheet caches stylesheets', () {
      const css = ':host { display: block; }';

      final sheet1 = createStyleSheet(css);
      final sheet2 = createStyleSheet(css);

      // Should return the same cached instance
      expect(identical(sheet1, sheet2), isTrue);
    });

    test('different CSS creates different stylesheets', () {
      const css1 = ':host { display: block; }';
      const css2 = ':host { display: flex; }';

      final sheet1 = createStyleSheet(css1);
      final sheet2 = createStyleSheet(css2);

      expect(identical(sheet1, sheet2), isFalse);
    });

    test('clearStyleSheetCache clears the cache', () {
      const css = ':host { display: block; }';

      final sheet1 = createStyleSheet(css);
      clearStyleSheetCache();
      final sheet2 = createStyleSheet(css);

      // After clearing, should create a new instance
      expect(identical(sheet1, sheet2), isFalse);
    });

    test('createStyleSheet handles complex CSS rules', () {
      final stylesheet = css({
        ':host': Style.typed(
          display: CssDisplay.block,
          padding: CssSpacing.all(CssLength.px(16)),
        ),
        'button': Style.typed(
          backgroundColor: CssColor.hex('#2196f3'),
          color: CssColor.white,
        ),
      });

      final cssText = stylesheet.toCss();
      final sheet = createStyleSheet(cssText);

      expect(sheet, isNotNull);
    });
  });
}
