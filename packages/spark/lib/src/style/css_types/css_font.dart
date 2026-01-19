import 'css_value.dart';

/// CSS font-weight property values.
sealed class CssFontWeight implements CssValue {
  const CssFontWeight._();

  // Named weights
  static const CssFontWeight normal = _CssFontWeightKeyword('normal');
  static const CssFontWeight bold = _CssFontWeightKeyword('bold');
  static const CssFontWeight bolder = _CssFontWeightKeyword('bolder');
  static const CssFontWeight lighter = _CssFontWeightKeyword('lighter');

  // Numeric weights
  static const CssFontWeight w100 = _CssFontWeightNumeric(100);
  static const CssFontWeight w200 = _CssFontWeightNumeric(200);
  static const CssFontWeight w300 = _CssFontWeightNumeric(300);
  static const CssFontWeight w400 = _CssFontWeightNumeric(400);
  static const CssFontWeight w500 = _CssFontWeightNumeric(500);
  static const CssFontWeight w600 = _CssFontWeightNumeric(600);
  static const CssFontWeight w700 = _CssFontWeightNumeric(700);
  static const CssFontWeight w800 = _CssFontWeightNumeric(800);
  static const CssFontWeight w900 = _CssFontWeightNumeric(900);

  /// Numeric weight (1-1000, typically 100-900 in increments of 100).
  factory CssFontWeight.numeric(int weight) = _CssFontWeightNumeric;

  /// CSS variable reference.
  factory CssFontWeight.variable(String varName) = _CssFontWeightVariable;

  /// Raw CSS value escape hatch.
  factory CssFontWeight.raw(String value) = _CssFontWeightRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssFontWeight.global(CssGlobal global) = _CssFontWeightGlobal;
}

final class _CssFontWeightKeyword extends CssFontWeight {
  final String keyword;
  const _CssFontWeightKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssFontWeightNumeric extends CssFontWeight {
  final int weight;
  const _CssFontWeightNumeric(this.weight) : super._();
  @override
  String toCss() => weight.toString();
}

final class _CssFontWeightVariable extends CssFontWeight {
  final String varName;
  const _CssFontWeightVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssFontWeightRaw extends CssFontWeight {
  final String value;
  const _CssFontWeightRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssFontWeightGlobal extends CssFontWeight {
  final CssGlobal global;
  const _CssFontWeightGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS font-family value.
sealed class CssFontFamily implements CssValue {
  const CssFontFamily._();

  // Generic families
  static const CssFontFamily serif = _CssFontFamilyGeneric('serif');
  static const CssFontFamily sansSerif = _CssFontFamilyGeneric('sans-serif');
  static const CssFontFamily monospace = _CssFontFamilyGeneric('monospace');
  static const CssFontFamily cursive = _CssFontFamilyGeneric('cursive');
  static const CssFontFamily fantasy = _CssFontFamilyGeneric('fantasy');
  static const CssFontFamily systemUi = _CssFontFamilyGeneric('system-ui');
  static const CssFontFamily uiSerif = _CssFontFamilyGeneric('ui-serif');
  static const CssFontFamily uiSansSerif = _CssFontFamilyGeneric(
    'ui-sans-serif',
  );
  static const CssFontFamily uiMonospace = _CssFontFamilyGeneric(
    'ui-monospace',
  );
  static const CssFontFamily uiRounded = _CssFontFamilyGeneric('ui-rounded');
  static const CssFontFamily emoji = _CssFontFamilyGeneric('emoji');
  static const CssFontFamily math = _CssFontFamilyGeneric('math');
  static const CssFontFamily fangsong = _CssFontFamilyGeneric('fangsong');

  /// Named font family (will be quoted).
  factory CssFontFamily.named(String name) = _CssFontFamilyNamed;

  /// Generic font family (not quoted).
  factory CssFontFamily.generic(String name) = _CssFontFamilyGeneric;

  /// Font stack (list of families with fallbacks).
  factory CssFontFamily.stack(List<CssFontFamily> families) =
      _CssFontFamilyStack;

  /// CSS variable reference.
  factory CssFontFamily.variable(String varName) = _CssFontFamilyVariable;

  /// Raw CSS value escape hatch.
  factory CssFontFamily.raw(String value) = _CssFontFamilyRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssFontFamily.global(CssGlobal global) = _CssFontFamilyGlobal;
}

final class _CssFontFamilyGeneric extends CssFontFamily {
  final String family;
  const _CssFontFamilyGeneric(this.family) : super._();
  @override
  String toCss() => family;
}

final class _CssFontFamilyNamed extends CssFontFamily {
  final String name;
  const _CssFontFamilyNamed(this.name) : super._();
  @override
  String toCss() => '"$name"';
}

final class _CssFontFamilyStack extends CssFontFamily {
  final List<CssFontFamily> families;
  const _CssFontFamilyStack(this.families) : super._();
  @override
  String toCss() => families.map((f) => f.toCss()).join(', ');
}

final class _CssFontFamilyVariable extends CssFontFamily {
  final String varName;
  const _CssFontFamilyVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssFontFamilyRaw extends CssFontFamily {
  final String value;
  const _CssFontFamilyRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssFontFamilyGlobal extends CssFontFamily {
  final CssGlobal global;
  const _CssFontFamilyGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS font-style property values.
sealed class CssFontStyle implements CssValue {
  const CssFontStyle._();

  static const CssFontStyle normal = _CssFontStyleKeyword('normal');
  static const CssFontStyle italic = _CssFontStyleKeyword('italic');
  static const CssFontStyle oblique = _CssFontStyleKeyword('oblique');

  /// Oblique with angle.
  factory CssFontStyle.obliqueAngle(String angle) = _CssFontStyleObliqueAngle;

  /// CSS variable reference.
  factory CssFontStyle.variable(String varName) = _CssFontStyleVariable;

  /// Raw CSS value escape hatch.
  factory CssFontStyle.raw(String value) = _CssFontStyleRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssFontStyle.global(CssGlobal global) = _CssFontStyleGlobal;
}

final class _CssFontStyleKeyword extends CssFontStyle {
  final String keyword;
  const _CssFontStyleKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssFontStyleObliqueAngle extends CssFontStyle {
  final String angle;
  const _CssFontStyleObliqueAngle(this.angle) : super._();
  @override
  String toCss() => 'oblique $angle';
}

final class _CssFontStyleVariable extends CssFontStyle {
  final String varName;
  const _CssFontStyleVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssFontStyleRaw extends CssFontStyle {
  final String value;
  const _CssFontStyleRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssFontStyleGlobal extends CssFontStyle {
  final CssGlobal global;
  const _CssFontStyleGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}
