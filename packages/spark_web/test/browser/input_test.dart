@TestOn('browser')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('HTMLInputElement (Browser)', () {
    test('common properties', () {
      final input = web.document.createElement('input') as web.HTMLInputElement;
      input.type = 'text';
      expect(input.type, 'text');
      input.value = 'hello';
      expect(input.value, 'hello');
      input.name = 'my-input';
      expect(input.name, 'my-input');
      input.disabled = true;
      expect(input.disabled, isTrue);
      input.required = true;
      expect(input.required, isTrue);
      input.autofocus = true;
      expect(input.autofocus, isTrue);
      
      expect(input.validity, isNotNull);
      expect(input.validity.valid, isTrue);
    });

    test('specialized interfaces', () {
      final input = web.document.createElement('input') as web.HTMLInputElement;
      input.type = 'number';
      
      final numInput = input as web.HTMLNumericInputElement;
      numInput.min = '0';
      numInput.max = '100';
      numInput.step = '1';
      expect(numInput.min, '0');
      expect(numInput.max, '100');
      
      numInput.value = '50';
      expect(numInput.valueAsNumber, 50);
      
      input.type = 'checkbox';
      final checkInput = input as web.HTMLCheckableInputElement;
      checkInput.checked = true;
      expect(checkInput.checked, isTrue);
      
      input.type = 'text';
      final textInput = input as web.HTMLTextInputElement;
      textInput.placeholder = 'Search...';
      expect(textInput.placeholder, 'Search...');
      textInput.maxLength = 10;
      expect(textInput.maxLength, 10);
    });

    test('selection properties', () {
      final input = web.document.createElement('input') as web.HTMLTextInputElement;
      input.type = 'text';
      web.document.body!.appendChild(input);
      input.value = 'abcdefghij';
      input.select();
      
      // Some browsers might not support these if not focused
      input.focus();
      input.setSelectionRange(2, 5);
      expect(input.selectionStart, 2);
      expect(input.selectionEnd, 5);
      
      input.remove();
    });
  });
}
