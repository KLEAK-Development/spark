import 'css_value.dart';

/// CSS display property values.
sealed class CssDisplay implements CssValue {
  const CssDisplay._();

  // Common display values
  static const CssDisplay none = _CssDisplayKeyword('none');
  static const CssDisplay block = _CssDisplayKeyword('block');
  static const CssDisplay inline = _CssDisplayKeyword('inline');
  static const CssDisplay inlineBlock = _CssDisplayKeyword('inline-block');
  static const CssDisplay flex = _CssDisplayKeyword('flex');
  static const CssDisplay inlineFlex = _CssDisplayKeyword('inline-flex');
  static const CssDisplay grid = _CssDisplayKeyword('grid');
  static const CssDisplay inlineGrid = _CssDisplayKeyword('inline-grid');
  static const CssDisplay contents = _CssDisplayKeyword('contents');
  static const CssDisplay flowRoot = _CssDisplayKeyword('flow-root');
  static const CssDisplay table = _CssDisplayKeyword('table');
  static const CssDisplay tableRow = _CssDisplayKeyword('table-row');
  static const CssDisplay tableCell = _CssDisplayKeyword('table-cell');
  static const CssDisplay tableRowGroup = _CssDisplayKeyword('table-row-group');
  static const CssDisplay tableHeaderGroup = _CssDisplayKeyword(
    'table-header-group',
  );
  static const CssDisplay tableFooterGroup = _CssDisplayKeyword(
    'table-footer-group',
  );
  static const CssDisplay tableColumn = _CssDisplayKeyword('table-column');
  static const CssDisplay tableColumnGroup = _CssDisplayKeyword(
    'table-column-group',
  );
  static const CssDisplay tableCaption = _CssDisplayKeyword('table-caption');
  static const CssDisplay listItem = _CssDisplayKeyword('list-item');
  static const CssDisplay runIn = _CssDisplayKeyword('run-in');

  /// CSS variable reference.
  factory CssDisplay.variable(String varName) = _CssDisplayVariable;

  /// Raw CSS value escape hatch.
  factory CssDisplay.raw(String value) = _CssDisplayRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssDisplay.global(CssGlobal global) = _CssDisplayGlobal;
}

final class _CssDisplayKeyword extends CssDisplay {
  final String keyword;
  const _CssDisplayKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssDisplayVariable extends CssDisplay {
  final String varName;
  const _CssDisplayVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssDisplayRaw extends CssDisplay {
  final String value;
  const _CssDisplayRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssDisplayGlobal extends CssDisplay {
  final CssGlobal global;
  const _CssDisplayGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
