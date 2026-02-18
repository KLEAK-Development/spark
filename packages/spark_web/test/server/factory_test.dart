@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Server Factory', () {
    test('createMutationObserver', () {
      final observer = web.createMutationObserver((_, __) {});
      observer.observe(web.document.createElement('div'));
      observer.disconnect();
      expect(observer.takeRecords(), isEmpty);
    });

    test('createEvent types', () {
      expect(web.createEvent('foo'), isA<web.Event>());
      expect(web.createMouseEvent('click'), isA<web.MouseEvent>());
      expect(web.createKeyboardEvent('keydown'), isA<web.KeyboardEvent>());
      expect(web.createFocusEvent('focus'), isA<web.FocusEvent>());
      expect(web.createInputEvent('input'), isA<web.InputEvent>());
      expect(web.createWheelEvent('wheel'), isA<web.WheelEvent>());
      expect(web.createPointerEvent('pointerdown'), isA<web.PointerEvent>());
      expect(web.createTouchEvent('touchstart'), isA<web.TouchEvent>());
      expect(web.createDragEvent('drag'), isA<web.DragEvent>());
      expect(
        web.createAnimationEvent('animationend'),
        isA<web.AnimationEvent>(),
      );
      expect(
        web.createTransitionEvent('transitionend'),
        isA<web.TransitionEvent>(),
      );
      expect(
        web.createCustomEvent('custom', {'foo': 'bar'}),
        isA<web.CustomEvent>(),
      );
    });

    test('Other events', () {
      // These don't have factory functions yet but classes exist in factory.dart
      // (Wait, they are in factory.dart but not exported as factory functions?)
      // Actually they are just classes in factory.dart.
    });
  });

  group('Server Events', () {
    test('ServerEvent properties', () {
      final e = web.createEvent('click');
      expect(e.type, 'click');
      expect(e.target, isNull);
      expect(e.currentTarget, isNull);
      expect(e.bubbles, isFalse);
      expect(e.cancelable, isFalse);
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      expect(e.raw, isNull);
    });

    test('ServerMouseEvent', () {
      final e = web.createMouseEvent('click');
      expect(e.clientX, 0);
      expect(e.clientY, 0);
      expect(e.pageX, 0);
      expect(e.pageY, 0);
      expect(e.screenX, 0);
      expect(e.screenY, 0);
      expect(e.button, 0);
      expect(e.buttons, 0);
      expect(e.altKey, isFalse);
      expect(e.ctrlKey, isFalse);
      expect(e.metaKey, isFalse);
      expect(e.shiftKey, isFalse);
    });

    test('ServerKeyboardEvent', () {
      final e = web.createKeyboardEvent('keydown');
      expect(e.key, '');
      expect(e.code, '');
      expect(e.altKey, isFalse);
      expect(e.ctrlKey, isFalse);
      expect(e.metaKey, isFalse);
      expect(e.shiftKey, isFalse);
      expect(e.repeat, isFalse);
      expect(e.location, 0);
    });

    test('ServerInputEvent', () {
      final e = web.createInputEvent('input');
      expect(e.data, isNull);
      expect(e.inputType, '');
      expect(e.isComposing, isFalse);
    });

    test('ServerFocusEvent', () {
      final e = web.createFocusEvent('focus');
      expect(e.relatedTarget, isNull);
    });

    test('ServerWheelEvent', () {
      final e = web.createWheelEvent('wheel');
      expect(e.deltaX, 0);
      expect(e.deltaY, 0);
      expect(e.deltaZ, 0);
      expect(e.deltaMode, 0);
    });

    test('ServerPointerEvent', () {
      final e = web.createPointerEvent('pointerdown');
      expect(e.pointerId, 0);
      expect(e.width, 1);
      expect(e.height, 1);
      expect(e.pressure, 0);
      expect(e.tangentialPressure, 0);
      expect(e.tiltX, 0);
      expect(e.tiltY, 0);
      expect(e.twist, 0);
      expect(e.pointerType, '');
      expect(e.isPrimary, isFalse);
    });

    test('ServerTouchEvent', () {
      final e = web.createTouchEvent('touchstart');
      expect(e.touches.length, 0);
      expect(e.targetTouches.length, 0);
      expect(e.changedTouches.length, 0);
      expect(e.altKey, isFalse);
      expect(e.ctrlKey, isFalse);
      expect(e.metaKey, isFalse);
      expect(e.shiftKey, isFalse);
    });

    test('ServerDragEvent', () {
      final e = web.createDragEvent('drag');
      final dt = e.dataTransfer!;
      expect(dt.dropEffect, 'none');
      dt.dropEffect = 'move';
      expect(dt.effectAllowed, 'uninitialized');
      dt.effectAllowed = 'all';
      expect(dt.types, isEmpty);
      dt.setData('text/plain', 'foo');
      expect(dt.getData('text/plain'), '');
      dt.clearData();
    });

    test('ServerTouch and TouchList', () {
      final e = web.createTouchEvent('touchstart');
      expect(e.touches.item(0), isNull);

      // We can't easily create ServerTouch because it's not exposed,
      // but we can test the class if we could instantiate it.
      // Since it's in factory.dart (private to lib/src), we can't.
      // But we can test ServerTouchList length.
      expect(e.touches.length, 0);
    });

    test('ServerAnimationEvent', () {
      final e = web.createAnimationEvent('animationend');
      expect(e.animationName, '');
      expect(e.elapsedTime, 0);
      expect(e.pseudoElement, '');
    });

    test('ServerTransitionEvent', () {
      final e = web.createTransitionEvent('transitionend');
      expect(e.propertyName, '');
      expect(e.elapsedTime, 0);
      expect(e.pseudoElement, '');
    });

    test('ServerCustomEvent', () {
      final detail = {'foo': 'bar'};
      final e = web.createCustomEvent('custom', detail);
      expect(e.detail, equals(detail));
    });
  });
}
