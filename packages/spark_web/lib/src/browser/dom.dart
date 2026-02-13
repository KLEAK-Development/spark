/// Browser implementations of DOM types wrapping `package:web`.
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../canvas.dart' as iface;
import '../core.dart';
import '../dom.dart' as iface;
import '../collections.dart';
import '../css.dart';
import 'canvas.dart';
import 'collections.dart';
import 'css.dart';

// ---------------------------------------------------------------------------
// Wrapping utilities
// ---------------------------------------------------------------------------

/// Wraps a native `web.Node` into the appropriate spark_web type.
Node wrapNode(web.Node node) {
  if ((node as JSAny?).isA<web.ShadowRoot>()) {
    return BrowserShadowRoot(node as web.ShadowRoot);
  }
  if ((node as JSAny?).isA<web.DocumentFragment>()) {
    return BrowserDocumentFragment(node as web.DocumentFragment);
  }
  if ((node as JSAny?).isA<web.Document>()) {
    return BrowserDocument(node as web.Document);
  }
  if ((node as JSAny?).isA<web.HTMLInputElement>()) {
    return BrowserHTMLInputElement(node as web.HTMLInputElement);
  }
  if ((node as JSAny?).isA<web.HTMLButtonElement>()) {
    return BrowserHTMLButtonElement(node as web.HTMLButtonElement);
  }
  if ((node as JSAny?).isA<web.HTMLTextAreaElement>()) {
    return BrowserHTMLTextAreaElement(node as web.HTMLTextAreaElement);
  }
  if ((node as JSAny?).isA<web.HTMLSelectElement>()) {
    return BrowserHTMLSelectElement(node as web.HTMLSelectElement);
  }
  if ((node as JSAny?).isA<web.HTMLOptionElement>()) {
    return BrowserHTMLOptionElement(node as web.HTMLOptionElement);
  }
  if ((node as JSAny?).isA<web.HTMLAnchorElement>()) {
    return BrowserHTMLAnchorElement(node as web.HTMLAnchorElement);
  }
  if ((node as JSAny?).isA<web.HTMLImageElement>()) {
    return BrowserHTMLImageElement(node as web.HTMLImageElement);
  }
  if ((node as JSAny?).isA<web.HTMLFormElement>()) {
    return BrowserHTMLFormElement(node as web.HTMLFormElement);
  }
  if ((node as JSAny?).isA<web.HTMLLabelElement>()) {
    return BrowserHTMLLabelElement(node as web.HTMLLabelElement);
  }
  if ((node as JSAny?).isA<web.HTMLTemplateElement>()) {
    return BrowserHTMLTemplateElement(node as web.HTMLTemplateElement);
  }
  if ((node as JSAny?).isA<web.HTMLCanvasElement>()) {
    return BrowserHTMLCanvasElement(node as web.HTMLCanvasElement);
  }
  if ((node as JSAny?).isA<web.HTMLVideoElement>()) {
    return BrowserHTMLVideoElement(node as web.HTMLVideoElement);
  }
  if ((node as JSAny?).isA<web.HTMLAudioElement>()) {
    return BrowserHTMLAudioElement(node as web.HTMLAudioElement);
  }
  if ((node as JSAny?).isA<web.HTMLDialogElement>()) {
    return BrowserHTMLDialogElement(node as web.HTMLDialogElement);
  }
  if ((node as JSAny?).isA<web.HTMLDetailsElement>()) {
    return BrowserHTMLDetailsElement(node as web.HTMLDetailsElement);
  }
  if ((node as JSAny?).isA<web.HTMLSlotElement>()) {
    return BrowserHTMLSlotElement(node as web.HTMLSlotElement);
  }
  if ((node as JSAny?).isA<web.HTMLIFrameElement>()) {
    return BrowserHTMLIFrameElement(node as web.HTMLIFrameElement);
  }
  if ((node as JSAny?).isA<web.HTMLTableElement>()) {
    return BrowserHTMLTableElement(node as web.HTMLTableElement);
  }
  if ((node as JSAny?).isA<web.HTMLTableRowElement>()) {
    return BrowserHTMLTableRowElement(node as web.HTMLTableRowElement);
  }
  if ((node as JSAny?).isA<web.HTMLTableCellElement>()) {
    return BrowserHTMLTableCellElement(node as web.HTMLTableCellElement);
  }
  if ((node as JSAny?).isA<web.HTMLProgressElement>()) {
    return BrowserHTMLProgressElement(node as web.HTMLProgressElement);
  }
  if ((node as JSAny?).isA<web.HTMLMeterElement>()) {
    return BrowserHTMLMeterElement(node as web.HTMLMeterElement);
  }
  if ((node as JSAny?).isA<web.HTMLOutputElement>()) {
    return BrowserHTMLOutputElement(node as web.HTMLOutputElement);
  }
  if ((node as JSAny?).isA<web.HTMLOListElement>()) {
    return BrowserHTMLOListElement(node as web.HTMLOListElement);
  }
  if ((node as JSAny?).isA<web.HTMLLIElement>()) {
    return BrowserHTMLLIElement(node as web.HTMLLIElement);
  }
  if ((node as JSAny?).isA<web.HTMLElement>()) {
    return BrowserHTMLElement(node as web.HTMLElement);
  }
  if ((node as JSAny?).isA<web.Element>()) {
    return BrowserElement(node as web.Element);
  }
  if (node.nodeType == 3) {
    return BrowserText(node as web.Text);
  }
  if (node.nodeType == 8) {
    return BrowserComment(node as web.Comment);
  }
  return BrowserNode(node);
}

/// Wraps a native `web.Element` into the appropriate spark_web Element type.
iface.Element wrapElement(web.Element el) => wrapNode(el) as iface.Element;

