import 'dart:math';

import 'package:collection/collection.dart';
import 'package:kalima/engine/document/delta_format.dart';

import 'text_layout_engine.dart';

class LineLayout extends Equatable {
  final int startOffset;
  final int endOffset;
  final double width;
  final double height;
  final double baselineOffset;
  final double lineSpacing;
  final List<GlyphPosition> glyphs;
  final TextAttributes attributes;
  final bool isRtl;
  final bool isLastLineOfParagraph;

  const LineLayout({
    required this.startOffset,
    required this.endOffset,
    this.width = 0.0,
    this.height = 0.0,
    this.baselineOffset = 0.0,
    this.lineSpacing = 0.0,
    this.glyphs = const [],
    this.attributes = const TextAttributes(),
    this.isRtl = true,
    this.isLastLineOfParagraph = false,
  });

  int get charCount => endOffset - startOffset;

  LineLayout copyWith({
    int? startOffset,
    int? endOffset,
    double? width,
    double? height,
    double? baselineOffset,
    double? lineSpacing,
    List<GlyphPosition>? glyphs,
    TextAttributes? attributes,
    bool? isRtl,
    bool? isLastLineOfParagraph,
  }) {
    return LineLayout(
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      width: width ?? this.width,
      height: height ?? this.height,
      baselineOffset: baselineOffset ?? this.baselineOffset,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      glyphs: glyphs ?? this.glyphs,
      attributes: attributes ?? this.attributes,
      isRtl: isRtl ?? this.isRtl,
      isLastLineOfParagraph:
          isLastLineOfParagraph ?? this.isLastLineOfParagraph,
    );
  }

  @override
  List<Object?> get props => [
        startOffset,
        endOffset,
        width,
        height,
        baselineOffset,
        lineSpacing,
        glyphs,
        attributes,
        isRtl,
        isLastLineOfParagraph,
      ];
}

class GlyphPosition extends Equatable {
  final int index;
  final String char;
  final double x;
  final double y;
  final double advance;

  const GlyphPosition({
    required this.index,
    required this.char,
    required this.x,
    required this.y,
    required this.advance,
  });

  @override
  List<Object?> get props => [index, char, x, y, advance];
}

enum BreakPriority {
  forbidden,
  normal,
  hyphen,
  space,
  zeroWidthSpace,
  mandatory,
}

class _BreakPoint {
  final int position;
  final BreakPriority priority;
  final double score;

  const _BreakPoint(this.position, this.priority, this.score);
}

class LineBreaker {
  final TextLayoutEngine _textEngine;

  static const double _maxWidowRatio = 0.3;
  static const double _minOrphanRatio = 0.3;
  static const int _maxConsecutiveHyphens = 3;

  LineBreaker({required TextLayoutEngine textEngine})
      : _textEngine = textEngine;

  List<LineLayout> breakLines(
    Delta delta, {
    double maxWidth = 612.0,
    bool isRtl = true,
    double lineSpacing = 2.0,
    double paragraphSpacing = 8.0,
    double firstLineIndent = 0.0,
  }) {
    final text = delta.plainText ?? '';
    if (text.isEmpty) {
      final measure = _textEngine.measureText(' ');
      return [
        LineLayout(
          startOffset: 0,
          endOffset: 0,
          width: 0,
          height: measure.height,
          baselineOffset: measure.baselineOffset,
          lineSpacing: 0,
          isRtl: isRtl,
          isLastLineOfParagraph: true,
        ),
      ];
    }

    final runs = delta.toFormatRanges();
    final breakPoints = _findBreakPoints(text, runs, maxWidth, firstLineIndent);
    final lines = _buildLines(text, runs, breakPoints, maxWidth, isRtl, lineSpacing);

    return _applyWidowOrphanControl(lines, lineSpacing);
  }

