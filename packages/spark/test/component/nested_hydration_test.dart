import 'package:spark_framework/src/component/web_component.dart';
import 'package:spark_framework/src/component/spark_component.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart' as html;
import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';
import 'package:spark_web/spark_web.dart' as web;

class ChildComponent extends WebComponent {
  static const tag = 'child-comp';
  @override
  String get tagName => tag;

  @override
  void onMount() {
    element.setAttribute('data-hydrated', 'true');
  }

  @override
  html.Element render() => html.div(['Child']);
}

class ChildWithStyles extends SparkComponent {
  static const tag = 'child-with-styles';
  @override
  String get tagName => tag;

  @override
  html.Element build() => html.div(['Styled Child']);

  @override
  Map<String, String> get dumpedAttributes => {};

  @override
  void syncAttributes() {}

  @override
  Stylesheet? get adoptedStyleSheets =>
      css({':host': .typed(display: .block, color: .hex('#ff0000'))});
}

class ParentComponent extends WebComponent {
  static const tag = 'parent-comp';
  @override
  String get tagName => tag;

  @override
  void onMount() {
    element.setAttribute('data-hydrated', 'true');
  }

  @override
  html.Element render() {
    return html.div([html.element(ChildComponent.tag, [])]);
  }
}

class DynamicSparkParent extends SparkComponent {
  static const tag = 'dynamic-spark-parent';
  @override
  String get tagName => tag;

  static DynamicSparkParent? lastInstance;

  DynamicSparkParent() {
    lastInstance = this;
  }

  bool _showChild = false;
  bool get showChild => _showChild;
  set showChild(bool v) {
    if (_showChild != v) {
      _showChild = v;
      update();
    }
  }

  @override
  html.Element build() {
    return html.div([if (_showChild) html.element(ChildComponent.tag, [])]);
  }

  @override
  Map<String, String> get dumpedAttributes => {};

  @override
  void syncAttributes() {}
}

class DynamicWithStylesParent extends SparkComponent {
  static const tag = 'dynamic-with-styles-parent';
  @override
  String get tagName => tag;

  bool _showChild = false;
  set showChild(bool v) {
    if (_showChild != v) {
      _showChild = v;
      update();
    }
  }

  @override
  html.Element build() {
    return html.div([if (_showChild) html.element(ChildWithStyles.tag, [])]);
  }

  @override
  Map<String, String> get dumpedAttributes => {};

  @override
  void syncAttributes() {}
}

void main() {
  group('Nested hydration', () {
    late web.HTMLDivElement container;

    setUp(() {
      container = web.document.createElement('div') as web.HTMLDivElement;
      web.document.body!.appendChild(container);
      registerComponent(ChildComponent.tag, ChildComponent.new);
      registerComponent(ChildWithStyles.tag, ChildWithStyles.new);
      registerComponent(ParentComponent.tag, ParentComponent.new);
      registerComponent(DynamicSparkParent.tag, DynamicSparkParent.new);
      registerComponent(
        DynamicWithStylesParent.tag,
        DynamicWithStylesParent.new,
      );
    });

    tearDown(() {
      container.remove();
    });

    test('hydrates nested components inside shadow root', () {
      // Create parent
      final parentHost =
          web.document.createElement(ParentComponent.tag) as web.HTMLElement;
      container.appendChild(parentHost);

      // Attach shadow root to parent (simulating DSD)
      final shadow = parentHost.attachShadow(
        const web.ShadowRootInit(mode: 'open'),
      );

      // Create child inside parent's shadow root
      final childHost =
          web.document.createElement(ChildComponent.tag) as web.HTMLElement;
      shadow.appendChild(childHost);

      // Hydrate all
      hydrateAll();

      expect(
        parentHost.getAttribute('data-hydrated'),
        equals('true'),
        reason: 'Parent should be hydrated',
      );
      expect(
        childHost.getAttribute('data-hydrated'),
        equals('true'),
        reason: 'Child inside shadow root should be hydrated',
      );
    });

    test('hydrates dynamically added nested components', () async {
      final parentHost =
          web.document.createElement(DynamicSparkParent.tag) as web.HTMLElement;
      container.appendChild(parentHost);

      // Attach shadow root
      parentHost.attachShadow(const web.ShadowRootInit(mode: 'open'));

      // Hydrate all - this will create the instance via factory
      hydrateAll();

      final parentComp = DynamicSparkParent.lastInstance;
      expect(parentComp, isNotNull);
      expect(parentComp!.element.raw, equals(parentHost.raw));

      expect(parentHost.shadowRoot!.querySelector(ChildComponent.tag), isNull);

      // Show child
      parentComp.showChild = true;

      final childHost = parentHost.shadowRoot!.querySelector(
        ChildComponent.tag,
      );
      expect(childHost, isNotNull, reason: 'Child should be rendered');

      // Hydration should have happened because update() calls hydrateAll()
      expect(
        childHost!.getAttribute('data-hydrated'),
        equals('true'),
        reason: 'Dynamically added child should be hydrated',
      );
    });

    test(
      'hydrates dynamically added styled components with shadow root',
      () async {
        final parentHost =
            web.document.createElement(DynamicWithStylesParent.tag)
                as web.HTMLElement;
        container.appendChild(parentHost);
        parentHost.attachShadow(const web.ShadowRootInit(mode: 'open'));

        // Initial hydration of parent
        hydrateAll();

        // We need to trigger update on the parent.
        // Since we don't have easy access to the instance from hydrateAll, let's use a similar trick.
        // Or just create it manually for the test.
        final parentComp = DynamicWithStylesParent();
        parentComp.hydrate(parentHost);

        parentComp.showChild = true;

        final childHost =
            parentHost.shadowRoot!.querySelector(ChildWithStyles.tag)
                as web.HTMLElement?;
        expect(childHost, isNotNull, reason: 'Child should be rendered');
        expect(
          childHost!.shadowRoot,
          isNotNull,
          reason: 'Dynamic child should have shadow root',
        );
        expect(
          childHost.shadowRoot!.adoptedStyleSheets,
          isNotEmpty,
          reason: 'Dynamic child should have styles',
        );
      },
    );
  });
}
