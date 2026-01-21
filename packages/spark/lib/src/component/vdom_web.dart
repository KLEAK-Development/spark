import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../html/node.dart';
import '../html/dsl.dart' as html;
import 'js_callback_web.dart'
    if (dart.library.io) 'js_callback_stub.dart'
    as js_callback;

/// Mounts a VDOM node into a parent element.
/// Handles initial render (appendChild) vs update (patch) logic.
void mount(dynamic parent, Node vNode) {
  if ((parent as JSAny?).isA<web.Node>() != true) return;
  final node = parent as web.Node;

  // Find first significant child (ignore whitespace-only text caused by SSR formatting)
  web.Node? targetNode = node.firstChild;
  while (targetNode != null && _isWhitespace(targetNode)) {
    targetNode = targetNode.nextSibling;
  }

  if (targetNode == null) {
    // If we skipped everything or there was nothing, append.
    node.appendChild(createNode(vNode) as web.Node);
  } else {
    patch(targetNode, vNode);
  }
}

/// Mounts a list of VDOM nodes into a parent element.
/// Each node is mounted sequentially.
void mountList(dynamic parent, List<Node> vNodes) {
  if ((parent as JSAny?).isA<web.Node>() != true) return;
  final node = parent as web.Node;

  // Find all significant children
  final significantNodes = <web.Node>[];
  web.Node? child = node.firstChild;
  while (child != null) {
    if (!_isWhitespace(child)) {
      significantNodes.add(child);
    }
    child = child.nextSibling;
  }

  final len = vNodes.length > significantNodes.length
      ? vNodes.length
      : significantNodes.length;

  for (var i = 0; i < len; i++) {
    if (i >= vNodes.length) {
      // Remove extra DOM nodes
      if (i < significantNodes.length) {
        node.removeChild(significantNodes[i]);
      }
    } else if (i >= significantNodes.length) {
      // Append new nodes
      node.appendChild(createNode(vNodes[i]) as web.Node);
    } else {
      // Patch existing nodes
      patch(significantNodes[i], vNodes[i]);
    }
  }
}

bool _isWhitespace(web.Node node) {
  return node.nodeType == 3 && (node.textContent ?? '').trim().isEmpty;
}

/// Patches an existing DOM element to match a Virtual DOM node.
/// Accepts dynamic [realNode] to support build_runner (VM) compilation where types are stubs.
void patch(dynamic realNode, Node vNode) {
  if ((realNode as JSAny?).isA<web.Node>() != true) return;

  final node = realNode as web.Node;

  if (vNode is html.Text) {
    if (node.nodeType == 3) {
      if (node.textContent != vNode.text) {
        node.textContent = vNode.text;
      }
    } else {
      final newScript = web.document.createTextNode(vNode.text);
      if (node.parentNode != null) {
        node.parentNode!.replaceChild(newScript, node);
      }
    }
  } else if (vNode is html.Element) {
    if (node.nodeType == 1) {
      final el = node as web.HTMLElement;
      if (el.tagName.toLowerCase() != vNode.tag.toLowerCase()) {
        final newNode = createNode(vNode) as web.Node;
        if (node.parentNode != null) {
          node.parentNode!.replaceChild(newNode, node);
        }
      } else {
        _patchElement(el, vNode);
      }
    } else {
      final newNode = createNode(vNode) as web.Node;
      if (node.parentNode != null) {
        node.parentNode!.replaceChild(newNode, node);
      }
    }
  }
}

/// Creates a real DOM node from a VDOM node.
/// Returns dynamic to support build_runner.
dynamic createNode(Node vNode) {
  if (vNode is html.Text) {
    return web.document.createTextNode(vNode.text);
  } else if (vNode is html.Element) {
    final el = web.document.createElement(vNode.tag) as web.HTMLElement;
    _updateAttributes(el, vNode.attributes);
    _updateEvents(el, vNode.events);
    for (final child in vNode.children) {
      el.appendChild(createNode(child) as web.Node);
    }
    return el;
  } else if (vNode is html.RawHtml) {
    final span = web.document.createElement('span');
    span.innerHTML = vNode.html.toJS;
    return span;
  }
  return web.document.createComment('Unknown Node');
}

void _patchElement(web.HTMLElement el, html.Element vNode) {
  _updateAttributes(el, vNode.attributes);
  _updateEvents(el, vNode.events);

  final childNodes = el.childNodes;
  final vChildren = vNode.children;

  // Filter out whitespace nodes from real DOM logic
  final significantNodes = <web.Node>[];
  for (var i = 0; i < childNodes.length; i++) {
    final node = childNodes.item(i);
    if (node != null && !_isWhitespace(node)) {
      significantNodes.add(node);
    }
  }

  final len = vChildren.length > significantNodes.length
      ? vChildren.length
      : significantNodes.length;

  for (var i = 0; i < len; i++) {
    if (i >= vChildren.length) {
      if (i < significantNodes.length) {
        el.removeChild(significantNodes[i]);
      }
    } else if (i >= significantNodes.length) {
      el.appendChild(createNode(vChildren[i]) as web.Node);
    } else {
      patch(significantNodes[i], vChildren[i]);
    }
  }
}

void _updateAttributes(web.HTMLElement el, Map<String, dynamic> attrs) {
  attrs.forEach((key, value) {
    if (value == null) {
      el.removeAttribute(key);
    } else if (value is bool) {
      if (value) {
        el.setAttribute(key, '');
      } else {
        el.removeAttribute(key);
      }
    } else {
      final strVal = value.toString();
      if (el.getAttribute(key) != strVal) {
        el.setAttribute(key, strVal);
      }
    }
  });
}

int _nextListenerId = 0;
final Map<String, Map<String, Function>> _listenersConfig = {};

void _updateEvents(web.HTMLElement el, Map<String, Function> newEvents) {
  String? id = el.getAttribute('data-spark-id');
  if (id == null) {
    id = 's-${_nextId++}';
    el.setAttribute('data-spark-id', id);
  }

  if (!_listenersConfig.containsKey(id)) {
    _listenersConfig[id] = {};
  }

  final oldEvents = _listenersConfig[id] ?? {};

  newEvents.forEach((event, handler) {
    if (!oldEvents.containsKey(event)) {
      final proxy = js_callback.jsCallbackImpl((dynamic e) {
        if ((e as JSAny?).isA<web.Event>() == true) {
          final target = (e as web.Event).currentTarget as web.HTMLElement;
          final dbId = target.getAttribute('data-spark-id');
          if (dbId != null) {
            final handlers = _listenersConfig[dbId];
            if (handlers != null && handlers.containsKey(event)) {
              (handlers[event] as Function)(e);
            }
          }
        }
      });

      final domEvent = event.startsWith('on')
          ? event.substring(2).toLowerCase()
          : event.toLowerCase();

      js_callback.addEventListener(el, domEvent, proxy, null);
    }
  });

  _listenersConfig[id] = newEvents;
}

int get _nextId => _nextListenerId;
set _nextId(int val) => _nextListenerId = val;
