import 'package:isar/isar.dart';

import '../../engine/document/document_model.dart' as engine;

@embedded
class ParagraphData {
  String alignment;

  double indentLeft;
  double indentRight;
  double indentFirstLine;
  double lineSpacing;
  double spaceBefore;
  double spaceAfter;

  String listType;
  int listLevel;

  ParagraphData({
    this.alignment = 'left',
    this.indentLeft = 0.0,
    this.indentRight = 0.0,
    this.indentFirstLine = 0.0,
    this.lineSpacing = 1.5,
    this.spaceBefore = 0.0,
    this.spaceAfter = 8.0,
    this.listType = 'none',
    this.listLevel = 0,
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

  engine.ListType get listTypeEnum {
    switch (listType) {
      case 'bullet':
        return engine.ListType.bullet;
      case 'numbered':
        return engine.ListType.numbered;
      case 'checkbox':
        return engine.ListType.checkbox;
      default:
        return engine.ListType.none;
    }
  }

  engine.BlockFormat toBlockFormat({bool isRtl = false}) {
    return engine.BlockFormat(
      alignment: textAlignment,
      indentLeft: indentLeft,
      indentRight: indentRight,
      indentFirstLine: indentFirstLine,
      lineSpacing: lineSpacing,
      spaceBefore: spaceBefore,
      spaceAfter: spaceAfter,
      listType: listTypeEnum,
      listLevel: listLevel,
      isRtl: isRtl,
    );
  }

  static ParagraphData fromBlockFormat(engine.BlockFormat format) {
    String alignStr;
    switch (format.alignment) {
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

    String listTypeStr;
    switch (format.listType) {
      case engine.ListType.bullet:
        listTypeStr = 'bullet';
        break;
      case engine.ListType.numbered:
        listTypeStr = 'numbered';
        break;
      case engine.ListType.checkbox:
        listTypeStr = 'checkbox';
        break;
      default:
        listTypeStr = 'none';
    }

    return ParagraphData(
      alignment: alignStr,
      indentLeft: format.indentLeft,
      indentRight: format.indentRight,
      indentFirstLine: format.indentFirstLine,
      lineSpacing: format.lineSpacing,
      spaceBefore: format.spaceBefore,
      spaceAfter: format.spaceAfter,
      listType: listTypeStr,
      listLevel: format.listLevel,
    );
  }

  static final standard = ParagraphData();

  static final heading = ParagraphData(
    alignment: 'right',
    lineSpacing: 1.3,
    spaceBefore: 12.0,
    spaceAfter: 6.0,
  );

  static final quote = ParagraphData(
    alignment: 'right',
    indentLeft: 20.0,
    indentRight: 20.0,
    lineSpacing: 1.5,
    spaceBefore: 16.0,
    spaceAfter: 16.0,
  );

  static final listItem = ParagraphData(
    lineSpacing: 1.5,
    indentLeft: 24.0,
    indentFirstLine: -24.0,
  );
}
