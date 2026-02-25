/// DOM Element types matching the MDN Web API.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Element
library;

import 'canvas.dart';
import 'core.dart';
import 'collections.dart';
import 'css.dart';
import 'file.dart';

// ---------------------------------------------------------------------------
// ValidityState
// ---------------------------------------------------------------------------

/// The validity state of a form element.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/ValidityState
abstract class ValidityState {
  bool get valueMissing;
  bool get typeMismatch;
  bool get patternMismatch;
  bool get tooLong;
  bool get tooShort;
  bool get rangeUnderflow;
  bool get rangeOverflow;
  bool get stepMismatch;
  bool get badInput;
  bool get customError;
  bool get valid;
}

// ---------------------------------------------------------------------------
// HTMLCollection
// ---------------------------------------------------------------------------

/// A collection of [Element] objects.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection
abstract class HTMLCollection {
  int get length;
  Element? item(int index);
}

// ---------------------------------------------------------------------------
// Element
// ---------------------------------------------------------------------------

/// Represents a DOM Element.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Element
abstract class Element implements Node {
  String get tagName;
  String get id;
  set id(String value);
  String get className;
  set className(String value);

  String get innerHTML;
  set innerHTML(String value);
  String get outerHTML;

  String? get namespaceURI;

  NamedNodeMap get attributes;
  DOMTokenList get classList;

  String? getAttribute(String name);
  void setAttribute(String name, String value);
  void removeAttribute(String name);
  bool hasAttribute(String name);

  Element? querySelector(String selectors);
  NodeList querySelectorAll(String selectors);
  Element? closest(String selectors);
  HTMLCollection get children;

  void remove();
  void append(Node node);
}

// ---------------------------------------------------------------------------
// HTMLElement
// ---------------------------------------------------------------------------

/// Represents an HTML Element.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement
abstract class HTMLElement implements Element {
  String get innerText;
  set innerText(String value);
  bool get hidden;
  set hidden(bool value);
  String get title;
  set title(String value);

  void focus();
  void blur();

  CSSStyleDeclaration get style;
  ShadowRoot? get shadowRoot;

  ShadowRoot attachShadow(ShadowRootInit init);
}

/// Options for [HTMLElement.attachShadow].
class ShadowRootInit {
  final String mode;
  const ShadowRootInit({required this.mode});
}

// ---------------------------------------------------------------------------
// Specific HTMLElement subclasses
// ---------------------------------------------------------------------------

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement
abstract class HTMLDivElement implements HTMLElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLSpanElement
abstract class HTMLSpanElement implements HTMLElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLParagraphElement
abstract class HTMLParagraphElement implements HTMLElement {}

/// The base interface for `<input>` elements.
///
/// This interface contains only the properties and methods that apply to
/// almost all input types. For type-specific properties (like `min`/`max`
/// for numbers or `checked` for checkboxes), cast this to one of the
/// specialized sub-interfaces like [HTMLNumericInputElement] or
/// [HTMLCheckableInputElement].
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement
abstract class HTMLInputElement implements HTMLElement {
  String get type;
  set type(String val);
  String get value;
  set value(String val);
  String get defaultValue;
  set defaultValue(String val);
  String get name;
  set name(String val);
  bool get disabled;
  set disabled(bool val);
  bool get autofocus;
  set autofocus(bool val);
  bool get required;
  set required(bool val);

  /// Returns the form element that contains this input.
  HTMLFormElement? get form;

  /// Returns a list of label elements associated with this input.
  NodeList get labels;

  /// Returns the datalist element that contains the options for this input.
  HTMLDataListElement? get list;

  // -- Validation -----------------------------------------------------------

  /// Whether the element is a candidate for constraint validation.
  bool get willValidate;

  /// The current validity state of the element.
  ValidityState get validity;

  /// The localized message that describes the validation constraints.
  String get validationMessage;