/// Wraps a native `web.Event` into a spark_web Event.
Event wrapEvent(web.Event e) {
  // Check most specific types first.
  if ((e as JSAny?).isA<web.PointerEvent>()) {
    return BrowserPointerEvent(e as web.PointerEvent);
  }
  if ((e as JSAny?).isA<web.WheelEvent>()) {
    return BrowserWheelEvent(e as web.WheelEvent);
  }
  if ((e as JSAny?).isA<web.DragEvent>()) {
    return BrowserDragEvent(e as web.DragEvent);
  }
  if ((e as JSAny?).isA<web.MouseEvent>()) {
    return BrowserMouseEvent(e as web.MouseEvent);
  }
  if ((e as JSAny?).isA<web.KeyboardEvent>()) {
    return BrowserKeyboardEvent(e as web.KeyboardEvent);
  }
  if ((e as JSAny?).isA<web.InputEvent>()) {
    return BrowserInputEvent(e as web.InputEvent);
  }
  if ((e as JSAny?).isA<web.FocusEvent>()) {
    return BrowserFocusEvent(e as web.FocusEvent);
  }
  if ((e as JSAny?).isA<web.TouchEvent>()) {
    return BrowserTouchEvent(e as web.TouchEvent);
  }
  if ((e as JSAny?).isA<web.AnimationEvent>()) {
    return BrowserAnimationEvent(e as web.AnimationEvent);
  }
  if ((e as JSAny?).isA<web.TransitionEvent>()) {
    return BrowserTransitionEvent(e as web.TransitionEvent);
  }
  if ((e as JSAny?).isA<web.CustomEvent>()) {
    return BrowserCustomEvent(e as web.CustomEvent);
  }
  return BrowserEvent(e);
}

/// Wraps a native `web.EventTarget` into the appropriate spark_web EventTarget type.
EventTarget wrapEventTarget(web.EventTarget target) {
  if ((target as JSAny?).isA<web.Node>()) {
    return wrapNode(target as web.Node);
  }
  // TODO: Add Window support if needed
  return BrowserEventTarget(target);
}

// ---------------------------------------------------------------------------
// EventTarget
// ---------------------------------------------------------------------------

class BrowserEventTarget implements EventTarget {
  final web.EventTarget _native;
  BrowserEventTarget(this._native);

  @override
  dynamic get raw => _native;

  @override
  void addEventListener(String type, EventListener? callback) {
    if (callback == null) return;
    _native.addEventListener(
      type,
      ((web.Event e) => callback(wrapEvent(e))).toJS,
    );
  }

  @override
  void removeEventListener(String type, EventListener? callback) {
    // Note: removing requires the same JS function reference.
    // For full support, callers should use the framework's event system.
  }

  @override
  bool dispatchEvent(Event event) {
    if (event.raw is web.Event) {
      return _native.dispatchEvent(event.raw as web.Event);
    }
    return false;
  }
}

// ---------------------------------------------------------------------------
// Event
// ---------------------------------------------------------------------------

class BrowserEvent implements Event {
  final web.Event _native;
  BrowserEvent(this._native);

  @override
  dynamic get raw => _native;
  @override
  String get type => _native.type;
  @override
  EventTarget? get target {
    final t = _native.target;
    return t != null ? wrapEventTarget(t) : null;
  }

  @override
  EventTarget? get currentTarget {
    final t = _native.currentTarget;
    return t != null ? wrapEventTarget(t) : null;
  }

  @override
  bool get bubbles => _native.bubbles;
  @override
  bool get cancelable => _native.cancelable;
  @override
  void preventDefault() => _native.preventDefault();
  @override
  void stopPropagation() => _native.stopPropagation();
  @override
  void stopImmediatePropagation() => _native.stopImmediatePropagation();
}

class BrowserMouseEvent extends BrowserEvent implements MouseEvent {
  final web.MouseEvent _nativeMouse;
  BrowserMouseEvent(this._nativeMouse) : super(_nativeMouse);

  @override
  double get clientX => _nativeMouse.clientX.toDouble();
  @override
  double get clientY => _nativeMouse.clientY.toDouble();
  @override
  double get pageX => _nativeMouse.pageX.toDouble();
  @override
  double get pageY => _nativeMouse.pageY.toDouble();
  @override
  double get screenX => _nativeMouse.screenX.toDouble();
  @override
  double get screenY => _nativeMouse.screenY.toDouble();
  @override
  int get button => _nativeMouse.button;
  @override
  int get buttons => _nativeMouse.buttons;
  @override
  bool get altKey => _nativeMouse.altKey;
  @override
  bool get ctrlKey => _nativeMouse.ctrlKey;
  @override
  bool get metaKey => _nativeMouse.metaKey;
  @override
  bool get shiftKey => _nativeMouse.shiftKey;
}

class BrowserKeyboardEvent extends BrowserEvent implements KeyboardEvent {
  final web.KeyboardEvent _nativeKb;
  BrowserKeyboardEvent(this._nativeKb) : super(_nativeKb);

  @override
  String get key => _nativeKb.key;
  @override
  String get code => _nativeKb.code;
  @override
  bool get altKey => _nativeKb.altKey;
  @override
  bool get ctrlKey => _nativeKb.ctrlKey;
  @override
  bool get metaKey => _nativeKb.metaKey;
  @override
  bool get shiftKey => _nativeKb.shiftKey;
  @override
  bool get repeat => _nativeKb.repeat;
  @override
  int get location => _nativeKb.location;
}

class BrowserInputEvent extends BrowserEvent implements InputEvent {
  final web.InputEvent _nativeInput;
  BrowserInputEvent(this._nativeInput) : super(_nativeInput);

  @override
  String? get data => _nativeInput.data;
  @override
  String get inputType => _nativeInput.inputType;
  @override
  bool get isComposing => _nativeInput.isComposing;
}

class BrowserFocusEvent extends BrowserEvent implements FocusEvent {
  final web.FocusEvent _nativeFocus;
  BrowserFocusEvent(this._nativeFocus) : super(_nativeFocus);

  @override
  EventTarget? get relatedTarget {
    final t = _nativeFocus.relatedTarget;
    return t != null ? wrapEventTarget(t) : null;
  }
}

class BrowserWheelEvent extends BrowserMouseEvent implements WheelEvent {
  final web.WheelEvent _nativeWheel;
  BrowserWheelEvent(this._nativeWheel) : super(_nativeWheel);

  @override
  double get deltaX => _nativeWheel.deltaX;
  @override
  double get deltaY => _nativeWheel.deltaY;
  @override
  double get deltaZ => _nativeWheel.deltaZ;
  @override
  int get deltaMode => _nativeWheel.deltaMode;
}

class BrowserPointerEvent extends BrowserMouseEvent implements PointerEvent {
  final web.PointerEvent _nativePointer;
  BrowserPointerEvent(this._nativePointer) : super(_nativePointer);

  @override
  int get pointerId => _nativePointer.pointerId;
  @override
  double get width => _nativePointer.width;
  @override
  double get height => _nativePointer.height;
  @override
  double get pressure => _nativePointer.pressure;
  @override
  double get tangentialPressure => _nativePointer.tangentialPressure;
  @override
  int get tiltX => _nativePointer.tiltX;
  @override
  int get tiltY => _nativePointer.tiltY;
  @override
  int get twist => _nativePointer.twist;
  @override
  String get pointerType => _nativePointer.pointerType;
  @override
  bool get isPrimary => _nativePointer.isPrimary;
}

