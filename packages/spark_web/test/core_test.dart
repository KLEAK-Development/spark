import 'package:spark_web/spark_web.dart';
import 'package:test/test.dart';

void main() {
  group('MutationObserverInit', () {
    test('constructor sets properties correctly', () {
      const init = MutationObserverInit(
        childList: true,
        attributes: true,
        characterData: true,
        subtree: true,
        attributeOldValue: true,
        characterDataOldValue: true,
        attributeFilter: ['class', 'id'],
      );

      expect(init.childList, isTrue);
      expect(init.attributes, isTrue);
      expect(init.characterData, isTrue);
      expect(init.subtree, isTrue);
      expect(init.attributeOldValue, isTrue);
      expect(init.characterDataOldValue, isTrue);
      expect(init.attributeFilter, equals(['class', 'id']));
    });

    test('constructor defaults to null', () {
      const init = MutationObserverInit();
      expect(init.childList, isNull);
      expect(init.attributes, isNull);
      expect(init.characterData, isNull);
      expect(init.subtree, isNull);
      expect(init.attributeOldValue, isNull);
      expect(init.characterDataOldValue, isNull);
      expect(init.attributeFilter, isNull);
    });
  });

  group('Node constants', () {
    test('node types match MDN', () {
      expect(Node.ELEMENT_NODE, 1);
      expect(Node.TEXT_NODE, 3);
      expect(Node.COMMENT_NODE, 8);
      expect(Node.DOCUMENT_NODE, 9);
      expect(Node.DOCUMENT_FRAGMENT_NODE, 11);
    });
  });
}
