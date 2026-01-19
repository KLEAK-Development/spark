import '../html/node.dart';

/// Stub implementation for VM/Server.
/// No-op patch.
void patch(dynamic realNode, Node vNode) {
  // No-op on server/VM.
}

/// Stub for mount.
void mount(dynamic parent, Node vNode) {}

/// Stub for patch.

/// Stub implementation for VM/Server.
/// Returns generic object or throws?
/// Should return something creating a structure?
/// Actually createNode is used for patching.
/// On server "patching" doesn't happen. render() returns html.Node strings via toHtml().
/// So this is likely unused on server, but needed for compilation.
dynamic createNode(Node vNode) {
  return Object();
}
