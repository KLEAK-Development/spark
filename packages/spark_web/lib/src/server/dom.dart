/// Server-side implementations of DOM types.
///
/// These are no-ops or return sensible defaults, allowing component code
/// to compile and run on the Dart VM without crashing.
library;

import '../canvas.dart' as iface;
import '../core.dart';
import '../dom.dart' as iface;
import '../collections.dart';
import '../css.dart';
import '../file.dart' as iface;
import 'collections.dart';
import 'css.dart';
import 'file.dart';

// ---------------------------------------------------------------------------
// ValidityState
// ---------------------------------------------------------------------------

class ServerValidityState implements iface.ValidityState {
  @override
  bool get valueMissing => false;
  @override
  bool get typeMismatch => false;
  @override
  bool get patternMismatch => false;
  @override
  bool get tooLong => false;
  @override
  bool get tooShort => false;
  @override
  bool get rangeUnderflow => false;
  @override
  bool get rangeOverflow => false;
  @override
  bool get stepMismatch => false;
  @override
  bool get badInput => false;
  @override
  bool get customError => false;
  @override
  bool get valid => true;
}

// ---------------------------------------------------------------------------
// HTMLCollection
// ---------------------------------------------------------------------------

class ServerHTMLCollection implements iface.HTMLCollection {
  @override
  int get length => 0;
  @override
  iface.Element? item(int index) => null;
}

// ---------------------------------------------------------------------------
// EventTarget
// ---------------------------------------------------------------------------

class ServerEventTarget implements EventTarget {
  @override
  void addEventListener(String type, EventListener? callback) {}
  @override
  void removeEventListener(String type, EventListener? callback) {}
  @override
  bool dispatchEvent(Event event) => false;
  @override
  dynamic get raw => null;
}

// ---------------------------------------------------------------------------
// Node
// ---------------------------------------------------------------------------

class ServerNode extends ServerEventTarget implements Node {
  @override
  int get nodeType => 0;
  @override
  String get nodeName => '';
  @override
  Node? get parentNode => null;
  @override
  Node? get parentElement => null;
  @override
  NodeList get childNodes => ServerNodeList();
  @override
  Node? get firstChild => null;
  @override
  Node? get lastChild => null;
  @override
  Node? get nextSibling => null;
  @override
  Node? get previousSibling => null;
  @override
  String? get textContent => '';
  @override
  set textContent(String? value) {}
  @override
  bool get isConnected => false;
  @override
  Node appendChild(Node child) => child;
  @override
  Node removeChild(Node child) => child;
  @override
  Node insertBefore(Node newNode, Node? referenceNode) => newNode;
  @override
  Node replaceChild(Node newChild, Node oldChild) => oldChild;
  @override
  Node cloneNode([bool deep = false]) => this;
  @override
  bool contains(EventTarget? other) => false;
  @override
  bool hasChildNodes() => false;
}

// ---------------------------------------------------------------------------
// Element
// ---------------------------------------------------------------------------

class ServerElement extends ServerNode implements iface.Element {
  @override
  int get nodeType => Node.ELEMENT_NODE;
  @override
  String get tagName => '';
  @override
  String get id => '';
  @override
  set id(String value) {}
  @override
  String get className => '';
  @override
  set className(String value) {}
  @override
  String get innerHTML => '';
  @override
  set innerHTML(String value) {}
  @override
  String get outerHTML => '';
  @override
  String? get namespaceURI => null;
  @override
  NamedNodeMap get attributes => ServerNamedNodeMap();
  @override
  DOMTokenList get classList => ServerDOMTokenList();
  @override
  String? getAttribute(String name) => null;
  @override
  void setAttribute(String name, String value) {}
  @override
  void removeAttribute(String name) {}
  @override
  bool hasAttribute(String name) => false;
  @override
  iface.Element? querySelector(String selectors) => null;
  @override
  NodeList querySelectorAll(String selectors) => ServerNodeList();
  @override
  iface.HTMLCollection get children => ServerHTMLCollection();
  @override
  void remove() {}
  @override
  void append(Node node) {}
}

// ---------------------------------------------------------------------------
// HTMLElement
// ---------------------------------------------------------------------------