class BrowserTouchEvent extends BrowserEvent implements TouchEvent {
  final web.TouchEvent _nativeTouch;
  BrowserTouchEvent(this._nativeTouch) : super(_nativeTouch);

  @override
  TouchList get touches => BrowserTouchList(_nativeTouch.touches);
  @override
  TouchList get targetTouches => BrowserTouchList(_nativeTouch.targetTouches);
  @override
  TouchList get changedTouches => BrowserTouchList(_nativeTouch.changedTouches);
  @override
  bool get altKey => _nativeTouch.altKey;
  @override
  bool get ctrlKey => _nativeTouch.ctrlKey;
  @override
  bool get metaKey => _nativeTouch.metaKey;
  @override
  bool get shiftKey => _nativeTouch.shiftKey;
}

class BrowserDragEvent extends BrowserMouseEvent implements DragEvent {
  final web.DragEvent _nativeDrag;
  BrowserDragEvent(this._nativeDrag) : super(_nativeDrag);

  @override
  DataTransfer? get dataTransfer {
    final dt = _nativeDrag.dataTransfer;
    return dt != null ? BrowserDataTransfer(dt) : null;
  }
}

class BrowserAnimationEvent extends BrowserEvent implements AnimationEvent {
  final web.AnimationEvent _nativeAnim;
  BrowserAnimationEvent(this._nativeAnim) : super(_nativeAnim);

  @override
  String get animationName => _nativeAnim.animationName;
  @override
  double get elapsedTime => _nativeAnim.elapsedTime;
  @override
  String get pseudoElement => _nativeAnim.pseudoElement;
}

class BrowserTransitionEvent extends BrowserEvent implements TransitionEvent {
  final web.TransitionEvent _nativeTrans;
  BrowserTransitionEvent(this._nativeTrans) : super(_nativeTrans);

  @override
  String get propertyName => _nativeTrans.propertyName;
  @override
  double get elapsedTime => _nativeTrans.elapsedTime;
  @override
  String get pseudoElement => _nativeTrans.pseudoElement;
}

class BrowserCustomEvent extends BrowserEvent implements CustomEvent {
  final web.CustomEvent _nativeCustom;
  BrowserCustomEvent(this._nativeCustom) : super(_nativeCustom);

  @override
  Object? get detail => _nativeCustom.detail.dartify();
}

// ---------------------------------------------------------------------------
// Node
// ---------------------------------------------------------------------------

class BrowserNode extends BrowserEventTarget implements Node {
  final web.Node _nativeNode;
  BrowserNode(this._nativeNode) : super(_nativeNode);

  @override
  dynamic get raw => _nativeNode;
  @override
  int get nodeType => _nativeNode.nodeType;
  @override
  String get nodeName => _nativeNode.nodeName;
  @override
  Node? get parentNode {
    final p = _nativeNode.parentNode;
    return p != null ? wrapNode(p) : null;
  }

  @override
  Node? get parentElement {
    final p = _nativeNode.parentElement;
    return p != null ? wrapNode(p) : null;
  }

  @override
  NodeList get childNodes => BrowserNodeList(_nativeNode.childNodes);
  @override
  Node? get firstChild {
    final c = _nativeNode.firstChild;
    return c != null ? wrapNode(c) : null;
  }

  @override
  Node? get lastChild {
    final c = _nativeNode.lastChild;
    return c != null ? wrapNode(c) : null;
  }

  @override
  Node? get nextSibling {
    final s = _nativeNode.nextSibling;
    return s != null ? wrapNode(s) : null;
  }

  @override
  Node? get previousSibling {
    final s = _nativeNode.previousSibling;
    return s != null ? wrapNode(s) : null;
  }

  @override
  String? get textContent => _nativeNode.textContent;
  @override
  set textContent(String? value) => _nativeNode.textContent = value ?? '';
  @override
  bool get isConnected => _nativeNode.isConnected;

  @override
  Node appendChild(Node child) {
    _nativeNode.appendChild(child.raw as web.Node);
    return child;
  }

  @override
  Node removeChild(Node child) {
    _nativeNode.removeChild(child.raw as web.Node);
    return child;
  }

  @override
  Node insertBefore(Node newNode, Node? referenceNode) {
    _nativeNode.insertBefore(
      newNode.raw as web.Node,
      referenceNode?.raw as web.Node?,
    );
    return newNode;
  }

  @override
  Node replaceChild(Node newChild, Node oldChild) {
    _nativeNode.replaceChild(
      newChild.raw as web.Node,
      oldChild.raw as web.Node,
    );
    return oldChild;
  }

  @override
  Node cloneNode([bool deep = false]) => wrapNode(_nativeNode.cloneNode(deep));
  @override
  bool contains(EventTarget? other) =>
      other is Node &&
      _nativeNode.contains((other as BrowserNode).raw as web.Node?);
  @override
  bool hasChildNodes() => _nativeNode.hasChildNodes();
}

// ---------------------------------------------------------------------------
// Element
// ---------------------------------------------------------------------------

class BrowserElement extends BrowserNode implements iface.Element {
  final web.Element _nativeElement;
  BrowserElement(this._nativeElement) : super(_nativeElement);

  @override
  dynamic get raw => _nativeElement;
  @override
  String get tagName => _nativeElement.tagName;
  @override
  String get id => _nativeElement.id;
  @override
  set id(String value) => _nativeElement.id = value;
  @override
  String get className => _nativeElement.className;
  @override
  set className(String value) => _nativeElement.className = value;
  @override
  String get innerHTML => (_nativeElement.innerHTML as JSString).toDart;
  @override
  set innerHTML(String value) => _nativeElement.innerHTML = value.toJS;
  @override
  String get outerHTML => (_nativeElement.outerHTML as JSString).toDart;
  @override
  String? get namespaceURI => _nativeElement.namespaceURI;
  @override
  NamedNodeMap get attributes => BrowserNamedNodeMap(_nativeElement.attributes);
  @override
  DOMTokenList get classList => BrowserDOMTokenList(_nativeElement.classList);
  @override
  String? getAttribute(String name) => _nativeElement.getAttribute(name);
  @override
  void setAttribute(String name, String value) =>
      _nativeElement.setAttribute(name, value);
  @override
  void removeAttribute(String name) => _nativeElement.removeAttribute(name);
  @override
  bool hasAttribute(String name) => _nativeElement.hasAttribute(name);
  @override
  iface.Element? querySelector(String selectors) {
    final el = _nativeElement.querySelector(selectors);
    return el != null ? wrapElement(el) : null;
  }

