/// Stub implementation for VM tests
/// Provides no-op implementations that allow vdom tests to compile and run in VM mode
library;

import 'package:spark_framework/src/html/node.dart';

void mount(dynamic parent, Node vNode) {
  // No-op in VM
}

void mountList(dynamic parent, List<Node> vNodes) {
  // No-op in VM
}

void patch(dynamic realNode, Node vNode) {
  // No-op in VM
}

dynamic createNode(Node vNode) {
  // Return a simple object in VM mode
  return Object();
}
