// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// ComponentGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_import

import 'package:spark_framework/spark.dart' hide query, queryAll;

/// Generated reactive implementation of [NotificationDemo].
class NotificationDemo extends SparkComponent {
  static const tag = 'notification-demo';

  late String _permissionStatus;
  late String _statusMessage;
  late String _notifTitle;
  late String _notifBody;
  late String _notifTag;
  Notification? _lastNotification;

  NotificationDemo({
    String permissionStatus = 'unknown',
    String statusMessage = '',
    String notifTitle = 'Test Notification',
    String notifBody = 'Hello from spark_web Notification API!',
    String notifTag = '',
  }) {
    _permissionStatus = permissionStatus;
    _statusMessage = statusMessage;
    _notifTitle = notifTitle;
    _notifBody = notifBody;
    _notifTag = notifTag;
  }

  String get permissionStatus => _permissionStatus;
  set permissionStatus(String v) {
    if (_permissionStatus != v) {
      _permissionStatus = v;
      scheduleUpdate();
    }
  }

  String get statusMessage => _statusMessage;
  set statusMessage(String v) {
    if (_statusMessage != v) {
      _statusMessage = v;
      scheduleUpdate();
    }
  }

  String get notifTitle => _notifTitle;
  set notifTitle(String v) {
    if (_notifTitle != v) {
      _notifTitle = v;
      scheduleUpdate();
    }
  }

  String get notifBody => _notifBody;
  set notifBody(String v) {
    if (_notifBody != v) {
      _notifBody = v;
      scheduleUpdate();
    }
  }

  String get notifTag => _notifTag;
  set notifTag(String v) {
    if (_notifTag != v) {
      _notifTag = v;
      scheduleUpdate();
    }
  }

  @override
  Element build() {
    final permClass = switch (permissionStatus) {
      'granted' => 'permission-value granted',
      'denied' => 'permission-value denied',
      'default' => 'permission-value default',
      _ => 'permission-value unknown',
    };

    return div([
      h2('Notification API Demo'),

      // Permission section
      div(className: 'section', [
        div(className: 'section-title', ['Permission']),
        div([
          span(['Status: ']),
          span(className: permClass, [permissionStatus]),
        ]),
        div(className: 'button-row', [
          button(
            className: 'btn-primary',
            ['Check Permission'],
            onClick: (_) {
              permissionStatus = notificationPermission.value;
              statusMessage =
                  'Permission checked: ${notificationPermission.value}';
            },
          ),
          button(
            className: 'btn-success',
            ['Request Permission'],
            onClick: (_) async {
              statusMessage = 'Requesting permission...';
              final result = await requestNotificationPermission();
              permissionStatus = result.value;
              statusMessage = 'Permission result: ${result.value}';
            },
          ),
        ]),
      ]),

      // Create notification section
      div(className: 'section', [
        div(className: 'section-title', ['Create Notification']),
        div(className: 'form-group', [
          label(['Title']),
          input<String>(
            type: 'text',
            value: notifTitle,
            className: 'text-input',
            onInput: (e) {
              final target = e.target as HTMLInputElement;
              notifTitle = target.value;
            },
          ),
        ]),
        div(className: 'form-group', [
          label(['Body']),
          input<String>(
            type: 'text',
            value: notifBody,
            className: 'text-input',
            onInput: (e) {
              final target = e.target as HTMLInputElement;
              notifBody = target.value;
            },
          ),
        ]),
        div(className: 'form-group', [
          label(['Tag (optional)']),
          input<String>(
            type: 'text',
            value: notifTag,
            className: 'text-input',
            onInput: (e) {
              final target = e.target as HTMLInputElement;
              notifTag = target.value;
            },
          ),
        ]),
        div(className: 'button-row', [
          button(
            className: 'btn-success',
            ['Send Notification'],
            onClick: (_) {
              _lastNotification = createNotification(
                notifTitle,
                NotificationOptions(body: notifBody, tag: notifTag),
              );
              statusMessage =
                  'Notification sent: "${_lastNotification!.title}" '
                  '(body: "${_lastNotification!.body}", '
                  'dir: ${_lastNotification!.dir.value}, '
                  'tag: "${_lastNotification!.tag}")';
            },
          ),
          button(
            className: 'btn-danger',
            ['Close Last Notification'],
            onClick: (_) {
              if (_lastNotification != null) {
                _lastNotification!.close();
                statusMessage = 'Notification closed.';
                _lastNotification = null;
              } else {
                statusMessage = 'No notification to close.';
              }
            },
          ),
        ]),
      ]),

      // Max actions info
      div(className: 'section', [
        div(className: 'section-title', ['Info']),
        div(['Max actions supported: $notificationMaxActions']),
      ]),

      // Status bar
      if (statusMessage.isNotEmpty)
        div(className: 'status-bar', ['Status: $statusMessage']),
    ]);
  }

