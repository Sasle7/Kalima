import 'dart:ui';

import 'package:kalima/engine/document/delta_format.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum BlockType {
  paragraph,
  heading1,
  heading2,
  heading3,
  heading4,
  heading5,
  heading6,
  image,
  table,
  quote,
  listItem,
  codeBlock,
  pageBreak,
}

enum TextAlignment {
  left,
  right,
  center,
  justify,
}

enum ListType {
  none,
  bullet,
  numbered,
  checkbox,
}

class TextFormat {
  final String? fontFamily;
  final double? fontSize;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrikethrough;
  final Color? textColor;
  final Color? highlightColor;
  final String? hyperlink;
  final String? language;

  const TextFormat({
    this.fontFamily,
    this.fontSize,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikethrough = false,
    this.textColor,
    this.highlightColor,
    this.hyperlink,
    this.language,
  });

  TextFormat copyWith({
    String? fontFamily,
    double? fontSize,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    bool? isStrikethrough,
    Color? textColor,
    Color? highlightColor,
    String? hyperlink,
    String? language,
  }) {
    return TextFormat(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      isStrikethrough: isStrikethrough ?? this.isStrikethrough,
      textColor: textColor ?? this.textColor,
      highlightColor: highlightColor ?? this.highlightColor,
      hyperlink: hyperlink ?? this.hyperlink,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontSize != null) 'fontSize': fontSize,
      'isBold': isBold,
      'isItalic': isItalic,
      'isUnderline': isUnderline,
      'isStrikethrough': isStrikethrough,
      if (textColor != null) 'textColor': textColor!.value,
      if (highlightColor != null) 'highlightColor': highlightColor!.value,
      if (hyperlink != null) 'hyperlink': hyperlink,
      if (language != null) 'language': language,
    };
  }

  factory TextFormat.fromJson(Map<String, dynamic> json) {
    return TextFormat(
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
      isUnderline: json['isUnderline'] as bool? ?? false,
      isStrikethrough: json['isStrikethrough'] as bool? ?? false,
      textColor: json['textColor'] != null
          ? Color(json['textColor'] as int)
          : null,
      highlightColor: json['highlightColor'] != null
          ? Color(json['highlightColor'] as int)
          : null,
      hyperlink: json['hyperlink'] as String?,
      language: json['language'] as String?,
    );
  }

  static const empty = TextFormat();
}

class BlockFormat {
  final TextAlignment alignment;
  final double indentLeft;
  final double indentRight;
  final double indentFirstLine;
  final double lineSpacing;
  final double spaceBefore;
  final double spaceAfter;
  final ListType listType;
  final int listLevel;
  final bool isRtl;

  const BlockFormat({
    this.alignment = TextAlignment.left,
    this.indentLeft = 0.0,
    this.indentRight = 0.0,
    this.indentFirstLine = 0.0,
    this.lineSpacing = 1.5,
    this.spaceBefore = 0.0,
    this.spaceAfter = 8.0,
    this.listType = ListType.none,
    this.listLevel = 0,
    this.isRtl = false,
  });

  BlockFormat copyWith({
    TextAlignment? alignment,
    double? indentLeft,
    double? indentRight,
    double? indentFirstLine,
    double? lineSpacing,
    double? spaceBefore,
    double? spaceAfter,
    ListType? listType,
    int? listLevel,
    bool? isRtl,
  }) {
    return BlockFormat(
      alignment: alignment ?? this.alignment,
      indentLeft: indentLeft ?? this.indentLeft,
      indentRight: indentRight ?? this.indentRight,
      indentFirstLine: indentFirstLine ?? this.indentFirstLine,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      spaceBefore: spaceBefore ?? this.spaceBefore,
      spaceAfter: spaceAfter ?? this.spaceAfter,
      listType: listType ?? this.listType,
      listLevel: listLevel ?? this.listLevel,
      isRtl: isRtl ?? this.isRtl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alignment': alignment.name,
      'indentLeft': indentLeft,
      'indentRight': indentRight,
      'indentFirstLine': indentFirstLine,
      'lineSpacing': lineSpacing,
      'spaceBefore': spaceBefore,
      'spaceAfter': spaceAfter,
      'listType': listType.name,
      'listLevel': listLevel,
      'isRtl': isRtl,
    };
  }

