import 'css_value.dart';

/// CSS background-attachment property values.
sealed class CssBackgroundAttachment implements CssValue {
  const CssBackgroundAttachment._();

  // Keyword values
  static const CssBackgroundAttachment scroll = _CssBackgroundAttachmentKeyword(
    'scroll',
  );
  static const CssBackgroundAttachment fixed = _CssBackgroundAttachmentKeyword(
    'fixed',
  );
  static const CssBackgroundAttachment local = _CssBackgroundAttachmentKeyword(
    'local',
  );

  /// Multiple background attachments.
  factory CssBackgroundAttachment.multiple(
    List<CssBackgroundAttachment> attachments,
  ) = _CssBackgroundAttachmentMultiple;

  /// CSS variable reference.
  factory CssBackgroundAttachment.variable(String varName) =
      _CssBackgroundAttachmentVariable;

  /// Raw CSS value escape hatch.
  factory CssBackgroundAttachment.raw(String value) =
      _CssBackgroundAttachmentRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBackgroundAttachment.global(CssGlobal global) =
      _CssBackgroundAttachmentGlobal;
}

final class _CssBackgroundAttachmentKeyword extends CssBackgroundAttachment {
  final String keyword;
  const _CssBackgroundAttachmentKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBackgroundAttachmentMultiple extends CssBackgroundAttachment {
  final List<CssBackgroundAttachment> attachments;
  const _CssBackgroundAttachmentMultiple(this.attachments) : super._();

  @override
  String toCss() => attachments.map((a) => a.toCss()).join(', ');
}

final class _CssBackgroundAttachmentVariable extends CssBackgroundAttachment {
  final String varName;
  const _CssBackgroundAttachmentVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBackgroundAttachmentRaw extends CssBackgroundAttachment {
  final String value;
  const _CssBackgroundAttachmentRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBackgroundAttachmentGlobal extends CssBackgroundAttachment {
  final CssGlobal global;
  const _CssBackgroundAttachmentGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