  @override
  NodeList querySelectorAll(String selectors) =>
      BrowserNodeList(_nativeElement.querySelectorAll(selectors));
  @override
  void remove() => _nativeElement.remove();
  @override
  void append(Node node) => _nativeElement.append(node.raw as web.Node);
}

// ---------------------------------------------------------------------------
// HTMLElement
// ---------------------------------------------------------------------------

class BrowserHTMLElement extends BrowserElement implements iface.HTMLElement {
  final web.HTMLElement _nativeHtml;
  BrowserHTMLElement(this._nativeHtml) : super(_nativeHtml);

  @override
  dynamic get raw => _nativeHtml;
  @override
  String get innerText => _nativeHtml.innerText;
  @override
  set innerText(String value) => _nativeHtml.innerText = value;
  @override
  bool get hidden => (_nativeHtml.hidden as JSBoolean?)?.toDart ?? false;
  @override
  set hidden(bool value) => _nativeHtml.hidden = value.toJS;
  @override
  String get title => _nativeHtml.title;
  @override
  set title(String value) => _nativeHtml.title = value;
  @override
  CSSStyleDeclaration get style =>
      BrowserCSSStyleDeclaration(_nativeHtml.style);
  @override
  iface.ShadowRoot? get shadowRoot {
    final sr = _nativeHtml.shadowRoot;
    return sr != null ? BrowserShadowRoot(sr) : null;
  }

  @override
  iface.ShadowRoot attachShadow(iface.ShadowRootInit init) {
    final sr = _nativeHtml.attachShadow(web.ShadowRootInit(mode: init.mode));
    return BrowserShadowRoot(sr);
  }
}

// ---------------------------------------------------------------------------
// Specific HTMLElement subclasses
// ---------------------------------------------------------------------------

class BrowserHTMLInputElement extends BrowserHTMLElement
    implements iface.HTMLInputElement {
  final web.HTMLInputElement _nativeInput;
  BrowserHTMLInputElement(this._nativeInput) : super(_nativeInput);

  @override
  dynamic get raw => _nativeInput;
  @override
  String get value => _nativeInput.value;
  @override
  set value(String val) => _nativeInput.value = val;
  @override
  String get type => _nativeInput.type;
  @override
  set type(String val) => _nativeInput.type = val;
  @override
  String get placeholder => _nativeInput.placeholder;
  @override
  set placeholder(String val) => _nativeInput.placeholder = val;
  @override
  bool get disabled => _nativeInput.disabled;
  @override
  set disabled(bool val) => _nativeInput.disabled = val;
  @override
  bool get checked => _nativeInput.checked;
  @override
  set checked(bool val) => _nativeInput.checked = val;
  @override
  String get name => _nativeInput.name;
  @override
  set name(String val) => _nativeInput.name = val;
}

class BrowserHTMLButtonElement extends BrowserHTMLElement
    implements iface.HTMLButtonElement {
  final web.HTMLButtonElement _nativeButton;
  BrowserHTMLButtonElement(this._nativeButton) : super(_nativeButton);

  @override
  dynamic get raw => _nativeButton;
  @override
  bool get disabled => _nativeButton.disabled;
  @override
  set disabled(bool val) => _nativeButton.disabled = val;
  @override
  String get type => _nativeButton.type;
  @override
  set type(String val) => _nativeButton.type = val;
}

class BrowserHTMLTextAreaElement extends BrowserHTMLElement
    implements iface.HTMLTextAreaElement {
  final web.HTMLTextAreaElement _nativeTextArea;
  BrowserHTMLTextAreaElement(this._nativeTextArea) : super(_nativeTextArea);

  @override
  dynamic get raw => _nativeTextArea;
  @override
  String get value => _nativeTextArea.value;
  @override
  set value(String val) => _nativeTextArea.value = val;
  @override
  String get placeholder => _nativeTextArea.placeholder;
  @override
  set placeholder(String val) => _nativeTextArea.placeholder = val;
  @override
  bool get disabled => _nativeTextArea.disabled;
  @override
  set disabled(bool val) => _nativeTextArea.disabled = val;
  @override
  int get rows => _nativeTextArea.rows;
  @override
  set rows(int val) => _nativeTextArea.rows = val;
  @override
  int get cols => _nativeTextArea.cols;
  @override
  set cols(int val) => _nativeTextArea.cols = val;
}

class BrowserHTMLSelectElement extends BrowserHTMLElement
    implements iface.HTMLSelectElement {
  final web.HTMLSelectElement _nativeSelect;
  BrowserHTMLSelectElement(this._nativeSelect) : super(_nativeSelect);

  @override
  dynamic get raw => _nativeSelect;
  @override
  String get value => _nativeSelect.value;
  @override
  set value(String val) => _nativeSelect.value = val;
  @override
  int get selectedIndex => _nativeSelect.selectedIndex;
  @override
  set selectedIndex(int val) => _nativeSelect.selectedIndex = val;
  @override
  bool get disabled => _nativeSelect.disabled;
  @override
  set disabled(bool val) => _nativeSelect.disabled = val;
}

class BrowserHTMLOptionElement extends BrowserHTMLElement
    implements iface.HTMLOptionElement {
  final web.HTMLOptionElement _nativeOption;
  BrowserHTMLOptionElement(this._nativeOption) : super(_nativeOption);

  @override
  dynamic get raw => _nativeOption;
  @override
  String get value => _nativeOption.value;
  @override
  set value(String val) => _nativeOption.value = val;
  @override
  String get text => _nativeOption.text;
  @override
  set text(String val) => _nativeOption.text = val;
  @override
  bool get selected => _nativeOption.selected;
  @override
  set selected(bool val) => _nativeOption.selected = val;
}

class BrowserHTMLAnchorElement extends BrowserHTMLElement
    implements iface.HTMLAnchorElement {
  final web.HTMLAnchorElement _nativeAnchor;
  BrowserHTMLAnchorElement(this._nativeAnchor) : super(_nativeAnchor);

  @override
  dynamic get raw => _nativeAnchor;
  @override
  String get href => _nativeAnchor.href;
  @override
  set href(String val) => _nativeAnchor.href = val;
  @override
  String get target => _nativeAnchor.target;
  @override
  set target(String val) => _nativeAnchor.target = val;
}

