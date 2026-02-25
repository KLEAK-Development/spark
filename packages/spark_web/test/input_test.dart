@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('HTMLInputElement (Server)', () {
    test('instantiates and has common properties', () {
      final input = web.document.createElement('input') as web.HTMLInputElement;
      input.type = 'text';
      input.value = 'hello';
      input.name = 'my-input';
      input.disabled = true;
      input.required = true;
      input.autofocus = true;

      expect(input.type, ''); // Server defaults to empty string
      expect(input.value, '');
      expect(input.name, '');
      expect(input.disabled, isFalse);
      expect(input.required, isFalse);
      expect(input.autofocus, isFalse);
      expect(input.form, isNull);
      expect(input.labels.length, 0);
      expect(input.willValidate, isTrue);
      expect(input.validity.valid, isTrue);
      expect(input.validationMessage, '');
    });

    test('can be cast to specialized interfaces', () {
      final input = web.document.createElement('input') as web.HTMLInputElement;
      
      final textInput = input as web.HTMLTextInputElement;
      textInput.placeholder = 'foo';
      expect(textInput.placeholder, '');

      final numInput = input as web.HTMLNumericInputElement;
      numInput.min = '0';
      numInput.max = '100';
      expect(numInput.min, '');

      final checkInput = input as web.HTMLCheckableInputElement;
      checkInput.checked = true;
      expect(checkInput.checked, isFalse);

      final fileInput = input as web.HTMLFileInputElement;
      expect(fileInput.files, isNotNull);
      expect(fileInput.files!.length, 0);

      final buttonInput = input as web.HTMLButtonInputElement;
      buttonInput.alt = 'alt';
      expect(buttonInput.alt, '');
    });
  });
}
