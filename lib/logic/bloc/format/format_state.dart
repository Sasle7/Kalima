import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:kalima/logic/bloc/format/format_event.dart';

class FormatState extends Equatable {
  final String fontFamily;
  final double fontSize;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrikethrough;
  final Color textColor;
  final Color? highlightColor;
  final TextAlignment alignment;
  final double lineSpacing;
  final double indentLeft;
  final double indentRight;
  final double indentFirstLine;
  final String? activeStyle;

  const FormatState({
    this.fontFamily = 'Cairo',
    this.fontSize = 14.0,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikethrough = false,
    this.textColor = Colors.black,
    this.highlightColor,
    this.alignment = TextAlignment.right,
    this.lineSpacing = 1.5,
    this.indentLeft = 0,
    this.indentRight = 0,
    this.indentFirstLine = 0,
    this.activeStyle,
  });

  FormatState copyWith({
    String? fontFamily,
    double? fontSize,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    bool? isStrikethrough,
    Color? textColor,
    Color? highlightColor,
    TextAlignment? alignment,
    double? lineSpacing,
    double? indentLeft,
    double? indentRight,
    double? indentFirstLine,
    String? activeStyle,
    bool clearHighlight = false,
    bool clearStyle = false,
  }) {
    return FormatState(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      isStrikethrough: isStrikethrough ?? this.isStrikethrough,
      textColor: textColor ?? this.textColor,
      highlightColor: clearHighlight ? null : (highlightColor ?? this.highlightColor),
      alignment: alignment ?? this.alignment,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      indentLeft: indentLeft ?? this.indentLeft,
      indentRight: indentRight ?? this.indentRight,
      indentFirstLine: indentFirstLine ?? this.indentFirstLine,
      activeStyle: clearStyle ? null : (activeStyle ?? this.activeStyle),
    );
  }

  Map<String, dynamic> get attributes => {
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'bold': isBold,
        'italic': isItalic,
        'underline': isUnderline,
        'strikethrough': isStrikethrough,
        'color': textColor.value,
        if (highlightColor != null) 'highlight': highlightColor!.value,
        'alignment': alignment.name,
        'lineSpacing': lineSpacing,
        'indentLeft': indentLeft,
        'indentRight': indentRight,
        'indentFirstLine': indentFirstLine,
      };

  @override
  List<Object?> get props => [
        fontFamily,
        fontSize,
        isBold,
        isItalic,
        isUnderline,
        isStrikethrough,
        textColor,
        highlightColor,
        alignment,
        lineSpacing,
        indentLeft,
        indentRight,
        indentFirstLine,
        activeStyle,
      ];
}