class BrowserHTMLImageElement extends BrowserHTMLElement
    implements iface.HTMLImageElement {
  final web.HTMLImageElement _nativeImage;
  BrowserHTMLImageElement(this._nativeImage) : super(_nativeImage);

  @override
  dynamic get raw => _nativeImage;
  @override
  String get src => _nativeImage.src;
  @override
  set src(String val) => _nativeImage.src = val;
  @override
  String get alt => _nativeImage.alt;
  @override
  set alt(String val) => _nativeImage.alt = val;
  @override
  int get width => _nativeImage.width;
  @override
  set width(int val) => _nativeImage.width = val;
  @override
  int get height => _nativeImage.height;
  @override
  set height(int val) => _nativeImage.height = val;
}

class BrowserHTMLFormElement extends BrowserHTMLElement
    implements iface.HTMLFormElement {
  final web.HTMLFormElement _nativeForm;
  BrowserHTMLFormElement(this._nativeForm) : super(_nativeForm);

  @override
  dynamic get raw => _nativeForm;
  @override
  String get action => _nativeForm.action;
  @override
  set action(String val) => _nativeForm.action = val;
  @override
  String get method => _nativeForm.method;
  @override
  set method(String val) => _nativeForm.method = val;
  @override
  void submit() => _nativeForm.submit();
  @override
  void reset() => _nativeForm.reset();
  @override
  bool reportValidity() => _nativeForm.reportValidity();
}

class BrowserHTMLLabelElement extends BrowserHTMLElement
    implements iface.HTMLLabelElement {
  final web.HTMLLabelElement _nativeLabel;
  BrowserHTMLLabelElement(this._nativeLabel) : super(_nativeLabel);

  @override
  dynamic get raw => _nativeLabel;
  @override
  String get htmlFor => _nativeLabel.htmlFor;
  @override
  set htmlFor(String val) => _nativeLabel.htmlFor = val;
}

class BrowserHTMLTemplateElement extends BrowserHTMLElement
    implements iface.HTMLTemplateElement {
  final web.HTMLTemplateElement _nativeTemplate;
  BrowserHTMLTemplateElement(this._nativeTemplate) : super(_nativeTemplate);

  @override
  dynamic get raw => _nativeTemplate;
  @override
  iface.DocumentFragment get content =>
      BrowserDocumentFragment(_nativeTemplate.content);
}

class BrowserHTMLCanvasElement extends BrowserHTMLElement
    implements iface.HTMLCanvasElement {
  final web.HTMLCanvasElement _nativeCanvas;
  BrowserHTMLCanvasElement(this._nativeCanvas) : super(_nativeCanvas);

  @override
  dynamic get raw => _nativeCanvas;
  @override
  int get width => _nativeCanvas.width;
  @override
  set width(int val) => _nativeCanvas.width = val;
  @override
  int get height => _nativeCanvas.height;
  @override
  set height(int val) => _nativeCanvas.height = val;
  @override
  iface.RenderingContext? getContext(
    iface.CanvasContextType contextType, [
    Map<String, Object?>? options,
  ]) {
    final typeStr = iface.canvasContextTypeToString(contextType);
    final ctx = _nativeCanvas.getContext(typeStr);
    if (ctx == null) return null;
    switch (contextType) {
      case iface.CanvasContextType.canvas2d:
        return BrowserCanvasRenderingContext2D(
          ctx as web.CanvasRenderingContext2D,
        );
    }
  }

  @override
  String toDataURL([String type = 'image/png', num? quality]) =>
      _nativeCanvas.toDataURL(type, quality?.toJS);
}

class BrowserHTMLMediaElement extends BrowserHTMLElement
    implements iface.HTMLMediaElement {
  final web.HTMLMediaElement _nativeMedia;
  BrowserHTMLMediaElement(this._nativeMedia) : super(_nativeMedia);

  @override
  dynamic get raw => _nativeMedia;
  @override
  String get src => _nativeMedia.src;
  @override
  set src(String val) => _nativeMedia.src = val;
  @override
  String get currentSrc => _nativeMedia.currentSrc;
  @override
  double get currentTime => _nativeMedia.currentTime;
  @override
  set currentTime(num val) => _nativeMedia.currentTime = val;
  @override
  double get duration => _nativeMedia.duration;
  @override
  bool get paused => _nativeMedia.paused;
  @override
  bool get ended => _nativeMedia.ended;
  @override
  bool get loop => _nativeMedia.loop;
  @override
  set loop(bool val) => _nativeMedia.loop = val;
  @override
  double get volume => _nativeMedia.volume;
  @override
  set volume(num val) => _nativeMedia.volume = val;
  @override
  bool get muted => _nativeMedia.muted;
  @override
  set muted(bool val) => _nativeMedia.muted = val;
  @override
  bool get autoplay => _nativeMedia.autoplay;
  @override
  set autoplay(bool val) => _nativeMedia.autoplay = val;
  @override
  bool get controls => _nativeMedia.controls;
  @override
  set controls(bool val) => _nativeMedia.controls = val;
  @override
  double get playbackRate => _nativeMedia.playbackRate;
  @override
  set playbackRate(num val) => _nativeMedia.playbackRate = val;
  @override
  int get readyState => _nativeMedia.readyState;
  @override
  int get networkState => _nativeMedia.networkState;
  @override
  String get preload => _nativeMedia.preload;
  @override
  set preload(String val) => _nativeMedia.preload = val;
  @override
  Future<void> play() => _nativeMedia.play().toDart.then((_) {});
  @override
  void pause() => _nativeMedia.pause();
  @override
  void load() => _nativeMedia.load();
}

class BrowserHTMLVideoElement extends BrowserHTMLMediaElement
    implements iface.HTMLVideoElement {
  final web.HTMLVideoElement _nativeVideo;
  BrowserHTMLVideoElement(this._nativeVideo) : super(_nativeVideo);

  @override
  dynamic get raw => _nativeVideo;
  @override
  int get width => _nativeVideo.width;
  @override
  set width(int val) => _nativeVideo.width = val;
  @override
  int get height => _nativeVideo.height;
  @override
  set height(int val) => _nativeVideo.height = val;
  @override
  int get videoWidth => _nativeVideo.videoWidth;
  @override
  int get videoHeight => _nativeVideo.videoHeight;
  @override
  String get poster => _nativeVideo.poster;
  @override
  set poster(String val) => _nativeVideo.poster = val;
  @override
  bool get playsInline => _nativeVideo.playsInline;
  @override
  set playsInline(bool val) => _nativeVideo.playsInline = val;
}

