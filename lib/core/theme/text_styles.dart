import 'package:flutter/material.dart';

class DocumentTextStyle {
  final String id;
  final String name;
  final String? arabicName;
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double lineHeight;
  final Color? color;
  final TextAlign? textAlign;
  final double? paragraphSpacing;
  final double? firstLineIndent;

  const DocumentTextStyle({
    required this.id,
    required this.name,
    this.arabicName,
    required this.fontSize,
    required this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    required this.lineHeight,
    this.color,
    this.textAlign,
    this.paragraphSpacing,
    this.firstLineIndent,
  });

  TextStyle toTextStyle({String? fontFamily}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: lineHeight,
      color: color,
      textBaseline: TextBaseline.alphabetic,
      fontFamily: fontFamily,
    );
  }

  DocumentTextStyle copyWith({
    String? id,
    String? name,
    String? arabicName,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? lineHeight,
    Color? color,
    TextAlign? textAlign,
    double? paragraphSpacing,
    double? firstLineIndent,
  }) {
    return DocumentTextStyle(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicName: arabicName ?? this.arabicName,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      color: color ?? this.color,
      textAlign: textAlign ?? this.textAlign,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      firstLineIndent: firstLineIndent ?? this.firstLineIndent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabicName': arabicName,
      'fontSize': fontSize,
      'fontWeight': fontWeight.index,
      'fontStyle': fontStyle?.index,
      'letterSpacing': letterSpacing,
      'lineHeight': lineHeight,
      'color': color?.value,
      'textAlign': textAlign?.index,
      'paragraphSpacing': paragraphSpacing,
      'firstLineIndent': firstLineIndent,
    };
  }

  factory DocumentTextStyle.fromJson(Map<String, dynamic> json) {
    return DocumentTextStyle(
      id: json['id'] as String,
      name: json['name'] as String,
      arabicName: json['arabicName'] as String?,
      fontSize: (json['fontSize'] as num).toDouble(),
      fontWeight: FontWeight.values[json['fontWeight'] as int],
      fontStyle: json['fontStyle'] != null
          ? FontStyle.values[json['fontStyle'] as int]
          : null,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble(),
      lineHeight: (json['lineHeight'] as num).toDouble(),
      color: json['color'] != null ? Color(json['color'] as int) : null,
      textAlign: json['textAlign'] != null
          ? TextAlign.values[json['textAlign'] as int]
          : null,
      paragraphSpacing: (json['paragraphSpacing'] as num?)?.toDouble(),
      firstLineIndent: (json['firstLineIndent'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentTextStyle &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DocumentTextStyle($id: $name)';
}

class TextStyles {
  TextStyles._();

  // Built-in style IDs
  static const String normalId = 'normal';
  static const String heading1Id = 'heading1';
  static const String heading2Id = 'heading2';
  static const String heading3Id = 'heading3';
  static const String titleId = 'title';
  static const String subtitleId = 'subtitle';
  static const String quoteId = 'quote';
  static const String codeId = 'code';

  static const DocumentTextStyle normal = DocumentTextStyle(
    id: normalId,
    name: 'Normal',
    arabicName: 'عادي',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    lineHeight: 1.8,
    paragraphSpacing: 8,
  );

  static const DocumentTextStyle heading1 = DocumentTextStyle(
    id: heading1Id,
    name: 'Heading 1',
    arabicName: 'عنوان 1',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    lineHeight: 1.4,
    paragraphSpacing: 12,
  );

  static const DocumentTextStyle heading2 = DocumentTextStyle(
    id: heading2Id,
    name: 'Heading 2',
    arabicName: 'عنوان 2',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    lineHeight: 1.4,
    paragraphSpacing: 10,
  );

  static const DocumentTextStyle heading3 = DocumentTextStyle(
    id: heading3Id,
    name: 'Heading 3',
    arabicName: 'عنوان 3',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    lineHeight: 1.4,
    paragraphSpacing: 8,
  );

  static const DocumentTextStyle title = DocumentTextStyle(
    id: titleId,
    name: 'Title',
    arabicName: 'عنوان رئيسي',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    lineHeight: 1.3,
    paragraphSpacing: 16,
  );

  static const DocumentTextStyle subtitle = DocumentTextStyle(
    id: subtitleId,
    name: 'Subtitle',
    arabicName: 'عنوان فرعي',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    lineHeight: 1.4,
    paragraphSpacing: 8,
    color: Color(0xFF5F6368),
  );

  static const DocumentTextStyle quote = DocumentTextStyle(
    id: quoteId,
    name: 'Quote',
    arabicName: 'اقتباس',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
    lineHeight: 1.8,
    paragraphSpacing: 8,
    firstLineIndent: 24,
  );

  static const DocumentTextStyle code = DocumentTextStyle(
    id: codeId,
    name: 'Code',
    arabicName: 'كود',
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    lineHeight: 1.6,
    paragraphSpacing: 4,
  );

  static const Map<String, DocumentTextStyle> builtInStyles = {
    normalId: normal,
    heading1Id: heading1,
    heading2Id: heading2,
    heading3Id: heading3,
    titleId: title,
    subtitleId: subtitle,
    quoteId: quote,
    codeId: code,
  };

  static DocumentTextStyle? get(String id) => builtInStyles[id];

  static DocumentTextStyle getByIndex(int index) {
    const values = [
      normal,
      heading1,
      heading2,
      heading3,
      title,
      subtitle,
      quote,
      code,
    ];
    if (index < 0 || index >= values.length) return normal;
    return values[index];
  }

  static TextStyle merge({
    required DocumentTextStyle style,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    String? fontFamily,
  }) {
    return style.toTextStyle(fontFamily: fontFamily).copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
    );
  }
}