class ServerHTMLElement extends ServerElement implements iface.HTMLElement {
  @override
  String get innerText => '';
  @override
  set innerText(String value) {}
  @override
  bool get hidden => false;
  @override
  set hidden(bool value) {}
  @override
  String get title => '';
  @override
  set title(String value) {}
  @override
  void focus() {}
  @override
  void blur() {}
  @override
  CSSStyleDeclaration get style => ServerCSSStyleDeclaration();
  @override
  iface.ShadowRoot? get shadowRoot => null;
  @override
  iface.ShadowRoot attachShadow(iface.ShadowRootInit init) =>
      ServerShadowRoot();
}

// ---------------------------------------------------------------------------
// Specific HTMLElement subclasses
// ---------------------------------------------------------------------------

class ServerHTMLInputElement extends ServerHTMLElement
    implements
        iface.HTMLInputElement,
        iface.HTMLTextInputElement,
        iface.HTMLNumericInputElement,
        iface.HTMLCheckableInputElement,
        iface.HTMLFileInputElement,
        iface.HTMLButtonInputElement {
  @override
  String get value => '';
  @override
  set value(String val) {}
  @override
  String get defaultValue => '';
  @override
  set defaultValue(String val) {}
  @override
  String get type => '';
  @override
  set type(String val) {}
  @override
  String get name => '';
  @override
  set name(String val) {}
  @override
  bool get disabled => false;
  @override
  set disabled(bool val) {}
  @override
  bool get autofocus => false;
  @override
  set autofocus(bool val) {}
  @override
  bool get required => false;
  @override
  set required(bool val) {}

  @override
  iface.HTMLFormElement? get form => null;

  @override
  NodeList get labels => ServerNodeList();

  @override
  iface.HTMLDataListElement? get list => null;

  @override
  bool get willValidate => true;
  @override
  iface.ValidityState get validity => ServerValidityState();
  @override
  String get validationMessage => '';
  @override
  bool checkValidity() => true;
  @override
  bool reportValidity() => true;
  @override
  void setCustomValidity(String error) {}

  @override
  void select() {}
  @override
  void showPicker() {}

  // -- HTMLTextInputElement --

  @override
  String get placeholder => '';
  @override
  set placeholder(String val) {}
  @override
  bool get readOnly => false;
  @override
  set readOnly(bool val) {}
  @override
  int get size => 20;
  @override
  set size(int val) {}
  @override
  int get maxLength => -1;
  @override
  set maxLength(int val) {}
  @override
  int get minLength => -1;
  @override
  set minLength(int val) {}
  @override
  String get pattern => '';
  @override
  set pattern(String val) {}
  @override
  String get autocomplete => '';
  @override
  set autocomplete(String val) {}
  @override
  String get dirName => '';
  @override
  set dirName(String val) {}

  @override
  int? get selectionStart => 0;
  @override
  set selectionStart(int? val) {}
  @override
  int? get selectionEnd => 0;
  @override
  set selectionEnd(int? val) {}
  @override
  String? get selectionDirection => 'none';
  @override
  set selectionDirection(String? val) {}

  @override
  void setRangeText(String replacement, [int? start, int? end, String? selectionMode]) {}
  @override
  void setSelectionRange(int start, int end, [String? direction]) {}

  // -- HTMLNumericInputElement --

  @override
  String get min => '';
  @override
  set min(String val) {}
  @override
  String get max => '';
  @override
  set max(String val) {}
  @override
  String get step => '';
  @override
  set step(String val) {}
  @override
  double? get valueAsNumber => 0.0;
  @override
  set valueAsNumber(double? val) {}
  @override
  DateTime? get valueAsDate => null;
  @override
  set valueAsDate(DateTime? val) {}

  @override
  void stepDown([int n = 1]) {}
  @override
  void stepUp([int n = 1]) {}

  // -- HTMLCheckableInputElement --

  @override
  bool get checked => false;
  @override
  set checked(bool val) {}
  @override
  bool get defaultChecked => false;
  @override
  set defaultChecked(bool val) {}
  @override
  bool get indeterminate => false;
  @override
  set indeterminate(bool val) {}

  // -- HTMLFileInputElement --

  @override
  String get accept => '';
  @override
  set accept(String val) {}
  @override
  String get capture => '';
  @override
  set capture(String val) {}
  @override
  bool get multiple => false;
  @override
  set multiple(bool val) {}
  @override
  iface.FileList? get files => ServerFileList();
  @override
  set files(iface.FileList? val) {}

  // -- HTMLButtonInputElement --

  @override
  String get alt => '';
  @override
  set alt(String val) {}
  @override
  String get src => '';
  @override
  set src(String val) {}
  @override
  int get height => 0;
  @override
  set height(int val) {}
  @override
  int get width => 0;
  @override
  set width(int val) {}

  @override
  String get formAction => '';
  @override
  set formAction(String val) {}
  @override
  String get formEnctype => '';
  @override
  set formEnctype(String val) {}
  @override
  String get formMethod => '';
  @override
  set formMethod(String val) {}
  @override
  bool get formNoValidate => false;
  @override
  set formNoValidate(bool val) {}
  @override
  String get formTarget => '';
  @override
  set formTarget(String val) {}
}