  /// Checks if the element has any constraints and whether it satisfies them.
  bool checkValidity();

  /// Reports the validity of the element to the user agent.
  bool reportValidity();

  /// Sets a custom validation message.
  void setCustomValidity(String error);

  // -- Methods --------------------------------------------------------------

  /// Selects all text in the input element.
  void select();

  /// Shows a browser picker for the input (e.g. date picker, color picker).
  void showPicker();
}

/// Specialized interface for text-like input types.
///
/// Applies to: `text`, `search`, `url`, `tel`, `email`, `password`.
abstract class HTMLTextInputElement implements HTMLInputElement {
  String get placeholder;
  set placeholder(String val);
  bool get readOnly;
  set readOnly(bool val);
  int get size;
  set size(int val);
  int get maxLength;
  set maxLength(int val);
  int get minLength;
  set minLength(int val);
  String get pattern;
  set pattern(String val);
  String get autocomplete;
  set autocomplete(String val);
  String get dirName;
  set dirName(String val);

  int? get selectionStart;
  set selectionStart(int? val);
  int? get selectionEnd;
  set selectionEnd(int? val);
  String? get selectionDirection;
  set selectionDirection(String? val);

  void setRangeText(
    String replacement, [
    int? start,
    int? end,
    String? selectionMode,
  ]);
  void setSelectionRange(int start, int end, [String? direction]);
}

/// Specialized interface for numeric and date/time input types.
///
/// Applies to: `number`, `range`, `date`, `datetime-local`, `month`, `time`, `week`.
abstract class HTMLNumericInputElement implements HTMLInputElement {
  String get min;
  set min(String val);
  String get max;
  set max(String val);
  String get step;
  set step(String val);
  double? get valueAsNumber;
  set valueAsNumber(double? val);
  DateTime? get valueAsDate;
  set valueAsDate(DateTime? val);

  void stepDown([int n]);
  void stepUp([int n]);
}

/// Specialized interface for checkable input types.
///
/// Applies to: `checkbox`, `radio`.
abstract class HTMLCheckableInputElement implements HTMLInputElement {
  bool get checked;
  set checked(bool val);
  bool get defaultChecked;
  set defaultChecked(bool val);
  bool get indeterminate;
  set indeterminate(bool val);
}

/// Specialized interface for file input types.
///
/// Applies to: `file`.
abstract class HTMLFileInputElement implements HTMLInputElement {
  String get accept;
  set accept(String val);
  String get capture;
  set capture(String val);
  bool get multiple;
  set multiple(bool val);
  FileList? get files;
  set files(FileList? val);
}

/// Specialized interface for button and image input types.
///
/// Applies to: `button`, `submit`, `reset`, `image`.
abstract class HTMLButtonInputElement implements HTMLInputElement {
  // Only for `image` type
  String get alt;
  set alt(String val);
  String get src;
  set src(String val);
  int get height;
  set height(int val);
  int get width;
  set width(int val);