  factory BlockFormat.fromJson(Map<String, dynamic> json) {
    return BlockFormat(
      alignment: TextAlignment.values.firstWhere(
        (e) => e.name == json['alignment'],
        orElse: () => TextAlignment.left,
      ),
      indentLeft: (json['indentLeft'] as num?)?.toDouble() ?? 0.0,
      indentRight: (json['indentRight'] as num?)?.toDouble() ?? 0.0,
      indentFirstLine: (json['indentFirstLine'] as num?)?.toDouble() ?? 0.0,
      lineSpacing: (json['lineSpacing'] as num?)?.toDouble() ?? 1.5,
      spaceBefore: (json['spaceBefore'] as num?)?.toDouble() ?? 0.0,
      spaceAfter: (json['spaceAfter'] as num?)?.toDouble() ?? 8.0,
      listType: ListType.values.firstWhere(
        (e) => e.name == json['listType'],
        orElse: () => ListType.none,
      ),
      listLevel: json['listLevel'] as int? ?? 0,
      isRtl: json['isRtl'] as bool? ?? false,
    );
  }

  static const empty = BlockFormat();
}

class TextRun {
  final String text;
  final TextFormat format;

  const TextRun(this.text, {this.format = TextFormat.empty});

  TextRun copyWith({String? text, TextFormat? format}) {
    return TextRun(
      text ?? this.text,
      format: format ?? this.format,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'format': format.toJson(),
      };

  factory TextRun.fromJson(Map<String, dynamic> json) {
    return TextRun(
      json['text'] as String? ?? '',
      format: json['format'] != null
          ? TextFormat.fromJson(json['format'] as Map<String, dynamic>)
          : TextFormat.empty,
    );
  }
}

class TableCell {
  final List<DocumentBlock> blocks;
  final int rowSpan;
  final int colSpan;
  final bool isHeader;

  const TableCell({
    this.blocks = const [],
    this.rowSpan = 1,
    this.colSpan = 1,
    this.isHeader = false,
  });
}

class DocumentBlock {
  final String id;
  final BlockType type;
  final List<TextRun> textRuns;
  final BlockFormat format;
  final List<List<TableCell>>? tableCells;
  final String? imagePath;
  final double? imageWidth;
  final double? imageHeight;
  final String? imageAltText;

  const DocumentBlock({
    required this.id,
    required this.type,
    this.textRuns = const [],
    this.format = BlockFormat.empty,
    this.tableCells,
    this.imagePath,
    this.imageWidth,
    this.imageHeight,
    this.imageAltText,
  });

  DocumentBlock copyWith({
    String? id,
    BlockType? type,
    List<TextRun>? textRuns,
    BlockFormat? format,
    List<List<TableCell>>? tableCells,
    String? imagePath,
    double? imageWidth,
    double? imageHeight,
    String? imageAltText,
  }) {
    return DocumentBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      textRuns: textRuns ?? this.textRuns,
      format: format ?? this.format,
      tableCells: tableCells ?? this.tableCells,
      imagePath: imagePath ?? this.imagePath,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      imageAltText: imageAltText ?? this.imageAltText,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'textRuns': textRuns.map((e) => e.toJson()).toList(),
        'format': format.toJson(),
        if (imagePath != null) 'imagePath': imagePath,
        if (imageWidth != null) 'imageWidth': imageWidth,
        if (imageHeight != null) 'imageHeight': imageHeight,
      };

  factory DocumentBlock.fromJson(Map<String, dynamic> json) {
    return DocumentBlock(
      id: json['id'] as String,
      type: BlockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BlockType.paragraph,
      ),
      textRuns: (json['textRuns'] as List<dynamic>?)
              ?.map((e) =>
                  TextRun.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      format: json['format'] != null
          ? BlockFormat.fromJson(json['format'] as Map<String, dynamic>)
          : BlockFormat.empty,
      imagePath: json['imagePath'] as String?,
      imageWidth: (json['imageWidth'] as num?)?.toDouble(),
      imageHeight: (json['imageHeight'] as num?)?.toDouble(),
    );
  }
}

class DocumentStyle {
  final String name;
  final String? basedOn;
  final String? fontFamily;
  final double? fontSize;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final Color? textColor;
  final Color? highlightColor;
  final TextAlignment alignment;
  final double lineSpacing;
  final double spaceBefore;
  final double spaceAfter;