class ServerHTMLButtonElement extends ServerHTMLElement
    implements iface.HTMLButtonElement {
  @override
  bool get disabled => false;
  @override
  set disabled(bool val) {}
  @override
  String get type => '';
  @override
  set type(String val) {}
}

class ServerHTMLTextAreaElement extends ServerHTMLElement
    implements iface.HTMLTextAreaElement {
  @override
  String get value => '';
  @override
  set value(String val) {}
  @override
  String get placeholder => '';
  @override
  set placeholder(String val) {}
  @override
  bool get disabled => false;
  @override
  set disabled(bool val) {}
  @override
  int get rows => 0;
  @override
  set rows(int val) {}
  @override
  int get cols => 0;
  @override
  set cols(int val) {}
}

class ServerHTMLSelectElement extends ServerHTMLElement
    implements iface.HTMLSelectElement {
  @override
  String get value => '';
  @override
  set value(String val) {}
  @override
  int get selectedIndex => -1;
  @override
  set selectedIndex(int val) {}
  @override
  bool get disabled => false;
  @override
  set disabled(bool val) {}
}

class ServerHTMLOptionElement extends ServerHTMLElement
    implements iface.HTMLOptionElement {
  @override
  String get value => '';
  @override
  set value(String val) {}
  @override
  String get text => '';
  @override
  set text(String val) {}
  @override
  bool get selected => false;
  @override
  set selected(bool val) {}
}

class ServerHTMLDivElement extends ServerHTMLElement
    implements iface.HTMLDivElement {}

class ServerHTMLSpanElement extends ServerHTMLElement
    implements iface.HTMLSpanElement {}

class ServerHTMLParagraphElement extends ServerHTMLElement
    implements iface.HTMLParagraphElement {}

class ServerHTMLAnchorElement extends ServerHTMLElement
    implements iface.HTMLAnchorElement {
  @override
  String get href => '';
  @override
  set href(String val) {}
  @override
  String get target => '';
  @override
  set target(String val) {}
}

class ServerHTMLImageElement extends ServerHTMLElement
    implements iface.HTMLImageElement {
  @override
  String get src => '';
  @override
  set src(String val) {}
  @override
  String get alt => '';
  @override
  set alt(String val) {}
  @override
  int get width => 0;
  @override
  set width(int val) {}
  @override
  int get height => 0;
  @override
  set height(int val) {}
}

class ServerHTMLFormElement extends ServerHTMLElement
    implements iface.HTMLFormElement {
  @override
  String get action => '';
  @override
  set action(String val) {}
  @override
  String get method => '';
  @override
  set method(String val) {}
  @override
  void submit() {}
  @override
  void reset() {}
  @override
  bool reportValidity() => true;
}

class ServerHTMLLabelElement extends ServerHTMLElement
    implements iface.HTMLLabelElement {
  @override
  String get htmlFor => '';
  @override
  set htmlFor(String val) {}
}

class ServerHTMLTemplateElement extends ServerHTMLElement
    implements iface.HTMLTemplateElement {
  @override
  iface.DocumentFragment get content => ServerDocumentFragment();
}

class ServerHTMLDataListElement extends ServerHTMLElement
    implements iface.HTMLDataListElement {
  @override
  iface.HTMLCollection get options => ServerHTMLCollection();
}

