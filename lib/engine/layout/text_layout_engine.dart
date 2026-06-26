import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide TextHeightBehavior;
import 'package:flutter/painting.dart';

import 'package:kalima/engine/document/delta_format.dart';

class TextMeasurement {
  final double width;
  final double height;
  final double baselineOffset;
  final int glyphCount;

  const TextMeasurement({
    this.width = 0.0,
    this.height = 0.0,
    this.baselineOffset = 0.0,
    this.glyphCount = 0,
  });
}

class GlyphInfo {
  final String char;
  final double advance;
  final double xOffset;
  final bool isRtl;

  const GlyphInfo({
    required this.char,
    required this.advance,
    required this.xOffset,
    this.isRtl = false,
  });
}

class TextLayoutEngine {
  final double defaultFontSize;
  final String defaultFontFamily;
  final double devicePixelRatio;

  TextLayoutEngine({
    this.defaultFontSize = 14.0,
    this.defaultFontFamily = 'Cairo',
    this.devicePixelRatio = 1.0,
  });

  static const _kashidaChars = '\u0640';
  static const _arabicPresentationFormsB = 0xFE70;
  static const _arabicPresentationFormsA = 0xFB50;
  static const _arabicBlockStart = 0x0600;
  static const _arabicBlockEnd = 0x06FF;
  static const _arabicSupplementStart = 0x0750;
  static const _arabicSupplementEnd = 0x077F;
  static const _arabicExtendedAStart = 0x08A0;
  static const _arabicExtendedAEnd = 0x08FF;
  static const _arabicExtendedBStart = 0x0870;
  static const _arabicExtendedBEnd = 0x089F;

