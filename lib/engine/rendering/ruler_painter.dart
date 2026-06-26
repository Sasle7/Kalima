import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:kalima/engine/document/document_model.dart';

class RulerMeasurement {
  final double pixelsPerUnit;
  final String unitLabel;

  const RulerMeasurement({
    required this.pixelsPerUnit,
    required this.unitLabel,
  });
}

class TabStop extends Equatable {
  final double position;
  final TabStopType type;

  const TabStop({
    required this.position,
    this.type = TabStopType.left,
  });

  @override
  List<Object?> get props => [position, type];
}

enum TabStopType { left, right, center, decimal, bar }

class IndentMarker {
  final double firstLineIndent;
  final double leftIndent;
  final double rightIndent;

  const IndentMarker({
    this.firstLineIndent = 0.0,
    this.leftIndent = 0.0,
    this.rightIndent = 0.0,
  });
}

class RulerPainter extends CustomPainter {
  final Rect rulerRect;
  final DocumentSection section;
  final bool isHorizontal;
  final RulerMeasurement measurement;
  final List<TabStop> tabStops;
  final IndentMarker indentMarker;
  final double viewScale;
  final Color backgroundColor;
  final Color tickColor;
  final Color textColor;
  final Color indentColor;
  final Color tabStopColor;
  final Color dragHandleColor;
  final String? dragHandleId;

  static const double _rulerHeight = 28.0;
  static const double _rulerWidth = 28.0;
  static const double _majorTickHeight = 12.0;
  static const double _minorTickHeight = 6.0;
  static const double _microTickHeight = 3.0;