class ServerHTMLCanvasElement extends ServerHTMLElement
    implements iface.HTMLCanvasElement {
  @override
  int get width => 0;
  @override
  set width(int val) {}
  @override
  int get height => 0;
  @override
  set height(int val) {}
  @override
  iface.RenderingContext? getContext(
    iface.CanvasContextType contextType, [
    Map<String, Object?>? options,
  ]) => null;
  @override
  String toDataURL([String type = 'image/png', num? quality]) => '';
}

class ServerHTMLMediaElement extends ServerHTMLElement
    implements iface.HTMLMediaElement {
  @override
  String get src => '';
  @override
  set src(String val) {}
  @override
  String get currentSrc => '';
  @override
  double get currentTime => 0;
  @override
  set currentTime(num val) {}
  @override
  double get duration => 0;
  @override
  bool get paused => true;
  @override
  bool get ended => false;
  @override
  bool get loop => false;
  @override
  set loop(bool val) {}
  @override
  double get volume => 1;
  @override
  set volume(num val) {}
  @override
  bool get muted => false;
  @override
  set muted(bool val) {}
  @override
  bool get autoplay => false;
  @override
  set autoplay(bool val) {}
  @override
  bool get controls => false;
  @override
  set controls(bool val) {}
  @override
  double get playbackRate => 1;
  @override
  set playbackRate(num val) {}
  @override
  int get readyState => 0;
  @override
  int get networkState => 0;
  @override
  String get preload => 'auto';
  @override
  set preload(String val) {}
  @override
  Future<void> play() async {}
  @override
  void pause() {}
  @override
  void load() {}
}

class ServerHTMLVideoElement extends ServerHTMLMediaElement
    implements iface.HTMLVideoElement {
  @override
  int get width => 0;
  @override
  set width(int val) {}
  @override
  int get height => 0;
  @override
  set height(int val) {}
  @override
  int get videoWidth => 0;
  @override
  int get videoHeight => 0;
  @override
  String get poster => '';
  @override
  set poster(String val) {}
  @override
  bool get playsInline => false;
  @override
  set playsInline(bool val) {}
}

class ServerHTMLAudioElement extends ServerHTMLMediaElement
    implements iface.HTMLAudioElement {}

class ServerHTMLDialogElement extends ServerHTMLElement
    implements iface.HTMLDialogElement {
  @override
  bool get open => false;
  @override
  set open(bool val) {}
  @override
  String get returnValue => '';
  @override
  set returnValue(String val) {}
  @override
  void show() {}
  @override
  void showModal() {}
  @override
  void close([String? returnValue]) {}
}

class ServerHTMLDetailsElement extends ServerHTMLElement
    implements iface.HTMLDetailsElement {
  @override
  bool get open => false;
  @override
  set open(bool val) {}
  @override
  String get name => '';
  @override
  set name(String val) {}
}

class ServerHTMLSlotElement extends ServerHTMLElement
    implements iface.HTMLSlotElement {
  @override
  String get name => '';
  @override
  set name(String val) {}
  @override
  List<Node> assignedNodes() => [];
  @override
  List<iface.Element> assignedElements() => [];
}

class ServerHTMLIFrameElement extends ServerHTMLElement
    implements iface.HTMLIFrameElement {
  @override
  String get src => '';
  @override
  set src(String val) {}
  @override
  String get name => '';
  @override
  set name(String val) {}
  @override
  String get allow => '';
  @override
  set allow(String val) {}
  @override
  bool get allowFullscreen => false;
  @override
  set allowFullscreen(bool val) {}
  @override
  String get width => '';
  @override
  set width(String val) {}
  @override
  String get height => '';
  @override
  set height(String val) {}
  @override
  String get loading => '';
  @override
  set loading(String val) {}
  @override
  String get referrerPolicy => '';
  @override
  set referrerPolicy(String val) {}
}

class ServerHTMLTableElement extends ServerHTMLElement
    implements iface.HTMLTableElement {
  @override
  iface.HTMLElement? get caption => null;
  @override
  set caption(iface.HTMLElement? val) {}
  @override
  iface.HTMLTableSectionElement? get tHead => null;
  @override
  set tHead(iface.HTMLTableSectionElement? val) {}
  @override
  iface.HTMLTableSectionElement? get tFoot => null;
  @override
  set tFoot(iface.HTMLTableSectionElement? val) {}
  @override
  iface.HTMLTableSectionElement createTBody() =>
      ServerHTMLTableSectionElement();
  @override
  iface.HTMLTableRowElement insertRow([int index = -1]) =>
      ServerHTMLTableRowElement();
  @override
  void deleteRow(int index) {}
}