class BrowserHTMLAudioElement extends BrowserHTMLMediaElement
    implements iface.HTMLAudioElement {
  BrowserHTMLAudioElement(web.HTMLAudioElement native) : super(native);
}

class BrowserHTMLDialogElement extends BrowserHTMLElement
    implements iface.HTMLDialogElement {
  final web.HTMLDialogElement _nativeDialog;
  BrowserHTMLDialogElement(this._nativeDialog) : super(_nativeDialog);

  @override
  dynamic get raw => _nativeDialog;
  @override
  bool get open => _nativeDialog.open;
  @override
  set open(bool val) => _nativeDialog.open = val;
  @override
  String get returnValue => _nativeDialog.returnValue;
  @override
  set returnValue(String val) => _nativeDialog.returnValue = val;
  @override
  void show() => _nativeDialog.show();
  @override
  void showModal() => _nativeDialog.showModal();
  @override
  void close([String? returnValue]) => _nativeDialog.close(returnValue ?? '');
}

class BrowserHTMLDetailsElement extends BrowserHTMLElement
    implements iface.HTMLDetailsElement {
  final web.HTMLDetailsElement _nativeDetails;
  BrowserHTMLDetailsElement(this._nativeDetails) : super(_nativeDetails);

  @override
  dynamic get raw => _nativeDetails;
  @override
  bool get open => _nativeDetails.open;
  @override
  set open(bool val) => _nativeDetails.open = val;
  @override
  String get name => _nativeDetails.name;
  @override
  set name(String val) => _nativeDetails.name = val;
}

class BrowserHTMLSlotElement extends BrowserHTMLElement
    implements iface.HTMLSlotElement {
  final web.HTMLSlotElement _nativeSlot;
  BrowserHTMLSlotElement(this._nativeSlot) : super(_nativeSlot);

  @override
  dynamic get raw => _nativeSlot;
  @override
  String get name => _nativeSlot.name;
  @override
  set name(String val) => _nativeSlot.name = val;
  @override
  List<Node> assignedNodes() =>
      _nativeSlot.assignedNodes().toDart.map((n) => wrapNode(n)).toList();
  @override
  List<iface.Element> assignedElements() =>
      _nativeSlot.assignedElements().toDart.map((e) => wrapElement(e)).toList();
}

class BrowserHTMLIFrameElement extends BrowserHTMLElement
    implements iface.HTMLIFrameElement {
  final web.HTMLIFrameElement _nativeIFrame;
  BrowserHTMLIFrameElement(this._nativeIFrame) : super(_nativeIFrame);

  @override
  dynamic get raw => _nativeIFrame;
  @override
  String get src => _nativeIFrame.src;
  @override
  set src(String val) => _nativeIFrame.src = val;
  @override
  String get name => _nativeIFrame.name;
  @override
  set name(String val) => _nativeIFrame.name = val;
  @override
  String get allow => _nativeIFrame.allow;
  @override
  set allow(String val) => _nativeIFrame.allow = val;
  @override
  bool get allowFullscreen => _nativeIFrame.allowFullscreen;
  @override
  set allowFullscreen(bool val) => _nativeIFrame.allowFullscreen = val;
  @override
  String get width => _nativeIFrame.width;
  @override
  set width(String val) => _nativeIFrame.width = val;
  @override
  String get height => _nativeIFrame.height;
  @override
  set height(String val) => _nativeIFrame.height = val;
  @override
  String get loading => _nativeIFrame.loading;
  @override
  set loading(String val) => _nativeIFrame.loading = val;
  @override
  String get referrerPolicy => _nativeIFrame.referrerPolicy;
  @override
  set referrerPolicy(String val) => _nativeIFrame.referrerPolicy = val;
}

class BrowserHTMLTableElement extends BrowserHTMLElement
    implements iface.HTMLTableElement {
  final web.HTMLTableElement _nativeTable;
  BrowserHTMLTableElement(this._nativeTable) : super(_nativeTable);

  @override
  dynamic get raw => _nativeTable;
  @override
  iface.HTMLElement? get caption {
    final c = _nativeTable.caption;
    return c != null ? BrowserHTMLElement(c) : null;
  }

  @override
  set caption(iface.HTMLElement? val) =>
      _nativeTable.caption = val?.raw as web.HTMLTableCaptionElement?;
  @override
  iface.HTMLElement? get tHead {
    final h = _nativeTable.tHead;
    return h != null ? BrowserHTMLElement(h) : null;
  }

  @override
  set tHead(iface.HTMLElement? val) =>
      _nativeTable.tHead = val?.raw as web.HTMLTableSectionElement?;
  @override
  iface.HTMLElement? get tFoot {
    final f = _nativeTable.tFoot;
    return f != null ? BrowserHTMLElement(f) : null;
  }

  @override
  set tFoot(iface.HTMLElement? val) =>
      _nativeTable.tFoot = val?.raw as web.HTMLTableSectionElement?;
  @override
  iface.HTMLElement createTBody() =>
      BrowserHTMLElement(_nativeTable.createTBody());
  @override
  iface.HTMLElement insertRow([int index = -1]) =>
      BrowserHTMLElement(_nativeTable.insertRow(index));
  @override
  void deleteRow(int index) => _nativeTable.deleteRow(index);
}

class BrowserHTMLTableRowElement extends BrowserHTMLElement
    implements iface.HTMLTableRowElement {
  final web.HTMLTableRowElement _nativeRow;
  BrowserHTMLTableRowElement(this._nativeRow) : super(_nativeRow);

  @override
  dynamic get raw => _nativeRow;
  @override
  int get rowIndex => _nativeRow.rowIndex;
  @override
  int get sectionRowIndex => _nativeRow.sectionRowIndex;
  @override
  iface.HTMLElement insertCell([int index = -1]) =>
      BrowserHTMLElement(_nativeRow.insertCell(index));
  @override
  void deleteCell(int index) => _nativeRow.deleteCell(index);
}

