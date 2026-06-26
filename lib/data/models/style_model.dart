import 'package:isar/isar.dart';

import '../../engine/document/document_model.dart' as engine;

@embedded
class StyleData {
  String name;
  String? basedOn;
  String? fontFamily;
  double? fontSize;
  bool isBold;
  bool isItalic;
  bool isUnderline;
  int? textColorValue;
  int? highlightColorValue;
  String alignment;
  double lineSpacing;

  StyleData({
    this.name = 'Normal',
    this.basedOn,
    this.fontFamily,
    this.fontSize,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.textColorValue,
    this.highlightColorValue,
    this.alignment = 'left',
    this.lineSpacing = 1.5,
  });

  engine.TextAlignment get textAlignment {
    switch (alignment) {
      case 'right':
        return engine.TextAlignment.right;
      case 'center':
        return engine.TextAlignment.center;
      case 'justify':
        return engine.TextAlignment.justify;
      default:
        return engine.TextAlignment.left;
    }
  }

  engine.DocumentStyle toEngineStyle() {
    return engine.DocumentStyle(
      name: name,
      basedOn: basedOn,
      fontFamily: fontFamily,
      fontSize: fontSize,
      isBold: isBold,
      isItalic: isItalic,
      isUnderline: isUnderline,
      alignment: textAlignment,
      lineSpacing: lineSpacing,
    );
  }

  static StyleData fromEngineStyle(engine.DocumentStyle style) {
    String alignStr;
    switch (style.alignment) {
      case engine.TextAlignment.right:
        alignStr = 'right';
        break;
      case engine.TextAlignment.center:
        alignStr = 'center';
        break;
      case engine.TextAlignment.justify:
        alignStr = 'justify';
        break;
      default:
        alignStr = 'left';
    }

    return StyleData(
      name: style.name,
      basedOn: style.basedOn,
      fontFamily: style.fontFamily,
      fontSize: style.fontSize,
      isBold: style.isBold,
      isItalic: style.isItalic,
      isUnderline: style.isUnderline,
      alignment: alignStr,
      lineSpacing: style.lineSpacing,
    );
  }

  static final heading1 = StyleData(
    name: 'Heading 1',
    fontSize: 24,
    isBold: true,
    alignment: 'right',
    lineSpacing: 1.3,
  );

  static final heading2 = StyleData(
    name: 'Heading 2',
    fontSize: 20,
    isBold: true,
    alignment: 'right',
    lineSpacing: 1.3,
  );

  static final heading3 = StyleData(
    name: 'Heading 3',
    fontSize: 16,
    isBold: true,
    alignment: 'right',
    lineSpacing: 1.3,
  );

  static final body = StyleData(
    name: 'Normal',
    fontSize: 12,
    alignment: 'right',
    lineSpacing: 1.5,
  );

  static final quote = StyleData(
    name: 'Quote',
    fontSize: 14,
    isItalic: true,
    alignment: 'right',
    lineSpacing: 1.5,
  );
}
