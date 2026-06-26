import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:kalima/engine/layout/page_layout_engine.dart';

class CanvasPainter extends CustomPainter {
  final DocumentLayout layout;
  final int currentPageIndex;
  final Set<String> selectedElementIds;
  final TextSelection? selection;
  final CaretInfo? caret;
  final double pageScale;
  final bool showRuler;
  final bool showPageShadow;
  final Color pageColor;
  final Color shadowColor;
  final Color marginColor;
  final Color selectionColor;
  final Color caretColor;
  final Color borderColor;

  CanvasPainter({
    required this.layout,
    this.currentPageIndex = 0,
    this.selectedElementIds = const {},
    this.selection,
    this.caret,
    this.pageScale = 1.0,
    this.showRuler = true,
    this.showPageShadow = true,
    this.pageColor = Colors.white,
    this.shadowColor = Colors.black26,
    this.marginColor = Colors.grey,
    this.selectionColor = Colors.blue.withValues(alpha: 0.3),
    this.caretColor = Colors.black,
    this.borderColor = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (layout.pages.isEmpty) return;

    final page = layout.pages[currentPageIndex];

    canvas.save();
    canvas.scale(pageScale);

    final pageRect = Rect.fromLTWH(
      0,
      0,
      page.size.width,
      page.size.height,
    );

    _drawPageBackground(canvas, pageRect);
    _drawPageShadow(canvas, pageRect);
    _drawPageBorder(canvas, pageRect);
    _drawMargins(canvas, page);
    _drawContentArea(canvas, page);
    _drawSelection(canvas);
    _drawCaret(canvas);

    canvas.restore();
  }

  void _drawPageBackground(Canvas canvas, Rect rect) {
    final bgPaint = Paint()
      ..color = pageColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, bgPaint);
  }

  void _drawPageShadow(Canvas canvas, Rect rect) {
    if (!showPageShadow) return;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawRect(rect.translate(2, 2), shadowPaint);

    canvas.drawRect(rect, Paint()..color = pageColor);
  }

  void _drawPageBorder(Canvas canvas, Rect rect) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRect(rect, borderPaint);
  }

  void _drawMargins(Canvas canvas, PageLayout page) {
    final marginPaint = Paint()
      ..color = marginColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final marginRect = Rect.fromLTWH(
      page.section.margins.left,
      page.section.margins.top,
      page.contentWidth,
      page.contentHeight,
    );
    canvas.drawRect(marginRect, marginPaint);

    if (page.section.showHeader) {
      final headerRect = Rect.fromLTWH(
        page.section.margins.left,
        0,
        page.contentWidth,
        page.section.margins.top,
      );
      final headerPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill;
      canvas.drawRect(headerRect, headerPaint);
    }

    if (page.section.showFooter) {
      final footerRect = Rect.fromLTWH(
        page.section.margins.left,
        page.size.height - page.section.margins.bottom,
        page.contentWidth,
        page.section.margins.bottom,
      );
      final footerPaint = Paint()
        ..color = Colors.green.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill;
      canvas.drawRect(footerRect, footerPaint);
    }
  }

  void _drawContentArea(Canvas canvas, PageLayout page) {
    for (final element in page.elements) {
      _drawElementBorder(canvas, element, page);
      _drawElementBackground(canvas, element);
    }
  }

  void _drawElementBorder(Canvas canvas, ElementLayout element, PageLayout page) {
    final isSelected = selectedElementIds.contains(element.elementId);
    if (!isSelected) return;

    final borderPaint = Paint()
      ..color = selectionColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = Rect.fromLTWH(
      page.contentOffset.x + element.position.x + element.size.width,
      element.position.y,
      0,
      element.size.height,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        page.contentOffset.x + element.position.x,
        element.position.y,
        element.size.width,
        element.size.height,
      ),
      borderPaint,
    );
  }

  void _drawElementBackground(Canvas canvas, ElementLayout element) {
    final isSelected = selectedElementIds.contains(element.elementId);
    if (!isSelected) return;

    final fillPaint = Paint()
      ..color = selectionColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRect(element.rect, fillPaint);
  }

  void _drawSelection(Canvas canvas) {
    final sel = selection;
    if (sel == null || !sel.isValid || sel.isCollapsed) return;

    final page = layout.pages[currentPageIndex];
    final selPaint = Paint()
      ..color = selectionColor
      ..style = PaintingStyle.fill;

    for (final element in page.elements) {
      for (final line in element.lines) {
        for (final rect in _getSelectionRects(line, sel, element, page)) {
          canvas.drawRect(rect, selPaint);
        }
      }
    }
  }

  List<Rect> _getSelectionRects(
    LineLayout line,
    TextSelection sel,
    ElementLayout element,
    PageLayout page,
  ) {
    final rects = <Rect>[];
    final lineStart = line.startOffset;
    final lineEnd = line.endOffset;

    if (sel.start > lineEnd || sel.end < lineStart) return rects;

    final selStart = max(sel.start, lineStart);
    final selEnd = min(sel.end, lineEnd);

    final baseX = page.contentOffset.x + element.position.x;
    final lineY = element.position.y +
        line.height * element.lines.indexOf(line);

    double startX = baseX;
    double endX = baseX + line.width;

    for (final glyph in line.glyphs) {
      if (glyph.index == selStart) {
        startX = baseX + glyph.x;
      }
      if (glyph.index == selEnd) {
        endX = baseX + glyph.x;
      }
    }

    rects.add(Rect.fromLTRB(
      min(startX, endX),
      lineY,
      max(startX, endX),
      lineY + line.height,
    ));

    return rects;
  }

  void _drawCaret(Canvas canvas) {
    final c = caret;
    if (c == null) return;

    final linePaint = Paint()
      ..color = caretColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(c.position, c.position.translate(0, c.height), linePaint);
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate.layout != layout ||
        oldDelegate.currentPageIndex != currentPageIndex ||
        oldDelegate.selectedElementIds != selectedElementIds ||
        oldDelegate.selection != selection ||
        oldDelegate.caret != caret ||
        oldDelegate.pageScale != pageScale;
  }

  Offset getPageOffset(Offset screenPosition, Size canvasSize) {
    return Offset(
      screenPosition.dx / pageScale,
      screenPosition.dy / pageScale,
    );
  }
}

class CaretInfo {
  final Offset position;
  final double height;
  final bool isRtl;

  const CaretInfo({
    required this.position,
    required this.height,
    this.isRtl = false,
  });
}