class BrowserHTMLTableCellElement extends BrowserHTMLElement
    implements iface.HTMLTableCellElement {
  final web.HTMLTableCellElement _nativeCell;
  BrowserHTMLTableCellElement(this._nativeCell) : super(_nativeCell);

  @override
  dynamic get raw => _nativeCell;
  @override
  int get colSpan => _nativeCell.colSpan;
  @override
  set colSpan(int val) => _nativeCell.colSpan = val;
  @override
  int get rowSpan => _nativeCell.rowSpan;
  @override
  set rowSpan(int val) => _nativeCell.rowSpan = val;
  @override
  int get cellIndex => _nativeCell.cellIndex;
}

class BrowserHTMLProgressElement extends BrowserHTMLElement
    implements iface.HTMLProgressElement {
  final web.HTMLProgressElement _nativeProgress;
  BrowserHTMLProgressElement(this._nativeProgress) : super(_nativeProgress);

  @override
  dynamic get raw => _nativeProgress;
  @override
  double get value => _nativeProgress.value;
  @override
  set value(double val) => _nativeProgress.value = val;
  @override
  double get max => _nativeProgress.max;
  @override
  set max(double val) => _nativeProgress.max = val;
  @override
  double get position => _nativeProgress.position;
}

class BrowserHTMLMeterElement extends BrowserHTMLElement
    implements iface.HTMLMeterElement {
  final web.HTMLMeterElement _nativeMeter;
  BrowserHTMLMeterElement(this._nativeMeter) : super(_nativeMeter);

  @override
  dynamic get raw => _nativeMeter;
  @override
  double get value => _nativeMeter.value;
  @override
  set value(double val) => _nativeMeter.value = val;
  @override
  double get min => _nativeMeter.min;
  @override
  set min(double val) => _nativeMeter.min = val;
  @override
  double get max => _nativeMeter.max;
  @override
  set max(double val) => _nativeMeter.max = val;
  @override
  double get low => _nativeMeter.low;
  @override
  set low(double val) => _nativeMeter.low = val;
  @override
  double get high => _nativeMeter.high;
  @override
  set high(double val) => _nativeMeter.high = val;
  @override
  double get optimum => _nativeMeter.optimum;
  @override
  set optimum(double val) => _nativeMeter.optimum = val;
}

class BrowserHTMLOutputElement extends BrowserHTMLElement
    implements iface.HTMLOutputElement {
  final web.HTMLOutputElement _nativeOutput;
  BrowserHTMLOutputElement(this._nativeOutput) : super(_nativeOutput);

  @override
  dynamic get raw => _nativeOutput;
  @override
  String get value => _nativeOutput.value;
  @override
  set value(String val) => _nativeOutput.value = val;
  @override
  String get defaultValue => _nativeOutput.defaultValue;
  @override
  set defaultValue(String val) => _nativeOutput.defaultValue = val;
  @override
  String get name => _nativeOutput.name;
  @override
  set name(String val) => _nativeOutput.name = val;
  @override
  String get type => _nativeOutput.type;
  @override
  DOMTokenList get htmlFor => BrowserDOMTokenList(_nativeOutput.htmlFor);
}

class BrowserHTMLOListElement extends BrowserHTMLElement
    implements iface.HTMLOListElement {
  final web.HTMLOListElement _nativeOList;
  BrowserHTMLOListElement(this._nativeOList) : super(_nativeOList);

  @override
  dynamic get raw => _nativeOList;
  @override
  bool get reversed => _nativeOList.reversed;
  @override
  set reversed(bool val) => _nativeOList.reversed = val;
  @override
  int get start => _nativeOList.start;
  @override
  set start(int val) => _nativeOList.start = val;
  @override
  String get type => _nativeOList.type;
  @override
  set type(String val) => _nativeOList.type = val;
}

class BrowserHTMLLIElement extends BrowserHTMLElement
    implements iface.HTMLLIElement {
  final web.HTMLLIElement _nativeLI;
  BrowserHTMLLIElement(this._nativeLI) : super(_nativeLI);

  @override
  dynamic get raw => _nativeLI;
  @override
  int get value => _nativeLI.value;
  @override
  set value(int val) => _nativeLI.value = val;
}

// ---------------------------------------------------------------------------
// DocumentFragment
// ---------------------------------------------------------------------------

class BrowserDocumentFragment extends BrowserNode
    implements iface.DocumentFragment {
  final web.DocumentFragment _nativeFragment;
  BrowserDocumentFragment(this._nativeFragment) : super(_nativeFragment);

  @override
  dynamic get raw => _nativeFragment;
  @override
  iface.Element? querySelector(String selectors) {
    final el = _nativeFragment.querySelector(selectors);
    return el != null ? wrapElement(el) : null;
  }

  @override
  NodeList querySelectorAll(String selectors) =>
      BrowserNodeList(_nativeFragment.querySelectorAll(selectors));
}

// ---------------------------------------------------------------------------
// ShadowRoot
// ---------------------------------------------------------------------------