  // For `submit` and `image` types
  String get formAction;
  set formAction(String val);
  String get formEnctype;
  set formEnctype(String val);
  String get formMethod;
  set formMethod(String val);
  bool get formNoValidate;
  set formNoValidate(bool val);
  String get formTarget;
  set formTarget(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement
abstract class HTMLTextAreaElement implements HTMLElement {
  String get value;
  set value(String val);
  String get placeholder;
  set placeholder(String val);
  bool get disabled;
  set disabled(bool val);
  int get rows;
  set rows(int val);
  int get cols;
  set cols(int val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLButtonElement
abstract class HTMLButtonElement implements HTMLElement {
  bool get disabled;
  set disabled(bool val);
  String get type;
  set type(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLSelectElement
abstract class HTMLSelectElement implements HTMLElement {
  String get value;
  set value(String val);
  int get selectedIndex;
  set selectedIndex(int val);
  bool get disabled;
  set disabled(bool val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLOptionElement
abstract class HTMLOptionElement implements HTMLElement {
  String get value;
  set value(String val);
  String get text;
  set text(String val);
  bool get selected;
  set selected(bool val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLAnchorElement
abstract class HTMLAnchorElement implements HTMLElement {
  String get href;
  set href(String val);
  String get target;
  set target(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement
abstract class HTMLImageElement implements HTMLElement {
  String get src;
  set src(String val);
  String get alt;
  set alt(String val);
  int get width;
  set width(int val);
  int get height;
  set height(int val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement
abstract class HTMLFormElement implements HTMLElement {
  String get action;
  set action(String val);
  String get method;
  set method(String val);
  void submit();
  void reset();
  bool reportValidity();
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement
abstract class HTMLLabelElement implements HTMLElement {
  String get htmlFor;
  set htmlFor(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLTemplateElement
abstract class HTMLTemplateElement implements HTMLElement {
  DocumentFragment get content;
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLDataListElement
abstract class HTMLDataListElement implements HTMLElement {
  HTMLCollection get options;
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement
abstract class HTMLCanvasElement implements HTMLElement {
  int get width;
  set width(int val);
  int get height;
  set height(int val);

  /// Returns a rendering context for the canvas.
  ///
  /// Use [CanvasContextType.canvas2d] for a [CanvasRenderingContext2D].
  RenderingContext? getContext(
    CanvasContextType contextType, [
    Map<String, Object?>? options,
  ]);

  String toDataURL([String type, num? quality]);
}

/// Base class for media elements (audio & video).
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement
abstract class HTMLMediaElement implements HTMLElement {
  String get src;
  set src(String val);
  String get currentSrc;
  double get currentTime;
  set currentTime(num val);
  double get duration;
  bool get paused;
  bool get ended;
  bool get loop;
  set loop(bool val);
  double get volume;
  set volume(num val);
  bool get muted;
  set muted(bool val);
  bool get autoplay;
  set autoplay(bool val);
  bool get controls;
  set controls(bool val);
  double get playbackRate;
  set playbackRate(num val);
  int get readyState;
  int get networkState;
  String get preload;
  set preload(String val);
  Future<void> play();
  void pause();
  void load();
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLVideoElement
abstract class HTMLVideoElement implements HTMLMediaElement {
  int get width;
  set width(int val);
  int get height;
  set height(int val);
  int get videoWidth;
  int get videoHeight;
  String get poster;
  set poster(String val);
  bool get playsInline;
  set playsInline(bool val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLAudioElement
abstract class HTMLAudioElement implements HTMLMediaElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLDialogElement
abstract class HTMLDialogElement implements HTMLElement {
  bool get open;
  set open(bool val);
  String get returnValue;
  set returnValue(String val);
  void show();
  void showModal();
  void close([String? returnValue]);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLDetailsElement
abstract class HTMLDetailsElement implements HTMLElement {
  bool get open;
  set open(bool val);
  String get name;
  set name(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLSlotElement
abstract class HTMLSlotElement implements HTMLElement {
  String get name;
  set name(String val);
  List<Node> assignedNodes();
  List<Element> assignedElements();
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLIFrameElement
abstract class HTMLIFrameElement implements HTMLElement {
  String get src;
  set src(String val);
  String get name;
  set name(String val);
  String get allow;
  set allow(String val);
  bool get allowFullscreen;
  set allowFullscreen(bool val);
  String get width;
  set width(String val);
  String get height;
  set height(String val);
  String get loading;
  set loading(String val);
  String get referrerPolicy;
  set referrerPolicy(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLTableElement
abstract class HTMLTableElement implements HTMLElement {
  HTMLElement? get caption;
  set caption(HTMLElement? val);
  HTMLTableSectionElement? get tHead;
  set tHead(HTMLTableSectionElement? val);
  HTMLTableSectionElement? get tFoot;
  set tFoot(HTMLTableSectionElement? val);
  HTMLTableSectionElement createTBody();
  HTMLTableRowElement insertRow([int index = -1]);
  void deleteRow(int index);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLTableSectionElement
abstract class HTMLTableSectionElement implements HTMLElement {
  HTMLTableRowElement insertRow([int index = -1]);
  void deleteRow(int index);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLTableRowElement
abstract class HTMLTableRowElement implements HTMLElement {
  int get rowIndex;
  int get sectionRowIndex;
  HTMLTableCellElement insertCell([int index = -1]);
  void deleteCell(int index);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLTableCellElement
abstract class HTMLTableCellElement implements HTMLElement {
  int get colSpan;
  set colSpan(int val);
  int get rowSpan;
  set rowSpan(int val);
  int get cellIndex;
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLHeadingElement
abstract class HTMLHeadingElement implements HTMLElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLUListElement
abstract class HTMLUListElement implements HTMLElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLOListElement
abstract class HTMLOListElement implements HTMLElement {
  bool get reversed;
  set reversed(bool val);
  int get start;
  set start(int val);
  String get type;
  set type(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLLIElement
abstract class HTMLLIElement implements HTMLElement {
  int get value;
  set value(int val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLPreElement
abstract class HTMLPreElement implements HTMLElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLHRElement
abstract class HTMLHRElement implements HTMLElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLBRElement
abstract class HTMLBRElement implements HTMLElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLProgressElement
abstract class HTMLProgressElement implements HTMLElement {
  double get value;
  set value(double val);
  double get max;
  set max(double val);
  double get position;
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMeterElement
abstract class HTMLMeterElement implements HTMLElement {
  double get value;
  set value(double val);
  double get min;
  set min(double val);
  double get max;
  set max(double val);
  double get low;
  set low(double val);
  double get high;
  set high(double val);
  double get optimum;
  set optimum(double val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLOutputElement
abstract class HTMLOutputElement implements HTMLElement {
  String get value;
  set value(String val);
  String get defaultValue;
  set defaultValue(String val);
  String get name;
  set name(String val);
  String get type;
  DOMTokenList get htmlFor;
}

// ---------------------------------------------------------------------------
// DocumentFragment
// ---------------------------------------------------------------------------

/// See: https://developer.mozilla.org/en-US/docs/Web/API/DocumentFragment
abstract class DocumentFragment implements Node {
  Element? querySelector(String selectors);
  NodeList querySelectorAll(String selectors);
}

// ---------------------------------------------------------------------------
// ShadowRoot
// ---------------------------------------------------------------------------

/// See: https://developer.mozilla.org/en-US/docs/Web/API/ShadowRoot
abstract class ShadowRoot implements DocumentFragment {
  Element get host;
  String get mode;
  Element? get firstElementChild;

  @override
  Element? querySelector(String selectors);
  @override
  NodeList querySelectorAll(String selectors);

  List<CSSStyleSheet> get adoptedStyleSheets;
  set adoptedStyleSheets(List<CSSStyleSheet> sheets);
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

/// See: https://developer.mozilla.org/en-US/docs/Web/API/Document
abstract class Document implements Node {
  Element? get documentElement;
  HTMLElement? get body;
  HTMLElement? get head;

  Element createElement(String tagName);
  Element createElementNS(String? namespace, String qualifiedName);
  Text createTextNode(String data);
  Comment createComment(String data);
  DocumentFragment createDocumentFragment();

  Element? getElementById(String id);
  Element? get activeElement;
  Element? querySelector(String selectors);
  NodeList querySelectorAll(String selectors);
}

// ---------------------------------------------------------------------------
// Text & Comment nodes
// ---------------------------------------------------------------------------

/// See: https://developer.mozilla.org/en-US/docs/Web/API/Text
abstract class Text implements Node {
  String get data;
  set data(String value);
  String get wholeText;
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/Comment
abstract class Comment implements Node {
  String get data;
  set data(String value);
}