class ServerHTMLTableSectionElement extends ServerHTMLElement
    implements iface.HTMLTableSectionElement {
  @override
  iface.HTMLTableRowElement insertRow([int index = -1]) =>
      ServerHTMLTableRowElement();
  @override
  void deleteRow(int index) {}
}

class ServerHTMLTableRowElement extends ServerHTMLElement
    implements iface.HTMLTableRowElement {
  @override
  int get rowIndex => -1;
  @override
  int get sectionRowIndex => -1;
  @override
  iface.HTMLTableCellElement insertCell([int index = -1]) =>
      ServerHTMLTableCellElement();
  @override
  void deleteCell(int index) {}
}

class ServerHTMLTableCellElement extends ServerHTMLElement
    implements iface.HTMLTableCellElement {
  @override
  int get colSpan => 1;
  @override
  set colSpan(int val) {}
  @override
  int get rowSpan => 1;
  @override
  set rowSpan(int val) {}
  @override
  int get cellIndex => -1;
}

class ServerHTMLHeadingElement extends ServerHTMLElement
    implements iface.HTMLHeadingElement {}

class ServerHTMLUListElement extends ServerHTMLElement
    implements iface.HTMLUListElement {}

class ServerHTMLOListElement extends ServerHTMLElement
    implements iface.HTMLOListElement {
  @override
  bool get reversed => false;
  @override
  set reversed(bool val) {}
  @override
  int get start => 1;
  @override
  set start(int val) {}
  @override
  String get type => '';
  @override
  set type(String val) {}
}

class ServerHTMLLIElement extends ServerHTMLElement
    implements iface.HTMLLIElement {
  @override
  int get value => 0;
  @override
  set value(int val) {}
}

class ServerHTMLPreElement extends ServerHTMLElement
    implements iface.HTMLPreElement {}

class ServerHTMLHRElement extends ServerHTMLElement
    implements iface.HTMLHRElement {}

class ServerHTMLBRElement extends ServerHTMLElement
    implements iface.HTMLBRElement {}

class ServerHTMLProgressElement extends ServerHTMLElement
    implements iface.HTMLProgressElement {
  @override
  double get value => 0;
  @override
  set value(double val) {}
  @override
  double get max => 1;
  @override
  set max(double val) {}
  @override
  double get position => -1;
}

class ServerHTMLMeterElement extends ServerHTMLElement
    implements iface.HTMLMeterElement {
  @override
  double get value => 0;
  @override
  set value(double val) {}
  @override
  double get min => 0;
  @override
  set min(double val) {}
  @override
  double get max => 1;
  @override
  set max(double val) {}
  @override
  double get low => 0;
  @override
  set low(double val) {}
  @override
  double get high => 1;
  @override
  set high(double val) {}
  @override
  double get optimum => 0.5;
  @override
  set optimum(double val) {}
}

class ServerHTMLOutputElement extends ServerHTMLElement
    implements iface.HTMLOutputElement {
  @override
  String get value => '';
  @override
  set value(String val) {}
  @override
  String get defaultValue => '';
  @override
  set defaultValue(String val) {}
  @override
  String get name => '';
  @override
  set name(String val) {}
  @override
  String get type => 'output';
  @override
  DOMTokenList get htmlFor => ServerDOMTokenList();
}

// ---------------------------------------------------------------------------
// DocumentFragment
// ---------------------------------------------------------------------------

class ServerDocumentFragment extends ServerNode
    implements iface.DocumentFragment {
  @override
  int get nodeType => Node.DOCUMENT_FRAGMENT_NODE;
  @override
  iface.Element? querySelector(String selectors) => null;
  @override
  NodeList querySelectorAll(String selectors) => ServerNodeList();
}

// ---------------------------------------------------------------------------
// ShadowRoot
// ---------------------------------------------------------------------------