  const DocumentStyle({
    required this.name,
    this.basedOn,
    this.fontFamily,
    this.fontSize,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.textColor,
    this.highlightColor,
    this.alignment = TextAlignment.left,
    this.lineSpacing = 1.5,
    this.spaceBefore = 0.0,
    this.spaceAfter = 8.0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (basedOn != null) 'basedOn': basedOn,
        if (fontFamily != null) 'fontFamily': fontFamily,
        if (fontSize != null) 'fontSize': fontSize,
        'isBold': isBold,
        'isItalic': isItalic,
        'isUnderline': isUnderline,
        if (textColor != null) 'textColor': textColor!.value,
        if (highlightColor != null) 'highlightColor': highlightColor!.value,
        'alignment': alignment.name,
        'lineSpacing': lineSpacing,
        'spaceBefore': spaceBefore,
        'spaceAfter': spaceAfter,
      };

  factory DocumentStyle.fromJson(Map<String, dynamic> json) {
    return DocumentStyle(
      name: json['name'] as String,
      basedOn: json['basedOn'] as String?,
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
      isUnderline: json['isUnderline'] as bool? ?? false,
      textColor: json['textColor'] != null
          ? Color(json['textColor'] as int)
          : null,
      highlightColor: json['highlightColor'] != null
          ? Color(json['highlightColor'] as int)
          : null,
      alignment: TextAlignment.values.firstWhere(
        (e) => e.name == json['alignment'],
        orElse: () => TextAlignment.left,
      ),
      lineSpacing: (json['lineSpacing'] as num?)?.toDouble() ?? 1.5,
      spaceBefore: (json['spaceBefore'] as num?)?.toDouble() ?? 0.0,
      spaceAfter: (json['spaceAfter'] as num?)?.toDouble() ?? 8.0,
    );
  }

  static const heading1 = DocumentStyle(
    name: 'Heading 1',
    fontSize: 24,
    isBold: true,
    spaceBefore: 24,
    spaceAfter: 12,
  );

  static const heading2 = DocumentStyle(
    name: 'Heading 2',
    fontSize: 20,
    isBold: true,
    spaceBefore: 20,
    spaceAfter: 10,
  );

  static const heading3 = DocumentStyle(
    name: 'Heading 3',
    fontSize: 16,
    isBold: true,
    spaceBefore: 16,
    spaceAfter: 8,
  );

  static const body = DocumentStyle(
    name: 'Normal',
    fontSize: 12,
    lineSpacing: 1.5,
  );

  static const quote = DocumentStyle(
    name: 'Quote',
    fontSize: 14,
    isItalic: true,
    lineSpacing: 1.5,
    spaceBefore: 16,
    spaceAfter: 16,
  );
}

class DocumentMetadata {
  final String? author;
  final String? subject;
  final String? keywords;
  final String? category;
  final Map<String, dynamic> custom;

  const DocumentMetadata({
    this.author,
    this.subject,
    this.keywords,
    this.category,
    this.custom = const {},
  });

  Map<String, dynamic> toJson() => {
        if (author != null) 'author': author,
        if (subject != null) 'subject': subject,
        if (keywords != null) 'keywords': keywords,
        if (category != null) 'category': category,
        if (custom.isNotEmpty) 'custom': custom,
      };

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) {
    return DocumentMetadata(
      author: json['author'] as String?,
      subject: json['subject'] as String?,
      keywords: json['keywords'] as String?,
      category: json['category'] as String?,
      custom: (json['custom'] as Map<String, dynamic>?) ?? const {},
    );
  }

  static const empty = DocumentMetadata();
}

class DocumentModel {
  final String id;
  String title;
  final List<DocumentBlock> blocks;
  final DocumentMetadata metadata;
  final List<DocumentStyle> styles;
  final DateTime createdAt;
  DateTime modifiedAt;
  bool isRtl;

