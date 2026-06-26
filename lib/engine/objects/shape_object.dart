import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' hide Shape;
import 'package:uuid/uuid.dart';

import 'package:kalima/engine/document/delta_format.dart';

const _uuid = Uuid();

enum ShapeType { rectangle, ellipse, circle, line, arrow, diamond, triangle, star, textBox, freeform }

enum ShapeFillType { solid, gradient, pattern, none }

class ShapeGradient extends Equatable {
  final int colorStart;
  final int colorEnd;
  final double angle;

  const ShapeGradient({
    this.colorStart = 0xFF4A90D9,
    this.colorEnd = 0xFF357ABD,
    this.angle = 0.0,
  });

  ShapeGradient copyWith({int? colorStart, int? colorEnd, double? angle}) {
    return ShapeGradient(
      colorStart: colorStart ?? this.colorStart,
      colorEnd: colorEnd ?? this.colorEnd,
      angle: angle ?? this.angle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colorStart': colorStart,
      'colorEnd': colorEnd,
      'angle': angle,
    };
  }

  factory ShapeGradient.fromJson(Map<String, dynamic> json) {
    return ShapeGradient(
      colorStart: json['colorStart'] as int? ?? 0xFF4A90D9,
      colorEnd: json['colorEnd'] as int? ?? 0xFF357ABD,
      angle: (json['angle'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [colorStart, colorEnd, angle];
}

class ShapeShadow extends Equatable {
  final int color;
  final double blurRadius;
  final double offsetX;
  final double offsetY;

  const ShapeShadow({
    this.color = 0x40000000,
    this.blurRadius = 4.0,
    this.offsetX = 2.0,
    this.offsetY = 2.0,
  });

  ShapeShadow copyWith({
    int? color,
    double? blurRadius,
    double? offsetX,
    double? offsetY,
  }) {
    return ShapeShadow(
      color: color ?? this.color,
      blurRadius: blurRadius ?? this.blurRadius,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'blurRadius': blurRadius,
      'offsetX': offsetX,
      'offsetY': offsetY,
    };
  }

  factory ShapeShadow.fromJson(Map<String, dynamic> json) {
    return ShapeShadow(
      color: json['color'] as int? ?? 0x40000000,
      blurRadius: (json['blurRadius'] as num?)?.toDouble() ?? 4.0,
      offsetX: (json['offsetX'] as num?)?.toDouble() ?? 2.0,
      offsetY: (json['offsetY'] as num?)?.toDouble() ?? 2.0,
    );
  }

  @override
  List<Object?> get props => [color, blurRadius, offsetX, offsetY];
}

class ShapeObject extends Equatable {
  final String id;
  final ShapeType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final int fillColor;
  final ShapeFillType fillType;
  final ShapeGradient? gradient;
  final int borderColor;
  final double borderWidth;
  final BorderStyle borderStyle;
  final ShapeShadow? shadow;
  final int? textColor;
  final double? textSize;
  final String? textFontFamily;
  final TextAlignHorizontal? textAlign;
  final String? text;
  final bool hasRoundedCorners;
  final double cornerRadius;
  final double opacity;
  final bool isLocked;
  final List<Offset>? freeformPoints;

  const ShapeObject({
    String? id,
    this.type = ShapeType.rectangle,
    this.x = 0.0,
    this.y = 0.0,
    this.width = 100.0,
    this.height = 100.0,
    this.rotation = 0.0,
    this.fillColor = 0xFF4A90D9,
    this.fillType = ShapeFillType.solid,
    this.gradient,
    this.borderColor = 0xFF000000,
    this.borderWidth = 1.0,
    this.borderStyle = BorderStyle.solid,
    this.shadow,
    this.textColor,
    this.textSize,
    this.textFontFamily,
    this.textAlign,
    this.text,
    this.hasRoundedCorners = false,
    this.cornerRadius = 4.0,
    this.opacity = 1.0,
    this.isLocked = false,
    this.freeformPoints,
  }) : id = id ?? _uuid.v4();

  double get centerX => x + width / 2;
  double get centerY => y + height / 2;

  Rect get rect => Rect.fromLTWH(x, y, width, height);

  bool containsPoint(Offset point) {
    final localPoint = _rotatePoint(
      point,
      Offset(centerX, centerY),
      -rotation,
    );
    return rect.contains(localPoint);
  }

  Offset _rotatePoint(Offset point, Offset center, double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return Offset(
      center.dx + dx * cos - dy * sin,
      center.dy + dx * sin + dy * cos,
    );
  }

  Path getPath() {
    final path = Path();
    switch (type) {
      case ShapeType.rectangle:
        if (hasRoundedCorners) {
          path.addRRect(RRect.fromRectAndRadius(
            rect,
            Radius.circular(cornerRadius),
          ));
        } else {
          path.addRect(rect);
        }
      case ShapeType.ellipse:
        path.addOval(rect);
      case ShapeType.circle:
        final r = min(width, height) / 2;
        final cx = x + width / 2;
        final cy = y + height / 2;
        path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      case ShapeType.line:
        path.moveTo(x, y);
        path.lineTo(x + width, y + height);
      case ShapeType.arrow:
        path.moveTo(x, y);
        path.lineTo(x + width, y + height);
        _addArrowHead(path, Offset(x + width, y + height), Offset(x, y));
      case ShapeType.diamond:
        path.moveTo(x + width / 2, y);
        path.lineTo(x + width, y + height / 2);
        path.lineTo(x + width / 2, y + height);
        path.lineTo(x, y + height / 2);
        path.close();
      case ShapeType.triangle:
        path.moveTo(x + width / 2, y);
        path.lineTo(x + width, y + height);
        path.lineTo(x, y + height);
        path.close();
      case ShapeType.star:
        _addStarPath(path);
      case ShapeType.textBox:
        if (hasRoundedCorners) {
          path.addRRect(RRect.fromRectAndRadius(
            rect,
            Radius.circular(cornerRadius),
          ));
        } else {
          path.addRect(rect);
        }
      case ShapeType.freeform:
        if (freeformPoints != null && freeformPoints!.length >= 2) {
          path.moveTo(freeformPoints![0].dx, freeformPoints![0].dy);
          for (int i = 1; i < freeformPoints!.length; i++) {
            path.lineTo(freeformPoints![i].dx, freeformPoints![i].dy);
          }
        }
    }
    return path;
  }

  void _addArrowHead(Path path, Offset tip, Offset from) {
    final angle = math.atan2(tip.dy - from.dy, tip.dx - from.dx);
    const arrowLength = 12.0;
    const arrowAngle = math.pi / 6;

    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - arrowLength * math.cos(angle - arrowAngle),
      tip.dy - arrowLength * math.sin(angle - arrowAngle),
    );
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - arrowLength * math.cos(angle + arrowAngle),
      tip.dy - arrowLength * math.sin(angle + arrowAngle),
    );
  }

  void _addStarPath(Path path) {
    const points = 5;
    final outerRadius = min(width, height) / 2;
    final innerRadius = outerRadius * 0.382;
    final cx = x + width / 2;
    final cy = y + height / 2;
    final startAngle = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = startAngle + (math.pi * i) / points;
      final px = cx + radius * math.cos(angle);
      final py = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
  }

  ShapeObject copyWith({
    String? id,
    ShapeType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    int? fillColor,
    ShapeFillType? fillType,
    ShapeGradient? gradient,
    int? borderColor,
    double? borderWidth,
    BorderStyle? borderStyle,
    ShapeShadow? shadow,
    int? textColor,
    double? textSize,
    String? textFontFamily,
    TextAlignHorizontal? textAlign,
    String? text,
    bool? hasRoundedCorners,
    double? cornerRadius,
    double? opacity,
    bool? isLocked,
    List<Offset>? freeformPoints,
  }) {
    return ShapeObject(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      fillColor: fillColor ?? this.fillColor,
      fillType: fillType ?? this.fillType,
      gradient: gradient ?? this.gradient,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderStyle: borderStyle ?? this.borderStyle,
      shadow: shadow ?? this.shadow,
      textColor: textColor ?? this.textColor,
      textSize: textSize ?? this.textSize,
      textFontFamily: textFontFamily ?? this.textFontFamily,
      textAlign: textAlign ?? this.textAlign,
      text: text ?? this.text,
      hasRoundedCorners: hasRoundedCorners ?? this.hasRoundedCorners,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      opacity: opacity ?? this.opacity,
      isLocked: isLocked ?? this.isLocked,
      freeformPoints: freeformPoints ?? this.freeformPoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'fillColor': fillColor,
      'fillType': fillType.name,
      'gradient': gradient?.toJson(),
      'borderColor': borderColor,
      'borderWidth': borderWidth,
      'borderStyle': borderStyle.name,
      'shadow': shadow?.toJson(),
      'textColor': textColor,
      'textSize': textSize,
      'textFontFamily': textFontFamily,
      'textAlign': textAlign?.name,
      'text': text,
      'hasRoundedCorners': hasRoundedCorners,
      'cornerRadius': cornerRadius,
      'opacity': opacity,
      'isLocked': isLocked,
      'freeformPoints': freeformPoints
          ?.map((p) => {'x': p.dx, 'y': p.dy})
          .toList(),
    };
  }

  factory ShapeObject.fromJson(Map<String, dynamic> json) {
    return ShapeObject(
      id: json['id'] as String?,
      type: json['type'] != null
          ? ShapeType.values.byName(json['type'] as String)
          : ShapeType.rectangle,
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 100.0,
      height: (json['height'] as num?)?.toDouble() ?? 100.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      fillColor: json['fillColor'] as int? ?? 0xFF4A90D9,
      fillType: json['fillType'] != null
          ? ShapeFillType.values.byName(json['fillType'] as String)
          : ShapeFillType.solid,
      gradient: json['gradient'] != null
          ? ShapeGradient.fromJson(
              json['gradient'] as Map<String, dynamic>)
          : null,
      borderColor: json['borderColor'] as int? ?? 0xFF000000,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.0,
      borderStyle: json['borderStyle'] != null
          ? BorderStyle.values.byName(json['borderStyle'] as String)
          : BorderStyle.solid,
      shadow: json['shadow'] != null
          ? ShapeShadow.fromJson(json['shadow'] as Map<String, dynamic>)
          : null,
      textColor: json['textColor'] as int?,
      textSize: (json['textSize'] as num?)?.toDouble(),
      textFontFamily: json['textFontFamily'] as String?,
      textAlign: json['textAlign'] != null
          ? TextAlignHorizontal.values
              .byName(json['textAlign'] as String)
          : null,
      text: json['text'] as String?,
      hasRoundedCorners: json['hasRoundedCorners'] as bool? ?? false,
      cornerRadius: (json['cornerRadius'] as num?)?.toDouble() ?? 4.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      isLocked: json['isLocked'] as bool? ?? false,
      freeformPoints: (json['freeformPoints'] as List<dynamic>?)
          ?.map((p) => Offset(
                (p['x'] as num).toDouble(),
                (p['y'] as num).toDouble(),
              ))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        x,
        y,
        width,
        height,
        rotation,
        fillColor,
        fillType,
        gradient,
        borderColor,
        borderWidth,
        borderStyle,
        shadow,
        textColor,
        textSize,
        textFontFamily,
        textAlign,
        text,
        hasRoundedCorners,
        cornerRadius,
        opacity,
        isLocked,
        freeformPoints,
      ];
}