  RulerPainter({
    required this.rulerRect,
    required this.section,
    this.isHorizontal = true,
    this.measurement = const RulerMeasurement(
      pixelsPerUnit: 2.834645669,
      unitLabel: 'mm',
    ),
    this.tabStops = const [],
    this.indentMarker = const IndentMarker(),
    this.viewScale = 1.0,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.tickColor = const Color(0xFF999999),
    this.textColor = const Color(0xFF666666),
    this.indentColor = const Color(0xFF4A90D9),
    this.tabStopColor = const Color(0xFF666666),
    this.dragHandleColor = const Color(0xFF4A90D9),
    this.dragHandleId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawTicks(canvas, size);
    _drawLabels(canvas, size);
    _drawTabStops(canvas, size);
    _drawIndentMarkers(canvas, size);
    _drawDragHandles(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    if (isHorizontal) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, _rulerHeight), bgPaint);
      canvas.drawLine(
        Offset(0, _rulerHeight),
        Offset(size.width, _rulerHeight),
        Paint()
          ..color = const Color(0xFFCCCCCC)
          ..strokeWidth = 0.5,
      );
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, _rulerWidth, size.height), bgPaint);
      canvas.drawLine(
        Offset(_rulerWidth, 0),
        Offset(_rulerWidth, size.height),
        Paint()
          ..color = const Color(0xFFCCCCCC)
          ..strokeWidth = 0.5,
      );
    }

    final cornerPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _rulerWidth, _rulerHeight),
      cornerPaint,
    );
  }

  void _drawTicks(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = tickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final pixelsPerUnit = measurement.pixelsPerUnit * viewScale;

    if (isHorizontal) {
      final contentStart = section.margins.left * viewScale;
      final contentEnd = size.width - section.margins.right * viewScale;
      final totalUnits = (contentEnd - contentStart) / pixelsPerUnit;

      for (double unit = 0; unit <= totalUnits; unit += 0.5) {
        final x = contentStart + unit * pixelsPerUnit;
        if (x < 0 || x > size.width) continue;

        final isMajor = unit == unit.roundToDouble();
        final isHalf = (unit * 10) % 10 == 5;

        double tickHeight;
        if (isMajor) {
          tickHeight = _majorTickHeight;
        } else if (isHalf) {
          tickHeight = _minorTickHeight;
        } else {
          tickHeight = _microTickHeight;
        }

        canvas.drawLine(
          Offset(x, _rulerHeight),
          Offset(x, _rulerHeight - tickHeight),
          tickPaint,
        );
      }
    } else {
      final contentStart = section.margins.top * viewScale;
      final contentEnd = size.height - section.margins.bottom * viewScale;
      final totalUnits = (contentEnd - contentStart) / pixelsPerUnit;

      for (double unit = 0; unit <= totalUnits; unit += 0.5) {
        final y = contentStart + unit * pixelsPerUnit;
        if (y < 0 || y > size.height) continue;

        final isMajor = unit == unit.roundToDouble();
        final isHalf = (unit * 10) % 10 == 5;

        double tickHeight;
        if (isMajor) {
          tickHeight = _rulerWidth;
        } else if (isHalf) {
          tickHeight = _rulerWidth * 0.5;
        } else {
          tickHeight = _rulerWidth * 0.25;
        }

        canvas.drawLine(
          Offset(_rulerWidth, y),
          Offset(_rulerWidth - tickHeight, y),
          tickPaint,
        );
      }
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 9,
      color: textColor,
    );

    final pixelsPerUnit = measurement.pixelsPerUnit * viewScale;

    if (isHorizontal) {
      final contentStart = section.margins.left * viewScale;

      for (double unit = 0; unit <= (size.width / pixelsPerUnit); unit++) {
        final x = contentStart + unit * pixelsPerUnit;
        if (x < 0 || x > size.width - 12) continue;

        final label = '${unit.toInt()}';
        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(canvas, Offset(x + 2 - tp.width / 2, 2));
      }
    } else {
      final contentStart = section.margins.top * viewScale;

      for (double unit = 0; unit <= (size.height / pixelsPerUnit); unit++) {
        final y = contentStart + unit * pixelsPerUnit;
        if (y < 0 || y > size.height - 12) continue;

        final label = '${unit.toInt()}';
        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(canvas, Offset(4, y + 2));
      }
    }
  }

  void _drawTabStops(Canvas canvas, Size size) {
    final tabPaint = Paint()
      ..color = tabStopColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (!isHorizontal) return;

    for (final tab in tabStops) {
      final x = tab.position * viewScale;
      if (x < 0 || x > size.width) continue;

      switch (tab.type) {
        case TabStopType.left:
          canvas.drawLine(
            Offset(x, _rulerHeight - 10),
            Offset(x, _rulerHeight - 2),
            tabPaint,
          );
          canvas.drawLine(
            Offset(x - 3, _rulerHeight - 8),
            Offset(x, _rulerHeight - 10),
            tabPaint,
          );
        case TabStopType.right:
          canvas.drawLine(
            Offset(x, _rulerHeight - 10),
            Offset(x, _rulerHeight - 2),
            tabPaint,
          );
          canvas.drawLine(
            Offset(x, _rulerHeight - 10),
            Offset(x + 3, _rulerHeight - 8),
            tabPaint,
          );
        case TabStopType.center:
          canvas.drawLine(
            Offset(x, _rulerHeight - 10),
            Offset(x, _rulerHeight - 2),
            tabPaint,
          );
          canvas.drawLine(
            Offset(x - 3, _rulerHeight - 8),
            Offset(x, _rulerHeight - 10),
            tabPaint,
          );
          canvas.drawLine(
            Offset(x, _rulerHeight - 10),
            Offset(x + 3, _rulerHeight - 8),
            tabPaint,
          );
        case TabStopType.decimal:
          canvas.drawLine(
            Offset(x, _rulerHeight - 10),
            Offset(x, _rulerHeight - 2),
            tabPaint,
          );
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, _rulerHeight - 6), width: 6, height: 6),
            tabPaint,
          );
        case TabStopType.bar:
          canvas.drawLine(
            Offset(x, 0),
            Offset(x, _rulerHeight),
            tabPaint,
          );
      }
    }
  }

  void _drawIndentMarkers(Canvas canvas, Size size) {
    if (!isHorizontal) return;

    final contentStart = section.margins.left * viewScale;

    final firstLineX = contentStart + indentMarker.firstLineIndent * viewScale;
    final leftIndentX = contentStart + indentMarker.leftIndent * viewScale;
    final rightIndentX =
        size.width - section.margins.right * viewScale -
            indentMarker.rightIndent * viewScale;

    _drawIndentHandle(canvas, firstLineX, _rulerHeight - 12, true);
    _drawIndentHandle(canvas, leftIndentX, _rulerHeight - 12, false);
    _drawRightIndentHandle(canvas, rightIndentX, _rulerHeight - 12);
  }

  void _drawIndentHandle(Canvas canvas, double x, double y, bool isFirstLine) {
    final paint = Paint()
      ..color = indentColor
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isFirstLine) {
      path.moveTo(x, y + 10);
      path.lineTo(x - 5, y + 4);
      path.lineTo(x - 5, y);
      path.lineTo(x + 5, y);
      path.lineTo(x + 5, y + 4);
      path.close();
    } else {
      path.moveTo(x, y + 10);
      path.lineTo(x - 5, y + 4);
      path.lineTo(x - 5, y);
      path.lineTo(x + 5, y);
      path.lineTo(x + 5, y + 4);
      path.close();
    }

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = indentColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawPath(path, borderPaint);
  }

  void _drawRightIndentHandle(Canvas canvas, double x, double y) {
    final paint = Paint()
      ..color = indentColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(x, y);
    path.lineTo(x - 5, y + 4);
    path.lineTo(x - 5, y + 10);
    path.lineTo(x + 5, y + 10);
    path.lineTo(x + 5, y + 4);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawDragHandles(Canvas canvas, Size size) {
    if (dragHandleId == null) return;

    final handlePaint = Paint()
      ..color = dragHandleColor
      ..style = PaintingStyle.fill;

    if (isHorizontal) {
      final contentStart = section.margins.left * viewScale;
      final contentEnd = size.width - section.margins.right * viewScale;

      if (dragHandleId == 'leftMargin') {
        canvas.drawRect(
          Rect.fromLTWH(contentStart - 2, 0, 4, _rulerHeight),
          handlePaint,
        );
      } else if (dragHandleId == 'rightMargin') {
        canvas.drawRect(
          Rect.fromLTWH(contentEnd - 2, 0, 4, _rulerHeight),
          handlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) {
    return oldDelegate.rulerRect != rulerRect ||
        oldDelegate.section != section ||
        oldDelegate.isHorizontal != isHorizontal ||
        oldDelegate.viewScale != viewScale ||
        oldDelegate.tabStops != tabStops ||
        oldDelegate.indentMarker != indentMarker ||
        oldDelegate.dragHandleId != dragHandleId;
  }

  double pixelToUnit(double pixels) {
    return pixels / (measurement.pixelsPerUnit * viewScale);
  }

  double unitToPixel(double units) {
    return units * measurement.pixelsPerUnit * viewScale;
  }

  HitTestResult hitTest(Offset position) {
    if (!isHorizontal) return HitTestResult.none;

    final contentStart = section.margins.left * viewScale;
    final contentEnd =
        rulerRect.width - section.margins.right * viewScale;

    if (position.dy < 0 || position.dy > _rulerHeight) {
      return HitTestResult.none;
    }

    for (final tab in tabStops) {
      final tabX = tab.position * viewScale;
      if ((position.dx - tabX).abs() < 6) {
        return HitTestResult.tabStop(tab);
      }
    }

    final firstLineX =
        contentStart + indentMarker.firstLineIndent * viewScale;
    if ((position.dx - firstLineX).abs() < 8) {
      return HitTestResult.firstLineIndent;
    }

    final leftIndentX =
        contentStart + indentMarker.leftIndent * viewScale;
    if ((position.dx - leftIndentX).abs() < 8) {
      return HitTestResult.leftIndent;
    }

    final rightIndentX =
        contentEnd - indentMarker.rightIndent * viewScale;
    if ((position.dx - rightIndentX).abs() < 8) {
      return HitTestResult.rightIndent;
    }

    if ((position.dx - contentStart).abs() < 6) {
      return HitTestResult.leftMargin;
    }
    if ((position.dx - contentEnd).abs() < 6) {
      return HitTestResult.rightMargin;
    }

    return HitTestResult.none;
  }
}

sealed class HitTestResult {
  const HitTestResult();
  const factory HitTestResult.none() = _NoneHitTest;
  const factory HitTestResult.tabStop(TabStop tabStop) = _TabStopHitTest;
  const factory HitTestResult.firstLineIndent() = _FirstLineIndentHitTest;
  const factory HitTestResult.leftIndent() = _LeftIndentHitTest;
  const factory HitTestResult.rightIndent() = _RightIndentHitTest;
  const factory HitTestResult.leftMargin() = _LeftMarginHitTest;
  const factory HitTestResult.rightMargin() = _RightMarginHitTest;
}

class _NoneHitTest extends HitTestResult {
  const _NoneHitTest();
}

class _TabStopHitTest extends HitTestResult {
  final TabStop tabStop;
  const _TabStopHitTest(this.tabStop);
}

class _FirstLineIndentHitTest extends HitTestResult {
  const _FirstLineIndentHitTest();
}

class _LeftIndentHitTest extends HitTestResult {
  const _LeftIndentHitTest();
}

class _RightIndentHitTest extends HitTestResult {
  const _RightIndentHitTest();
}

class _LeftMarginHitTest extends HitTestResult {
  const _LeftMarginHitTest();
}

class _RightMarginHitTest extends HitTestResult {
  const _RightMarginHitTest();
}