class ServerShadowRoot extends ServerDocumentFragment
    implements iface.ShadowRoot {
  @override
  iface.Element get host => ServerElement();
  @override
  String get mode => 'open';
  @override
  iface.Element? get firstElementChild => null;
  @override
  iface.Element? querySelector(String selectors) => null;
  @override
  NodeList querySelectorAll(String selectors) => ServerNodeList();
  @override
  List<CSSStyleSheet> get adoptedStyleSheets => [];
  @override
  set adoptedStyleSheets(List<CSSStyleSheet> sheets) {}
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

class ServerDocument extends ServerNode implements iface.Document {
  @override
  int get nodeType => Node.DOCUMENT_NODE;
  @override
  iface.Element? get documentElement => null;
  @override
  iface.HTMLElement? get body => null;
  @override
  iface.HTMLElement? get head => null;
  @override
  iface.Element createElement(String tagName) {
    switch (tagName.toLowerCase()) {
      case 'div':
        return ServerHTMLDivElement();
      case 'span':
        return ServerHTMLSpanElement();
      case 'input':
        return ServerHTMLInputElement();
      case 'button':
        return ServerHTMLButtonElement();
      case 'textarea':
        return ServerHTMLTextAreaElement();
      case 'select':
        return ServerHTMLSelectElement();
      case 'option':
        return ServerHTMLOptionElement();
      case 'a':
        return ServerHTMLAnchorElement();
      case 'img':
        return ServerHTMLImageElement();
      case 'form':
        return ServerHTMLFormElement();
      case 'label':
        return ServerHTMLLabelElement();
      case 'template':
        return ServerHTMLTemplateElement();
      case 'datalist':
        return ServerHTMLDataListElement();
      case 'canvas':
        return ServerHTMLCanvasElement();
      case 'video':
        return ServerHTMLVideoElement();
      case 'audio':
        return ServerHTMLAudioElement();
      case 'dialog':
        return ServerHTMLDialogElement();
      case 'details':
        return ServerHTMLDetailsElement();
      case 'slot':
        return ServerHTMLSlotElement();
      case 'iframe':
        return ServerHTMLIFrameElement();
      case 'table':
        return ServerHTMLTableElement();
      case 'ol':
        return ServerHTMLOListElement();
      case 'li':
        return ServerHTMLLIElement();
      case 'p':
        return ServerHTMLParagraphElement();
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        return ServerHTMLHeadingElement();
      case 'ul':
        return ServerHTMLUListElement();
      case 'pre':
        return ServerHTMLPreElement();
      case 'hr':
        return ServerHTMLHRElement();
      case 'br':
        return ServerHTMLBRElement();
      case 'progress':
        return ServerHTMLProgressElement();
      case 'meter':
        return ServerHTMLMeterElement();
      case 'output':
        return ServerHTMLOutputElement();
      default:
        return ServerHTMLElement();
    }
  }

  @override
  iface.Element createElementNS(String? namespace, String qualifiedName) =>
      createElement(qualifiedName);
  @override
  iface.Text createTextNode(String data) => ServerText(data);
  @override
  iface.Comment createComment(String data) => ServerComment(data);
  @override
  iface.DocumentFragment createDocumentFragment() => ServerDocumentFragment();
  @override
  iface.Element? getElementById(String id) => null;
  @override
  iface.Element? get activeElement => null;
  @override
  iface.Element? querySelector(String selectors) => null;
  @override
  NodeList querySelectorAll(String selectors) => ServerNodeList();
}

// ---------------------------------------------------------------------------
// Text & Comment
// ---------------------------------------------------------------------------

class ServerText extends ServerNode implements iface.Text {
  String _data;
  ServerText(this._data);
  @override
  int get nodeType => Node.TEXT_NODE;
  @override
  String get data => _data;
  @override
  set data(String value) => _data = value;
  @override
  String get wholeText => _data;
  @override
  String? get textContent => _data;
  @override
  set textContent(String? value) => _data = value ?? '';
}

class ServerComment extends ServerNode implements iface.Comment {
  String _data;
  ServerComment(this._data);
  @override
  int get nodeType => Node.COMMENT_NODE;
  @override
  String get data => _data;
  @override
  set data(String value) => _data = value;
  @override
  String? get textContent => _data;
  @override
  set textContent(String? value) => _data = value ?? '';
}

// ---------------------------------------------------------------------------
// MutationObserver
// ---------------------------------------------------------------------------

class ServerMutationObserver implements MutationObserver {
  ServerMutationObserver(MutationCallback callback);
  @override
  void observe(Node target, [MutationObserverInit? options]) {}
  @override
  void disconnect() {}
  @override
  List<MutationRecord> takeRecords() => [];
}
