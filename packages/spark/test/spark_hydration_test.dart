@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:spark_framework/src/component/spark_component.dart';
import 'package:spark_framework/src/component/web_component.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart' as html;
import 'package:spark_framework/src/style/style.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

// Define a simple component that uses styles and attributes
class TestInputComponent extends SparkComponent {
  static const tag = 'test-input-comp';

  @override
  String get tagName => tag;

  @override
  Stylesheet? get adoptedStyleSheets => css({':host': .typed(display: .block)});

  @override
  Map<String, String> get dumpedAttributes => {};

  @override
  List<String> get observedAttributes => ['value'];

  String _value = '';

  @override
  void syncAttributes() {
    _value = prop('value');
  }

  @override
  html.Element build() {
    return html.div([
      html.input(id: 'inner-input', attributes: {'value': _value}),
    ]);
  }
}

void main() {
  group('SparkComponent hydration with styles', () {
    late web.HTMLDivElement container;

    setUp(() {
      container = web.document.createElement('div') as web.HTMLDivElement;
      web.document.body!.appendChild(container);
      registerComponent(TestInputComponent.tag, TestInputComponent.new);
    });

    tearDown(() {
      container.remove();
    });

    test('preserves input element when hydrating with SSR styles', () async {
      // Simulate SSR structure:
      // <test-input-comp value="foo">
      //   <template shadowrootmode="open">
      //     <style>...</style>
      //     <div><input id="inner-input" value="foo"></div>
      //   </template>
      // </test-input-comp>

      final host =
          web.document.createElement(TestInputComponent.tag) as web.HTMLElement;
      host.setAttribute('value', 'foo');
      container.appendChild(host);

      // Manually attach shadow root and content to simulate DSD (Declarative Shadow DOM)
      // We process the options map to be JS interop compatible
      final shadow = host.attachShadow(
        _jsify({'mode': 'open'}) as web.ShadowRootInit,
      );

      final style = web.document.createElement('style');
      style.textContent = ':host { display: block; }';
      shadow.appendChild(style);

      final wrapper = web.document.createElement('div');
      final input = web.document.createElement('input') as web.HTMLInputElement;
      input.id = 'inner-input';
      input.value = 'foo';
      wrapper.appendChild(input);
      shadow.appendChild(wrapper);

      // Focus the input
      input.focus();
      expect(
        host.shadowRoot!.activeElement,
        input,
        reason: 'Input should be focused initially',
      );

      // Hydrate
      hydrateAll();

      // Wait for microtasks (updates)
      await Future.delayed(Duration.zero);

      // Check if input is preserved
      final newInput = host.shadowRoot!.getElementById('inner-input');

      expect(newInput, isNotNull);
      expect(
        newInput,
        equals(input),
        reason: 'Input element should be reused, not replaced',
      );
      expect(
        host.shadowRoot!.activeElement,
        input,
        reason: 'Input should remain focused',
      );
    });
  });
}

JSAny _jsify(Map map) {
  final obj = JSObject();
  for (final key in map.keys) {
    obj[key as String] = (map[key] as String).toJS;
  }
  return obj;
}