  static bool isArabicChar(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= _arabicBlockStart && code <= _arabicBlockEnd) ||
        (code >= _arabicSupplementStart && code <= _arabicSupplementEnd) ||
        (code >= _arabicExtendedAStart && code <= _arabicExtendedAEnd) ||
        (code >= _arabicExtendedBStart && code <= _arabicExtendedBEnd) ||
        (code >= _arabicPresentationFormsB && code <= 0xFEFF) ||
        (code >= _arabicPresentationFormsA && code <= 0xFDFF) ||
        (code >= 0x0600 && code <= 0x06FF) ||
        code == 0x200B ||
        code == 0x200C ||
        code == 0x200D ||
        code == 0x200E ||
        code == 0x200F ||
        code == 0x061C;
  }

  static bool isArabicScript(String text) {
    return text.codeUnits.any((code) =>
        (code >= 0x0600 && code <= 0x06FF) ||
        (code >= 0x0750 && code <= 0x077F) ||
        (code >= 0x08A0 && code <= 0x08FF) ||
        (code >= 0x0870 && code <= 0x089F) ||
        (code >= 0xFB50 && code <= 0xFDFF) ||
        (code >= 0xFE70 && code <= 0xFEFF));
  }

  static bool isRtlCharacter(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return isArabicChar(char) || code >= 0x0590 && code <= 0x05FF;
  }

  TextMeasurement measureText(
    String text, {
    TextAttributes? attributes,
    double maxWidth = double.infinity,
  }) {
    final attrs = attributes ?? const TextAttributes();
    final tp = _buildTextPainter(text, attrs, maxWidth: maxWidth);
    tp.layout(maxWidth: maxWidth);
    return TextMeasurement(
      width: tp.width,
      height: tp.height,
      baselineOffset: _measureBaseline(tp),
      glyphCount: text.length,
    );
  }

  TextMeasurement measureUnconstrained(String text, {TextAttributes? attributes}) {
    return measureText(text, attributes: attributes, maxWidth: double.infinity);
  }

  double measureTextWidth(String text, {TextAttributes? attributes}) {
    return measureText(text, attributes: attributes).width;
  }

  double measureTextHeight(String text, {TextAttributes? attributes, double maxWidth = double.infinity}) {
    return measureText(text, attributes: attributes, maxWidth: maxWidth).height;
  }

  List<TextBox> getBoxesForRange(
    String text, {
    required int start,
    required int end,
    TextAttributes? attributes,
    double maxWidth = double.infinity,
  }) {
    final tp = _buildTextPainter(text, attributes ?? const TextAttributes());
    tp.layout(maxWidth: maxWidth);
    return tp.getBoxesForSelection(
      TextSelection(
        baseOffset: start,
        extentOffset: end,
      ),
    );
  }

  Offset getOffsetForPosition(
    String text,
    int position, {
    TextAttributes? attributes,
    double maxWidth = double.infinity,
  }) {
    final tp = _buildTextPainter(text, attributes ?? const TextAttributes());
    tp.layout(maxWidth: maxWidth);
    return tp.getOffsetForCaret(
      TextPosition(offset: position, affinity: TextAffinity.downstream),
      Rect.zero,
    );
  }

  int getPositionForOffset(
    String text,
    Offset offset, {
    TextAttributes? attributes,
    double maxWidth = double.infinity,
  }) {
    final tp = _buildTextPainter(text, attributes ?? const TextAttributes());
    tp.layout(maxWidth: maxWidth);
    return tp.getPositionForOffset(offset);
  }

  double kashidaJustify(String text, double targetWidth, TextAttributes attributes) {
    if (!isArabicScript(text)) return 0.0;
    if (text.length < 2) return 0.0;

    final currentWidth = measureTextWidth(text, attributes: attributes);
    final gap = targetWidth - currentWidth;
    if (gap <= 0) return 0.0;

    final kashidaPositions = <int>[];
    for (int i = 0; i < text.length - 1; i++) {
      final code = text.codeUnitAt(i);
      if (_canTakeKashida(code)) {
        kashidaPositions.add(i);
      }
    }

    if (kashidaPositions.isEmpty) return 0.0;

    final kashidaWidth = measureTextWidth(_kashidaChars, attributes: attributes);
    if (kashidaWidth <= 0) return 0.0;

    final kashidaCount = (gap / kashidaWidth).ceil();
    return kashidaCount * kashidaWidth;
  }

  String insertKashida(String text, double targetWidth, TextAttributes attributes) {
    if (!isArabicScript(text)) return text;
    if (text.length < 2) return text;

    final currentWidth = measureTextWidth(text, attributes: attributes);
    final gap = targetWidth - currentWidth;
    if (gap <= 0) return text;

    final kashidaPositions = <int>[];
    for (int i = 0; i < text.length - 1; i++) {
      final code = text.codeUnitAt(i);
      if (_canTakeKashida(code)) {
        kashidaPositions.add(i);
      }
    }

    if (kashidaPositions.isEmpty) return text;

    final kashidaWidth = measureTextWidth(_kashidaChars, attributes: attributes);
    if (kashidaWidth <= 0) return text;

    final kashidaNeeded = (gap / kashidaWidth).ceil();
    final kashidaPerGap = kashidaNeeded / kashidaPositions.length;

    final buffer = StringBuffer();
    int kashidaInserted = 0;

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (kashidaPositions.contains(i)) {
        final count = ((i + 1) / kashidaPositions.length * kashidaNeeded)
                .round() -
            kashidaInserted;
        for (int k = 0; k < max(0, count); k++) {
          buffer.write(_kashidaChars);
        }
        kashidaInserted += max(0, count);
      }
    }

    return buffer.toString();
  }

  bool _canTakeKashida(int code) {
    const kashidaAccepting = <int>{
      0x0627, 0x0623, 0x0625, 0x0622, 0x0621, 0x0628, 0x062A, 0x062B,
      0x062C, 0x062D, 0x062E, 0x0633, 0x0634, 0x0635, 0x0636, 0x0637,
      0x0638, 0x0639, 0x063A, 0x0641, 0x0642, 0x0643, 0x0644, 0x0645,
      0x0646, 0x0647, 0x0648, 0x0649, 0x064A, 0x0629, 0x0624, 0x0626,
      0x06CC, 0x06A9, 0x06AF, 0x06D0, 0x06D2, 0x06BA, 0x06BE, 0x06C1,
      0x06C2, 0x06C3, 0x06D5, 0x06C0, 0x06A4, 0x06A6, 0x06A9, 0x06AD,
      0x06AF, 0x06B1, 0x06B3, 0x06BE, 0x0688, 0x0689, 0x068A, 0x068B,
      0x068C, 0x068D, 0x068E, 0x068F, 0x0690, 0x0691, 0x0692, 0x0693,
      0x0694, 0x0695, 0x0696, 0x0697, 0x0698, 0x0699, 0x06A0,
    };
    return kashidaAccepting.contains(code);
  }

  double _measureBaseline(TextPainter tp) {
    return tp.height;
  }

  TextPainter _buildTextPainter(String text, TextAttributes attributes, {double maxWidth = double.infinity}) {
    final style = _buildTextStyle(attributes);
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.rtl,
      textAlign: _toFlutterTextAlign(attributes.align),
      textScaleFactor: 1.0,
      maxLines: null,
    )..layout(maxWidth: maxWidth);
  }

  TextStyle _buildTextStyle(TextAttributes attrs) {
    return TextStyle(
      fontWeight: attrs.bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: attrs.italic ? FontStyle.italic : FontStyle.normal,
      decoration: _buildTextDecoration(attrs),
      fontFamily: _resolveFontFamily(attrs),
      fontSize: attrs.fontSize ?? defaultFontSize,
      color: attrs.color != null ? Color(attrs.color!) : null,
      backgroundColor: attrs.highlight != null
          ? Color(attrs.highlight!)
          : null,
      decorationColor: attrs.color != null ? Color(attrs.color!) : null,
    );
  }

  TextDecoration? _buildTextDecoration(TextAttributes attrs) {
    if (attrs.underline && attrs.strikethrough) {
      return TextDecoration.combine([
        TextDecoration.underline,
        TextDecoration.lineThrough,
      ]);
    }
    if (attrs.underline) return TextDecoration.underline;
    if (attrs.strikethrough) return TextDecoration.lineThrough;
    return null;
  }

  String _resolveFontFamily(TextAttributes attrs) {
    if (attrs.fontFamily != null && attrs.fontFamily!.isNotEmpty) {
      return attrs.fontFamily!;
    }
    if (attrs.heading != null) {
      switch (attrs.heading) {
        case 'h1':
        case 'h2':
        case 'h3':
          return 'Amiri';
        default:
          return defaultFontFamily;
      }
    }
    return defaultFontFamily;
  }

  TextAlign _toFlutterTextAlign(TextAlignHorizontal? align) {
    switch (align) {
      case TextAlignHorizontal.left:
        return TextAlign.left;
      case TextAlignHorizontal.right:
        return TextAlign.right;
      case TextAlignHorizontal.center:
        return TextAlign.center;
      case TextAlignHorizontal.justify:
        return TextAlign.justify;
      case null:
        return TextAlign.right;
    }
  }
}