class BrowserShadowRoot extends BrowserDocumentFragment
    implements iface.ShadowRoot {
  final web.ShadowRoot _nativeShadowRoot;
  BrowserShadowRoot(this._nativeShadowRoot) : super(_nativeShadowRoot);

  @override
  dynamic get raw => _nativeShadowRoot;
  @override
  iface.Element get host => wrapElement(_nativeShadowRoot.host);
  @override
  String get mode => _nativeShadowRoot.mode;
  @override
  iface.Element? get firstElementChild {
    final el = _nativeShadowRoot.firstElementChild;
    return el != null ? wrapElement(el) : null;
  }

  @override
  iface.Element? querySelector(String selectors) {
    final el = _nativeShadowRoot.querySelector(selectors);
    return el != null ? wrapElement(el) : null;
  }

  @override
  NodeList querySelectorAll(String selectors) =>
      BrowserNodeList(_nativeShadowRoot.querySelectorAll(selectors));

  @override
  List<CSSStyleSheet> get adoptedStyleSheets => [];

  @override
  set adoptedStyleSheets(List<CSSStyleSheet> sheets) {
    final nativeSheets = sheets
        .map((s) => (s as BrowserCSSStyleSheet).native)
        .toList();
    _nativeShadowRoot.adoptedStyleSheets = nativeSheets.toJS;
  }
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

class BrowserDocument extends BrowserNode implements iface.Document {
  final web.Document _nativeDoc;
  BrowserDocument(this._nativeDoc) : super(_nativeDoc);

  @override
  dynamic get raw => _nativeDoc;
  @override
  iface.Element? get documentElement {
    final el = _nativeDoc.documentElement;
    return el != null ? wrapElement(el) : null;
  }

  @override
  iface.HTMLElement? get body {
    final el = _nativeDoc.body;
    return el != null ? BrowserHTMLElement(el) : null;
  }

  @override
  iface.HTMLElement? get head {
    final el = _nativeDoc.head;
    return el != null ? BrowserHTMLElement(el) : null;
  }

  @override
  iface.Element createElement(String tagName) =>
      wrapElement(_nativeDoc.createElement(tagName));
  @override
  iface.Element createElementNS(String? namespace, String qualifiedName) =>
      wrapElement(_nativeDoc.createElementNS(namespace, qualifiedName));
  @override
  iface.Text createTextNode(String data) =>
      BrowserText(_nativeDoc.createTextNode(data));
  @override
  iface.Comment createComment(String data) =>
      BrowserComment(_nativeDoc.createComment(data));
  @override
  iface.DocumentFragment createDocumentFragment() =>
      BrowserDocumentFragment(_nativeDoc.createDocumentFragment());
  @override
  iface.Element? getElementById(String id) {
    final el = _nativeDoc.getElementById(id);
    return el != null ? wrapElement(el) : null;
  }

  @override
  iface.Element? querySelector(String selectors) {
    final el = _nativeDoc.querySelector(selectors);
    return el != null ? wrapElement(el) : null;
  }

  @override
  NodeList querySelectorAll(String selectors) =>
      BrowserNodeList(_nativeDoc.querySelectorAll(selectors));
}

// ---------------------------------------------------------------------------
// Text & Comment
// ---------------------------------------------------------------------------

class BrowserText extends BrowserNode implements iface.Text {
  final web.Text _nativeText;
  BrowserText(this._nativeText) : super(_nativeText);

  @override
  dynamic get raw => _nativeText;
  @override
  String get data => _nativeText.data;
  @override
  set data(String value) => _nativeText.data = value;
  @override
  String get wholeText => _nativeText.wholeText;
}

class BrowserComment extends BrowserNode implements iface.Comment {
  final web.Comment _nativeComment;
  BrowserComment(this._nativeComment) : super(_nativeComment);

  @override
  dynamic get raw => _nativeComment;
  @override
  String get data => _nativeComment.data;
  @override
  set data(String value) => _nativeComment.data = value;
}

// ---------------------------------------------------------------------------
// MutationObserver
// ---------------------------------------------------------------------------

class BrowserMutationObserver implements MutationObserver {
  final web.MutationObserver _native;

  BrowserMutationObserver(MutationCallback callback)
    : _native = web.MutationObserver(
        ((
              JSArray<web.MutationRecord> mutations,
              web.MutationObserver observer,
            ) {
              callback(
                mutations.toDart.map((r) => BrowserMutationRecord(r)).toList(),
                BrowserMutationObserver._wrap(observer),
              );
            })
            .toJS,
      );

  BrowserMutationObserver._wrap(web.MutationObserver native) : _native = native;

  @override
  void observe(Node target, [MutationObserverInit? options]) {
    if (options != null) {
      final init = web.MutationObserverInit(
        attributes: options.attributes ?? false,
        attributeOldValue: options.attributeOldValue ?? false,
        childList: options.childList ?? false,
        characterData: options.characterData ?? false,
        subtree: options.subtree ?? false,
        characterDataOldValue: options.characterDataOldValue ?? false,
      );
      // attributeFilter must be set separately if provided
      if (options.attributeFilter != null) {
        init.attributeFilter = options.attributeFilter!
            .map((s) => s.toJS)
            .toList()
            .toJS;
      }
      _native.observe(target.raw as web.Node, init);
    } else {
      _native.observe(target.raw as web.Node);
    }
  }

  @override
  void disconnect() => _native.disconnect();

  @override
  List<MutationRecord> takeRecords() => _native
      .takeRecords()
      .toDart
      .map((r) => BrowserMutationRecord(r))
      .toList();
}

class BrowserMutationRecord implements MutationRecord {
  final web.MutationRecord _native;
  BrowserMutationRecord(this._native);

  @override
  String get type => _native.type;
  @override
  Node get target => wrapNode(_native.target);
  @override
  NodeList get addedNodes => BrowserNodeList(_native.addedNodes);
  @override
  NodeList get removedNodes => BrowserNodeList(_native.removedNodes);
  @override
  Node? get previousSibling {
    final s = _native.previousSibling;
    return s != null ? wrapNode(s) : null;
  }

  @override
  Node? get nextSibling {
    final s = _native.nextSibling;
    return s != null ? wrapNode(s) : null;
  }

  @override
  String? get attributeName => _native.attributeName;
  @override
  String? get oldValue => _native.oldValue;
}

// ---------------------------------------------------------------------------
// Touch & TouchList
// ---------------------------------------------------------------------------

class BrowserTouch implements Touch {
  final web.Touch _native;
  BrowserTouch(this._native);

  @override
  int get identifier => _native.identifier;
  @override
  EventTarget get target => wrapEventTarget(_native.target);
  @override
  double get screenX => _native.screenX;
  @override
  double get screenY => _native.screenY;
  @override
  double get clientX => _native.clientX;
  @override
  double get clientY => _native.clientY;
  @override
  double get pageX => _native.pageX;
  @override
  double get pageY => _native.pageY;
  @override
  double get radiusX => _native.radiusX;
  @override
  double get radiusY => _native.radiusY;
  @override
  double get rotationAngle => _native.rotationAngle;
  @override
  double get force => _native.force;
}

class BrowserTouchList implements TouchList {
  final web.TouchList _native;
  BrowserTouchList(this._native);

  @override
  int get length => _native.length;
  @override
  Touch? item(int index) {
    final t = _native.item(index);
    return t != null ? BrowserTouch(t) : null;
  }
}

// ---------------------------------------------------------------------------
// DataTransfer
// ---------------------------------------------------------------------------

class BrowserDataTransfer implements DataTransfer {
  final web.DataTransfer _native;
  BrowserDataTransfer(this._native);

  @override
  String get dropEffect => _native.dropEffect;
  @override
  set dropEffect(String value) => _native.dropEffect = value;
  @override
  String get effectAllowed => _native.effectAllowed;
  @override
  set effectAllowed(String value) => _native.effectAllowed = value;
  @override
  List<String> get types => _native.types.toDart.map((s) => s.toDart).toList();
  @override
  void setData(String format, String data) => _native.setData(format, data);
  @override
  String getData(String format) => _native.getData(format);
  @override
  void clearData([String? format]) =>
      format != null ? _native.clearData(format) : _native.clearData();
}