  DocumentModel({
    required this.id,
    required this.title,
    this.blocks = const [],
    this.metadata = DocumentMetadata.empty,
    this.styles = const [],
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.isRtl = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  int get blockCount => blocks.length;

  DocumentBlock? blockAt(int index) {
    if (index < 0 || index >= blocks.length) return null;
    return blocks[index];
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    List<DocumentBlock>? blocks,
    DocumentMetadata? metadata,
    List<DocumentStyle>? styles,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? isRtl,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      blocks: blocks ?? this.blocks,
      metadata: metadata ?? this.metadata,
      styles: styles ?? this.styles,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isRtl: isRtl ?? this.isRtl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'metadata': metadata.toJson(),
        'styles': styles.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'isRtl': isRtl,
      };

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map(
                  (e) => DocumentBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? DocumentMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : DocumentMetadata.empty,
      styles: (json['styles'] as List<dynamic>?)
              ?.map(
                  (e) => DocumentStyle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'] as String)
          : null,
      isRtl: json['isRtl'] as bool? ?? true,
    );
  }

  String toJsonString() => toJson().toString();

  factory DocumentModel.empty() {
    return DocumentModel(
      id: _uuid.v4(),
      title: '',
      blocks: [],
      metadata: DocumentMetadata.empty,
      styles: [],
      isRtl: true,
    );
  }

  String get text {
    return blocks
        .where((b) => b.type == BlockType.paragraph ||
            b.type == BlockType.heading1 ||
            b.type == BlockType.heading2 ||
            b.type == BlockType.heading3 ||
            b.type == BlockType.quote ||
            b.type == BlockType.listItem)
        .map((b) => b.textRuns.map((t) => t.text).join())
        .join('\n');
  }

  DocumentModel applyDelta(Delta delta) {
    final plainText = delta.plainText;
    if (plainText == null || plainText.isEmpty) return this;

    final newBlocks = List<DocumentBlock>.from(blocks);
    final lines = plainText.split('\n');
    for (final line in lines) {
      if (line.isNotEmpty) {
        newBlocks.add(DocumentBlock(
          id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
          type: BlockType.paragraph,
          textRuns: [TextRun(line)],
          format: BlockFormat(isRtl: isRtl),
        ));
      }
    }

    return DocumentModel(
      id: id,
      title: title,
      blocks: newBlocks,
      metadata: metadata,
      styles: styles,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
      isRtl: isRtl,
    );
  }
}

class PageMargins {
  final double left;
  final double right;
  final double top;
  final double bottom;

  const PageMargins({
    this.left = 72.0,
    this.right = 72.0,
    this.top = 72.0,
    this.bottom = 72.0,
  });

  Map<String, dynamic> toJson() => {
        'left': left,
        'right': right,
        'top': top,
        'bottom': bottom,
      };

  factory PageMargins.fromJson(Map<String, dynamic> json) {
    return PageMargins(
      left: (json['left'] as num?)?.toDouble() ?? 72.0,
      right: (json['right'] as num?)?.toDouble() ?? 72.0,
      top: (json['top'] as num?)?.toDouble() ?? 72.0,
      bottom: (json['bottom'] as num?)?.toDouble() ?? 72.0,
    );
  }

  static const defaultMargins = PageMargins();
}

enum PageOrientation {
  portrait,
  landscape,
}

class PageSize {
  final double width;
  final double height;

  const PageSize(this.width, this.height);

  factory PageSize.a4() => const PageSize(595.276, 841.890);
  factory PageSize.letter() => const PageSize(612.0, 792.0);

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
      };

  factory PageSize.fromJson(Map<String, dynamic> json) {
    return PageSize(
      (json['width'] as num?)?.toDouble() ?? 612.0,
      (json['height'] as num?)?.toDouble() ?? 792.0,
    );
  }

  static const a4Portrait = PageSize(595.276, 841.890);
  static const a4Landscape = PageSize(841.890, 595.276);
  static const letterPortrait = PageSize(612.0, 792.0);
  static const letterLandscape = PageSize(792.0, 612.0);
}

class DocumentSection {
  final PageSize pageSize;
  final PageOrientation orientation;
  final PageMargins margins;

  const DocumentSection({
    this.pageSize = PageSize.letterPortrait,
    this.orientation = PageOrientation.portrait,
    this.margins = PageMargins.defaultMargins,
  });

  double get pageWidth => pageSize.width;
  double get pageHeight => pageSize.height;

  Map<String, dynamic> toJson() => {
        'pageSize': pageSize.toJson(),
        'orientation': orientation.name,
        'margins': margins.toJson(),
      };

  factory DocumentSection.fromJson(Map<String, dynamic> json) {
    return DocumentSection(
      pageSize: json['pageSize'] != null
          ? PageSize.fromJson(json['pageSize'] as Map<String, dynamic>)
          : PageSize.letterPortrait,
      orientation: json['orientation'] != null
          ? PageOrientation.values.firstWhere(
              (e) => e.name == json['orientation'],
              orElse: () => PageOrientation.portrait,
            )
          : PageOrientation.portrait,
      margins: json['margins'] != null
          ? PageMargins.fromJson(json['margins'] as Map<String, dynamic>)
          : PageMargins.defaultMargins,
    );
  }
}

enum ElementType {
  paragraph,
  sectionBreak,
  table,
  image,
  shape,
}

class DocumentElement {
  final String id;
  final ElementType type;
  final Delta content;

  const DocumentElement({
    required this.id,
    required this.type,
    this.content = const Delta(),
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'content': content.toJson(),
      };

  factory DocumentElement.fromJson(Map<String, dynamic> json) {
    return DocumentElement(
      id: json['id'] as String,
      type: ElementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ElementType.paragraph,
      ),
      content: json['content'] != null
          ? Delta.fromJson(json['content'] as List<dynamic>)
          : const Delta(),
    );
  }
}