  @override
  String get tagName => tag;

  @override
  List<String> get observedAttributes => const [
    'permissionstatus',
    'statusmessage',
    'notiftitle',
    'notifbody',
    'notiftag',
  ];

  @override
  void syncAttributes() {
    setAttr('permissionstatus', permissionStatus);
    setAttr('statusmessage', statusMessage);
    setAttr('notiftitle', notifTitle);
    setAttr('notifbody', notifBody);
    setAttr('notiftag', notifTag);
  }

  @override
  Map<String, String> get dumpedAttributes => {
    'permissionstatus': permissionStatus,
    'statusmessage': statusMessage,
    'notiftitle': notifTitle,
    'notifbody': notifBody,
    'notiftag': notifTag,
  };

  @override
  void attributeChangedCallback(
    String name,
    String? oldValue,
    String? newValue,
  ) {
    switch (name) {
      case 'permissionstatus':
        _permissionStatus = newValue ?? '';
        break;
      case 'statusmessage':
        _statusMessage = newValue ?? '';
        break;
      case 'notiftitle':
        _notifTitle = newValue ?? '';
        break;
      case 'notifbody':
        _notifBody = newValue ?? '';
        break;
      case 'notiftag':
        _notifTag = newValue ?? '';
        break;
    }
    super.attributeChangedCallback(name, oldValue, newValue);
  }

  @override
  Stylesheet get adoptedStyleSheets => css({
    ':host': .typed(
      display: .block,
      padding: .all(.px(24)),
      border: CssBorder(width: .px(1), style: .solid, color: .hex('#e0e0e0')),
      borderRadius: .px(12),
      maxWidth: .px(500),
      fontFamily: .raw('system-ui, -apple-system, sans-serif'),
    ),
    'h2': .typed(
      margin: .zero,
      marginBottom: .px(16),
      fontSize: .px(20),
      color: .hex('#333333'),
    ),
    '.section': .typed(
      marginBottom: .px(16),
      padding: .all(.px(12)),
      backgroundColor: .hex('#f8f9fa'),
      borderRadius: .px(8),
    ),
    '.section-title': .typed(
      fontSize: .px(14),
      fontWeight: .bold,
      color: .hex('#555555'),
      marginBottom: .px(8),
    ),
    '.permission-value': .typed(
      fontSize: .px(16),
      fontWeight: .bold,
      padding: .symmetric(.px(4), .px(8)),
      borderRadius: .px(4),
      display: .inlineBlock,
    ),
    '.granted': .typed(
      backgroundColor: .hex('#d4edda'),
      color: .hex('#155724'),
    ),
    '.denied': .typed(backgroundColor: .hex('#f8d7da'), color: .hex('#721c24')),
    '.default': .typed(
      backgroundColor: .hex('#fff3cd'),
      color: .hex('#856404'),
    ),
    '.unknown': .typed(
      backgroundColor: .hex('#e2e3e5'),
      color: .hex('#383d41'),
    ),
    '.button-row': .typed(
      display: .flex,
      gap: .px(8),
      marginTop: .px(8),
      flexWrap: .wrap,
    ),
    'button': .typed(
      padding: .symmetric(.px(8), .px(16)),
      fontSize: .px(14),
      border: .none,
      borderRadius: .px(6),
      cursor: .pointer,
      fontWeight: .bold,
      transition: .raw('background-color 0.2s, transform 0.1s'),
    ),
    'button:active': .typed(transform: 'scale(0.97)'),
    '.btn-primary': .typed(backgroundColor: .hex('#2196f3'), color: .white),
    '.btn-primary:hover': .typed(backgroundColor: .hex('#1976d2')),
    '.btn-success': .typed(backgroundColor: .hex('#4caf50'), color: .white),
    '.btn-success:hover': .typed(backgroundColor: .hex('#388e3c')),
    '.btn-danger': .typed(backgroundColor: .hex('#f44336'), color: .white),
    '.btn-danger:hover': .typed(backgroundColor: .hex('#d32f2f')),
    '.form-group': .typed(marginBottom: .px(10)),
    '.form-group label': .typed(
      display: .block,
      fontSize: .px(13),
      color: .hex('#555555'),
      marginBottom: .px(4),
    ),
    '.text-input': .typed(
      width: .percent(100),
      padding: .all(.px(8)),
      fontSize: .px(14),
      border: CssBorder(width: .px(1), style: .solid, color: .hex('#cccccc')),
      borderRadius: .px(4),
    ),
    '.status-bar': .typed(
      marginTop: .px(12),
      padding: .all(.px(10)),
      backgroundColor: .hex('#e8f4fd'),
      borderRadius: .px(6),
      fontSize: .px(13),
      color: .hex('#0c5460'),
      borderLeft: CssBorder(
        width: .px(4),
        style: .solid,
        color: .hex('#2196f3'),
      ),
    ),
  });
}