  List<_BreakPoint> _findBreakPoints(
    String text,
    List<FormatRange> runs,
    double maxWidth,
    double firstLineIndent,
  ) {
    final points = <_BreakPoint>[_BreakPoint(0, BreakPriority.mandatory, 0.0)];
    double currentWidth = firstLineIndent;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final attrs = _getAttributesAt(runs, i);
      final charWidth = _textEngine.measureTextWidth(char, attributes: attrs);
      currentWidth += charWidth;

      if (currentWidth > maxWidth) {
        var bestPoint = _findBestBreakPoint(points, i, text, runs);
        points.add(_BreakPoint(
          bestPoint?.position ?? i,
          BreakPriority.normal,
          currentWidth - maxWidth,
        ));
        currentWidth = charWidth;
        continue;
      }

      final priority = _getBreakPriority(char, i, text);
      if (priority != BreakPriority.forbidden) {
        points.add(_BreakPoint(i + 1, priority, currentWidth));
      }
    }

    points.add(_BreakPoint(text.length, BreakPriority.mandatory, currentWidth));
    return points;
  }

  BreakPriority _getBreakPriority(String char, int index, String text) {
    if (index >= text.length - 1) {
      return BreakPriority.mandatory;
    }

    if (char == ' ' || char == '\u00A0') {
      return BreakPriority.space;
    }

    if (char == '-' || char == '\u2010' || char == '\u2011') {
      return BreakPriority.hyphen;
    }

    if (char == '\u200B') {
      return BreakPriority.zeroWidthSpace;
    }

    if (char == '\n') {
      return BreakPriority.mandatory;
    }

    if (_isArabicBreakOpportunity(char, text, index)) {
      return BreakPriority.normal;
    }

    if (_isCjkCharacter(char)) {
      return BreakPriority.normal;
    }

    return BreakPriority.forbidden;
  }

  bool _isArabicBreakOpportunity(String char, String text, int index) {
    if (!TextLayoutEngine.isArabicChar(char)) return false;

    if (index > 0) {
      final prev = text[index - 1];
      if (prev == ' ') return false;
    }

    if (index < text.length - 1) {
      final next = text[index + 1];
      if (next == ' ' || _isArabicPunctuation(next)) return true;
    }

    return _isArabicPunctuation(char);
  }

  bool _isArabicPunctuation(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= 0x060C && code <= 0x061E) ||
        (code >= 0x0660 && code <= 0x066D) ||
        code == 0x061B ||
        code == 0x061F ||
        code == 0xFE30 ||
        code == 0xFE31 ||
        code == 0xFE32 ||
        code == 0xFE33 ||
        code == 0xFE34 ||
        code == 0xFE35 ||
        code == 0xFE36 ||
        code == 0xFE37 ||
        code == 0xFE38 ||
        code == 0xFE39 ||
        code == 0xFE3A ||
        code == 0xFE3B ||
        code == 0xFE3C ||
        code == 0xFE3D ||
        code == 0xFE3E ||
        code == 0xFE3F ||
        code == 0xFE40 ||
        code == 0xFE41 ||
        code == 0xFE42 ||
        code == 0xFE43 ||
        code == 0xFE44;
  }

  bool _isCjkCharacter(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= 0x4E00 && code <= 0x9FFF) ||
        (code >= 0x3000 && code <= 0x303F) ||
        (code >= 0xFF00 && code <= 0xFFEF);
  }

  _BreakPoint? _findBestBreakPoint(
    List<_BreakPoint> points,
    int currentPosition,
    String text,
    List<FormatRange> runs,
  ) {
    _BreakPoint? best;
    double bestScore = double.negativeInfinity;

    for (final point in points) {
      if (point.position >= currentPosition) continue;

      double score = 0;
      switch (point.priority) {
        case BreakPriority.space:
          score = 100;
        case BreakPriority.hyphen:
          score = 80;
        case BreakPriority.zeroWidthSpace:
          score = 120;
        case BreakPriority.normal:
          score = 60;
        case BreakPriority.mandatory:
          score = 200;
        case BreakPriority.forbidden:
          continue;
      }

      final distance = currentPosition - point.position;
      score -= distance * 0.1;

      if (point.position > 0) {
        final prevChar = text[point.position - 1];
        if (_isConsecutiveHyphen(text, point.position, runs)) {
          score -= 50;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        best = point;
      }
    }

    return best;
  }

  bool _isConsecutiveHyphen(String text, int position, List<FormatRange> runs) {
    int hyphenCount = 0;
    for (int i = position - 1; i >= 0 && hyphenCount < _maxConsecutiveHyphens; i--) {
      if (text[i] == '-' || text[i] == '\u2010') {
        hyphenCount++;
      } else {
        break;
      }
    }
    return hyphenCount >= _maxConsecutiveHyphens;
  }

  List<LineLayout> _buildLines(
    String text,
    List<FormatRange> runs,
    List<_BreakPoint> breakPoints,
    double maxWidth,
    bool isRtl,
    double lineSpacing,
  ) {
    final lines = <LineLayout>[];

    for (int i = 0; i < breakPoints.length - 1; i++) {
      final start = breakPoints[i].position;
      final end = breakPoints[i + 1].position;
      if (start >= end) continue;

      final segment = text.substring(start, end);
      final attrs = _getAttributesAt(runs, start);

      double lineWidth;
      final isJustified = attrs.align == TextAlignHorizontal.justify &&
          i < breakPoints.length - 2;

      if (isJustified && TextLayoutEngine.isArabicScript(segment)) {
        lineWidth = _textEngine.kashidaJustify(segment, maxWidth, attrs);
      }

      final measurement =
          _textEngine.measureText(segment, attributes: attrs, maxWidth: maxWidth);

      final glyphs = <GlyphPosition>[];
      double xOffset = isRtl ? maxWidth - measurement.width : 0;
      for (int g = 0; g < segment.length; g++) {
        final gChar = segment[g];
        final gWidth =
            _textEngine.measureTextWidth(gChar, attributes: attrs);
        glyphs.add(GlyphPosition(
          index: start + g,
          char: gChar,
          x: xOffset,
          y: 0,
          advance: gWidth,
        ));
        xOffset += gWidth;
      }

      final isLastLine = i >= breakPoints.length - 2;

      lines.add(LineLayout(
        startOffset: start,
        endOffset: end,
        width: measurement.width,
        height: measurement.height,
        baselineOffset: measurement.baselineOffset,
        lineSpacing: lineSpacing,
        glyphs: glyphs,
        attributes: attrs,
        isRtl: isRtl,
        isLastLineOfParagraph: isLastLine,
      ));
    }

    return lines;
  }

  List<LineLayout> _applyWidowOrphanControl(
    List<LineLayout> lines,
    double lineSpacing,
  ) {
    if (lines.length <= 2) return lines;

    final result = <LineLayout>[];
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (i == lines.length - 2 && lines.length > 2) {
        final isWidow = line.height <
            _getAverageLineHeight(lines) * _maxWidowRatio;
        if (isWidow && i > 0) {
          final merged = _mergeLines(lines[i - 1], line, lineSpacing);
          if (merged != null) {
            result.removeLast();
            result.add(merged);
            continue;
          }
        }
      }

      if (i == lines.length - 1 && lines.length > 2) {
        final orphanRatio = line.height / _getAverageLineHeight(lines);
        final isOrphan = orphanRatio < _minOrphanRatio;

        if (isOrphan && result.isNotEmpty) {
          final previous = result.removeLast();
          final merged = _mergeLines(previous, line, lineSpacing);
          if (merged != null) {
            result.add(merged);
            continue;
          }
          result.add(previous);
        }
      }

      result.add(line);
    }

    return result;
  }

  double _getAverageLineHeight(List<LineLayout> lines) {
    if (lines.isEmpty) return 0.0;
    return lines.fold(0.0, (sum, l) => sum + l.height) / lines.length;
  }

  LineLayout? _mergeLines(LineLayout a, LineLayout b, double lineSpacing) {
    final text = '(${a.startOffset}-${a.endOffset})(${b.startOffset}-${b.endOffset})';
    final attrs = a.attributes;

    return LineLayout(
      startOffset: a.startOffset,
      endOffset: b.endOffset,
      width: max(a.width, b.width),
      height: a.height + lineSpacing + b.height,
      baselineOffset: a.baselineOffset,
      lineSpacing: lineSpacing,
      attributes: attrs,
      isRtl: a.isRtl,
      isLastLineOfParagraph: b.isLastLineOfParagraph,
    );
  }

  TextAttributes _getAttributesAt(List<FormatRange> runs, int index) {
    for (final run in runs) {
      if (index >= run.offset && index < run.offset + run.length) {
        return run.attributes;
      }
    }
    return const TextAttributes();
  }
}
