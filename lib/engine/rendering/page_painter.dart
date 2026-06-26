import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:kalima/engine/document/delta_format.dart';
import 'package:kalima/engine/layout/page_layout_engine.dart';
import 'package:kalima/engine/layout/text_layout_engine.dart';

class PagePainter {
  final TextLayoutEngine _textEngine;
  final double pageScale;

  PagePainter({
    required TextLayoutEngine textEngine,
    this.pageScale = 1.0,
  }) : _textEngine = textEngine;

  void paintPage(
    Canvas canvas,
    PageLayout page,
    Offset offset,
  ) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _drawPageBackground(canvas, page);
    _drawHeader(canvas, page);
    _drawContent(canvas, page);
    _drawFooter(canvas, page);
    _drawPageNumber(canvas, page);

    canvas.restore();
  }

  void _drawPageBackground(Canvas canvas, PageLayout page) {
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, page.size.width, page.size.height),
      bgPaint,
    );
  }

  void _drawHeader(Canvas canvas, PageLayout page) {
    if (!page.section.showHeader) return;

    final headerY = 0.0;
    final headerHeight = page.section.margins.top;

    for (final entry in page.headers.entries) {
      final header = entry.value;
      _renderDelta(
        canvas,
        header.content,
        Offset(header.position.x, headerY),
        maxWidth: page.contentWidth,
      );
    }
  }

  void _drawFooter(Canvas canvas, PageLayout page) {
    if (!page.section.showFooter) return;

    final footerY = page.size.height - page.section.margins.bottom;

    for (final entry in page.footers.entries) {
      final footer = entry.value;
      _renderDelta(
        canvas,
        footer.content,
        Offset(footer.position.x, footerY),
        maxWidth: page.contentWidth,
      );
    }
  }

  void _drawPageNumber(Canvas canvas, PageLayout page) {
    final textStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 10,
      color: Colors.grey[600],
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '${page.pageNumber}',
        style: textStyle,
      ),
      textDirection: TextDirection.rtl,
    )..layout();

    final x = page.size.width / 2 - tp.width / 2;
    final y = page.size.height - page.section.margins.bottom + 4;

    tp.paint(canvas, Offset(x, y));
  }

  void _drawContent(Canvas canvas, PageLayout page) {
    final contentOffset = page.contentOffset;

    for (final element in page.elements) {
      switch (element.type) {
        case ElementType.paragraph:
          _drawParagraph(canvas, element, contentOffset, page);
        case ElementType.table:
          _drawTable(canvas, element, contentOffset, page);
        case ElementType.image:
          _drawImage(canvas, element, contentOffset, page);
        case ElementType.shape:
          _drawShape(canvas, element, contentOffset, page);
        case ElementType.sectionBreak:
          break;
      }
    }
  }

  void _drawParagraph(
    Canvas canvas,
    ElementLayout element,
    LayoutPosition contentOffset,
    PageLayout page,
  ) {
    double currentY = element.position.y;

    for (final line in element.lines) {
      final lineX = contentOffset.x;

      _drawLine(canvas, line, Offset(lineX, currentY), element, page);

      currentY += line.height + line.lineSpacing;
    }
  }

  void _drawLine(
    Canvas canvas,
    LineLayout line,
    Offset lineOffset,
    ElementLayout element,
    PageLayout page,
  ) {
    final style = _buildTextStyle(line.attributes);
    final text = _getLineText(line);

    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: line.isRtl ? TextDirection.rtl : TextDirection.ltr,
      textAlign: _toFlutterTextAlign(line.attributes.align),
    )..layout(maxWidth: page.contentWidth);

    double x = lineOffset.dx;
    if (line.isRtl) {
      x = lineOffset.dx + page.contentWidth - line.width;
    }

    switch (line.attributes.align) {
      case TextAlignHorizontal.left:
        x = lineOffset.dx;
      case TextAlignHorizontal.center:
        x = lineOffset.dx + (page.contentWidth - line.width) / 2;
      case TextAlignHorizontal.right:
        x = lineOffset.dx + page.contentWidth - line.width;
      case TextAlignHorizontal.justify:
        x = lineOffset.dx;
        if (line.isRtl) {
          x = lineOffset.dx;
        }
      case null:
        x = line.isRtl
            ? lineOffset.dx + page.contentWidth - line.width
            : lineOffset.dx;
    }

    tp.paint(canvas, Offset(x, lineOffset.dy));
  }

  void _drawTable(
    Canvas canvas,
    ElementLayout element,
    LayoutPosition contentOffset,
    PageLayout page,
  ) {
    final tablePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawRect(
      Rect.fromLTWH(
        contentOffset.x + element.position.x,
        element.position.y,
        element.size.width,
        element.size.height,
      ),
      tablePaint,
    );

    final placeholderStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 12,
      color: Colors.grey[500],
    );

    final tp = TextPainter(
      text: const TextSpan(
        text: '[Table]',
        style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
      ),
      textDirection: TextDirection.rtl,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        contentOffset.x + element.position.x + 4,
        element.position.y + 4,
      ),
    );
  }

  void _drawImage(
    Canvas canvas,
    ElementLayout element,
    LayoutPosition contentOffset,
    PageLayout page,
  ) {
    final imgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        contentOffset.x + element.position.x,
        element.position.y,
        element.size.width,
        element.size.height,
      ),
      imgPaint,
    );

    final borderPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawRect(
      Rect.fromLTWH(
        contentOffset.x + element.position.x,
        element.position.y,
        element.size.width,
        element.size.height,
      ),
      borderPaint,
    );

    final tp = TextPainter(
      text: const TextSpan(
        text: '[Image]',
        style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
      ),
      textDirection: TextDirection.rtl,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        contentOffset.x + element.position.x + element.size.width / 2 -
            tp.width / 2,
        element.position.y + element.size.height / 2 - tp.height / 2,
      ),
    );
  }

  void _drawShape(
    Canvas canvas,
    ElementLayout element,
    LayoutPosition contentOffset,
    PageLayout page,
  ) {
    final shapePaint = Paint()
      ..color = Colors.amber[100]!
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      contentOffset.x + element.position.x,
      element.position.y,
      element.size.width,
      element.size.height,
    );

    canvas.drawRect(rect, shapePaint);

    final borderPaint = Paint()
      ..color = Colors.amber[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(rect, borderPaint);
  }

  void _renderDelta(
    Canvas canvas,
    Delta delta,
    Offset offset, {
    double maxWidth = double.infinity,
  }) {
    double currentX = offset.dx;
    final text = delta.plainText ?? '';
    if (text.isEmpty) return;

    final runs = delta.toFormatRanges();
    for (final run in runs) {
      final segment = text.substring(
        run.offset,
        min(run.offset + run.length, text.length),
      );
      if (segment.isEmpty) continue;

      final style = _buildTextStyle(run.attributes);
      final tp = TextPainter(
        text: TextSpan(text: segment, style: style),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: maxWidth);

      tp.paint(canvas, Offset(currentX, offset.dy));
      currentX += tp.width;
    }
  }

  String _getLineText(LineLayout line) {
    return '';
  }

  TextStyle _buildTextStyle(TextAttributes attrs) {
    return TextStyle(
      fontWeight: attrs.bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: attrs.italic ? FontStyle.italic : FontStyle.normal,
      decoration: _buildTextDecoration(attrs),
      fontFamily: attrs.fontFamily ?? 'Cairo',
      fontSize: attrs.fontSize ?? 14.0,
      color: attrs.color != null ? Color(attrs.color!) : Colors.black,
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
