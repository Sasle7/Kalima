import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../../engine/document/document_model.dart' as engine;
import '../../engine/document/document_parser.dart';

class DocxParser implements DocumentParser {
  @override
  String get formatName => 'Office Open XML Document';

  @override
  List<String> get supportedExtensions => ['.docx'];

  @override
  bool get supportsImport => true;

  @override
  bool get supportsExport => true;

  static const _contentTypesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Default Extension="jpg" ContentType="image/jpeg"/>
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Default Extension="gif" ContentType="image/gif"/>
  <Default Extension="bmp" ContentType="image/bmp"/>
  <Default Extension="svg" ContentType="image/svg+xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
</Types>''';

  static final _relsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>''';

  static final _documentRelsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/>
</Relationships>''';

  static final _corePropsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:creator>Kalima</dc:creator>
  <dc:description>Created with Kalima Word Processor</dc:description>
  <dcterms:created xsi:type="dcterms:W3CDTF">{createdAt}</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">{modifiedAt}</dcterms:modified>
</cp:coreProperties>''';

  static final _appPropsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Kalima Word Processor</Application>
  <DocSecurity>0</DocSecurity>
  <Lines>{lineCount}</Lines>
  <Paragraphs>{paraCount}</Paragraphs>
  <Template>Normal.dotm</Template>
  <TotalTime>0</TotalTime>
</Properties>''';

  @override
  Future<engine.DocumentModel> parse(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('DOCX file not found', filePath);
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final documentXml = archive.files.firstWhere(
      (f) => f.name == 'word/document.xml',
      orElse: () => throw FormatException('Invalid DOCX: missing document.xml'),
    );

    final stylesXml = archive.files.firstWhere(
      (f) => f.name == 'word/styles.xml',
      orElse: () => null,
    );

    final docContent = utf8.decode(documentXml.content);
    final docElement = XmlDocument.parse(docContent);

    final styles = <String, Map<String, dynamic>>{};
    if (stylesXml != null) {
      final stylesContent = utf8.decode(stylesXml.content);
      _parseStyles(stylesContent, styles);
    }

    final body = docElement.findAllElements('w:body').first;
    final paragraphs = body.findElements('w:p');

    final blocks = <engine.DocumentBlock>[];
    final images = <String, List<int>>{};

    for (final mediaFile in archive.files) {
      if (mediaFile.name.startsWith('word/media/')) {
        final name = mediaFile.name.replaceFirst('word/media/', '');
        images[name] = mediaFile.content;
      }
    }

    String tempDir = '${Directory.systemTemp.path}/docx_${const Uuid().v4()}';
    if (images.isNotEmpty) {
      final dir = Directory(tempDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      for (final entry in images.entries) {
        final imgFile = File('$tempDir/${entry.key}');
        await imgFile.writeAsBytes(entry.value);
      }
    }

    for (final para in paragraphs) {
      final block = _parseParagraph(para, styles, tempDir);
      blocks.add(block);
    }

    for (final entry in images.entries) {
      final imgFile = File('$tempDir/${entry.key}');
      if (await imgFile.exists()) {
        final block = engine.DocumentBlock(
          id: const Uuid().v4(),
          type: engine.BlockType.image,
          imagePath: imgFile.path,
          imageAltText: entry.key,
        );
        blocks.add(block);
      }
    }

    if (tempDir.isNotEmpty) {
      final dir = Directory(tempDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }

    final docxStyles = styles.entries.map((e) {
      final s = e.value;
      return engine.DocumentStyle(
        name: e.key,
        basedOn: s['basedOn'] as String?,
        fontFamily: s['fontFamily'] as String?,
        fontSize: (s['fontSize'] as num?)?.toDouble(),
        isBold: s['isBold'] as bool? ?? false,
        isItalic: s['isItalic'] as bool? ?? false,
        isUnderline: s['isUnderline'] as bool? ?? false,
        alignment: _parseAlignment(s['alignment'] as String?),
        lineSpacing: (s['lineSpacing'] as num?)?.toDouble() ?? 1.5,
      );
    }).toList();

    return engine.DocumentModel(
      id: const Uuid().v4(),
      title: filePath.split('/').last.replaceAll('.docx', ''),
      blocks: blocks,
      styles: docxStyles,
      isRtl: _hasRtlContent(docElement),
    );
  }

  bool _hasRtlContent(XmlDocument doc) {
    try {
      final body = doc.findAllElements('w:body').first;
      final paragraphs = body.findElements('w:p');
      for (final para in paragraphs) {
        final bidi = para.findElements('w:bidi');
        if (bidi.isNotEmpty) return true;
        final rtlPara = para.findAllElements('w:rtl');
        if (rtlPara.isNotEmpty) return true;
      }
    } catch (_) {}
    return false;
  }

  engine.DocumentBlock _parseParagraph(
    XmlElement para,
    Map<String, Map<String, dynamic>> styles,
    String tempDir,
  ) {
    final paraProps = para.findElements('w:pPr').firstOrNull;

    engine.BlockFormat blockFormat = engine.BlockFormat.empty;
    engine.BlockType blockType = engine.BlockType.paragraph;

    if (paraProps != null) {
      blockFormat = _parseParagraphFormat(paraProps, styles);

      final pStyle = paraProps.findElements('w:pStyle').firstOrNull;
      if (pStyle != null) {
        final styleVal = pStyle.getAttribute('w:val') ?? '';
        blockType = _styleToBlockType(styleVal);
      }
    }

    final textRuns = <engine.TextRun>[];
    for (final run in para.findElements('w:r')) {
      final text = run.findElements('w:t').firstOrNull;
      if (text == null) continue;

      String runText = text.innerText;
      final preserve = text.getAttribute('xml:space') == 'preserve';
      if (!preserve) {
        runText = runText.trim();
      }

      final rPr = run.findElements('w:rPr').firstOrNull;
      final format = _parseRunFormat(rPr);

      final drawing = run.findElements('w:drawing').firstOrNull;
      if (drawing != null) {
        final blip = drawing
            .findElements('a:blip')
            .firstOrNull;
        if (blip != null) {
          final embed = blip.getAttribute('r:embed') ?? '';
          return engine.DocumentBlock(
            id: const Uuid().v4(),
            type: engine.BlockType.image,
            imagePath: embed.isNotEmpty ? '$tempDir/$embed' : null,
            format: blockFormat,
          );
        }
      }

      if (runText.isNotEmpty) {
        textRuns.add(engine.TextRun(runText, format: format));
      }
    }

    final tables = para.parent?.findElements('w:tbl').firstOrNull;
    if (tables != null) {
      return _parseTable(tables);
    }

    return engine.DocumentBlock(
      id: const Uuid().v4(),
      type: blockType,
      textRuns: textRuns,
      format: blockFormat,
    );
  }

  void _parseStyles(
    String stylesContent,
    Map<String, Map<String, dynamic>> styles,
  ) {
    final doc = XmlDocument.parse(stylesContent);
    for (final style in doc.findAllElements('w:style')) {
      final styleId = style.getAttribute('w:styleId') ?? '';
      final styleName = style
          .findElements('w:name')
          .firstOrNull
          ?.getAttribute('w:val') ?? styleId;

      final rPr = style.findElements('w:rPr').firstOrNull;
      final pPr = style.findElements('w:pPr').firstOrNull;

      final styleData = <String, dynamic>{
        'name': styleName,
        'basedOn': style
            .findElements('w:basedOn')
            .firstOrNull
            ?.getAttribute('w:val'),
      };

      if (rPr != null) {
        final rFonts = rPr.findElements('w:rFonts').firstOrNull;
        if (rFonts != null) {
          styleData['fontFamily'] = rFonts.getAttribute('w:ascii') ??
              rFonts.getAttribute('w:hAnsi');
        }

        final sz = rPr.findElements('w:sz').firstOrNull;
        if (sz != null) {
          final val = sz.getAttribute('w:val');
          if (val != null) styleData['fontSize'] = double.parse(val) / 2;
        }

        final b = rPr.findElements('w:b').firstOrNull;
        if (b != null) styleData['isBold'] = b.getAttribute('w:val') != 'false';

        final i = rPr.findElements('w:i').firstOrNull;
        if (i != null) styleData['isItalic'] = i.getAttribute('w:val') != 'false';

        final u = rPr.findElements('w:u').firstOrNull;
        if (u != null) styleData['isUnderline'] = u.getAttribute('w:val') != 'none';
      }

      if (pPr != null) {
        final jc = pPr.findElements('w:jc').firstOrNull;
        if (jc != null) styleData['alignment'] = jc.getAttribute('w:val');

        final spacing = pPr.findElements('w:spacing').firstOrNull;
        if (spacing != null) {
          final line = spacing.getAttribute('w:line');
          if (line != null) {
            styleData['lineSpacing'] = double.parse(line) / 240;
          }
        }
      }

      styles[styleId] = styleData;
    }
  }

  engine.BlockFormat _parseParagraphFormat(
    XmlElement paraProps,
    Map<String, Map<String, dynamic>> styles,
  ) {
    String alignment = 'left';
    double indentLeft = 0;
    double indentRight = 0;
    double indentFirstLine = 0;
    double lineSpacing = 1.5;
    double spaceBefore = 0;
    double spaceAfter = 8;
    bool isRtl = false;

    final jc = paraProps.findElements('w:jc').firstOrNull;
    if (jc != null) {
      alignment = jc.getAttribute('w:val') ?? 'left';
    }

    final ind = paraProps.findElements('w:ind').firstOrNull;
    if (ind != null) {
      final left = ind.getAttribute('w:left');
      if (left != null) indentLeft = double.parse(left) / 567;
      final right = ind.getAttribute('w:right');
      if (right != null) indentRight = double.parse(right) / 567;
      final firstLine = ind.getAttribute('w:firstLine');
      if (firstLine != null) indentFirstLine = double.parse(firstLine) / 567;
    }

    final spacing = paraProps.findElements('w:spacing').firstOrNull;
    if (spacing != null) {
      final line = spacing.getAttribute('w:line');
      if (line != null) lineSpacing = double.parse(line) / 240;
      final before = spacing.getAttribute('w:before');
      if (before != null) spaceBefore = double.parse(before) / 20;
      final after = spacing.getAttribute('w:after');
      if (after != null) spaceAfter = double.parse(after) / 20;
    }

    final bidi = paraProps.findElements('w:bidi').firstOrNull;
    if (bidi != null) isRtl = true;

    final pStyle = paraProps.findElements('w:pStyle').firstOrNull;
    if (pStyle != null) {
      final styleId = pStyle.getAttribute('w:val') ?? '';
      final styleData = styles[styleId];
      if (styleData != null) {
        if (styleData['alignment'] != null) {
          alignment = styleData['alignment'] as String;
        }
        if (styleData['lineSpacing'] != null) {
          lineSpacing = styleData['lineSpacing'] as double;
        }
      }
    }

    return engine.BlockFormat(
      alignment: _parseAlignment(alignment),
      indentLeft: indentLeft,
      indentRight: indentRight,
      indentFirstLine: indentFirstLine,
      lineSpacing: lineSpacing,
      spaceBefore: spaceBefore,
      spaceAfter: spaceAfter,
      isRtl: isRtl,
    );
  }

  engine.TextFormat _parseRunFormat(XmlElement? rPr) {
    if (rPr == null) return engine.TextFormat.empty;

    String? fontFamily;
    double? fontSize;
    bool isBold = false;
    bool isItalic = false;
    bool isUnderline = false;
    Color? textColor;
    Color? highlightColor;

    final rFonts = rPr.findElements('w:rFonts').firstOrNull;
    if (rFonts != null) {
      fontFamily = rFonts.getAttribute('w:ascii') ??
          rFonts.getAttribute('w:hAnsi') ??
          rFonts.getAttribute('w:cs');
    }

    final sz = rPr.findElements('w:sz').firstOrNull;
    if (sz != null) {
      final val = sz.getAttribute('w:val');
      if (val != null) fontSize = double.parse(val) / 2;
    }

    final b = rPr.findElements('w:b').firstOrNull;
    if (b != null) isBold = b.getAttribute('w:val') != 'false';

    final i = rPr.findElements('w:i').firstOrNull;
    if (i != null) isItalic = i.getAttribute('w:val') != 'false';

    final u = rPr.findElements('w:u').firstOrNull;
    if (u != null) {
      final val = u.getAttribute('w:val');
      isUnderline = val != null && val != 'none';
    }

    final color = rPr.findElements('w:color').firstOrNull;
    if (color != null) {
      final val = color.getAttribute('w:val');
      if (val != null && val != 'auto') {
        final intVal = int.tryParse(val, radix: 16);
        if (intVal != null) {
          textColor = Color(0xFF000000 | intVal);
        }
      }
    }

    final highlight = rPr.findElements('w:highlight').firstOrNull;
    if (highlight != null) {
      final val = highlight.getAttribute('w:val');
      if (val != null && val != 'none') {
        highlightColor = _highlightColor(val);
      }
    }

    return engine.TextFormat(
      fontFamily: fontFamily,
      fontSize: fontSize,
      isBold: isBold,
      isItalic: isItalic,
      isUnderline: isUnderline,
      textColor: textColor,
      highlightColor: highlightColor,
    );
  }

  engine.DocumentBlock _parseTable(XmlElement tableElement) {
    final rows = tableElement.findElements('w:tr');
    final tableRows = <List<engine.TableCell>>[];

    for (final row in rows) {
      final cells = row.findElements('w:tc');
      final rowCells = <engine.TableCell>[];

      for (final cell in cells) {
        final cellContents = <engine.DocumentBlock>[];
        final paragraphs = cell.findElements('w:p');
        for (final para in paragraphs) {
          cellContents.add(_parseParagraph(
            para,
            {},
            '',
          ));
        }

        final tcPr = cell.findElements('w:tcPr').firstOrNull;
        int rowSpan = 1;
        int colSpan = 1;
        bool isHeader = false;

        if (tcPr != null) {
          final vMerge = tcPr.findElements('w:vMerge').firstOrNull;
          if (vMerge != null) rowSpan = 2;
          final gridSpan = tcPr.findElements('w:gridSpan').firstOrNull;
          if (gridSpan != null) {
            final val = gridSpan.getAttribute('w:val');
            if (val != null) colSpan = int.tryParse(val) ?? 1;
          }
        }

        rowCells.add(engine.TableCell(
          blocks: cellContents,
          rowSpan: rowSpan,
          colSpan: colSpan,
          isHeader: isHeader,
        ));
      }

      tableRows.add(rowCells);
    }

    return engine.DocumentBlock(
      id: const Uuid().v4(),
      type: engine.BlockType.table,
      tableCells: tableRows,
    );
  }

  @override
  Future<void> save(engine.DocumentModel document, String filePath) async {
    final archive = Archive();

    final contentTypesBytes = utf8.encode(_contentTypesXml);
    archive.addFile(ArchiveFile(
      '[Content_Types].xml',
      contentTypesBytes.length,
      contentTypesBytes,
    ));

    final relsBytes = utf8.encode(_relsXml);
    archive.addFile(ArchiveFile(
      '_rels/.rels',
      relsBytes.length,
      relsBytes,
    ));

    final docRels = _buildDocumentRels(document);
    final docRelsBytes = utf8.encode(docRels);
    archive.addFile(ArchiveFile(
      'word/_rels/document.xml.rels',
      docRelsBytes.length,
      docRelsBytes,
    ));

    final now = DateTime.now();
    final coreProps = _corePropsXml
        .replaceAll('{createdAt}', now.toIso8601String())
        .replaceAll('{modifiedAt}', now.toIso8601String());
    final corePropsBytes = utf8.encode(coreProps);
    archive.addFile(ArchiveFile(
      'docProps/core.xml',
      corePropsBytes.length,
      corePropsBytes,
    ));

    final paraCount = document.blocks
        .where((b) =>
            b.type == engine.BlockType.paragraph ||
            b.type == engine.BlockType.heading1 ||
            b.type == engine.BlockType.heading2 ||
            b.type == engine.BlockType.heading3)
        .length;
    final lineCount = document.blocks.length;
    final appProps = _appPropsXml
        .replaceAll('{paraCount}', paraCount.toString())
        .replaceAll('{lineCount}', lineCount.toString());
    final appPropsBytes = utf8.encode(appProps);
    archive.addFile(ArchiveFile(
      'docProps/app.xml',
      appPropsBytes.length,
      appPropsBytes,
    ));

    final stylesXml = _buildStylesXml(document);
    final stylesBytes = utf8.encode(stylesXml);
    archive.addFile(ArchiveFile(
      'word/styles.xml',
      stylesBytes.length,
      stylesBytes,
    ));

    final numberingXml = _buildNumberingXml(document);
    final numberingBytes = utf8.encode(numberingXml);
    archive.addFile(ArchiveFile(
      'word/numbering.xml',
      numberingBytes.length,
      numberingBytes,
    ));

    final documentXml = _buildDocumentXml(document);
    final documentBytes = utf8.encode(documentXml);
    archive.addFile(ArchiveFile(
      'word/document.xml',
      documentBytes.length,
      documentBytes,
    ));

    int imageIndex = 0;
    for (final block in document.blocks) {
      if (block.type == engine.BlockType.image && block.imagePath != null) {
        final imgFile = File(block.imagePath!);
        if (await imgFile.exists()) {
          imageIndex++;
          final ext = block.imagePath!.split('.').last.toLowerCase();
          final mediaName = 'image$imageIndex.$ext';
          final imgBytes = await imgFile.readAsBytes();
          archive.addFile(ArchiveFile(
            'word/media/$mediaName',
            imgBytes.length,
            imgBytes,
          ));
        }
      }
    }

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw Exception('Failed to encode DOCX archive');
    }

    await File(filePath).writeAsBytes(encoded);
  }

  String _buildDocumentRels(engine.DocumentModel document) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    buffer.writeln(
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">');
    buffer.writeln(
        '  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>');
    buffer.writeln(
        '  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/>');

    int imgRelId = 3;
    int imgIndex = 0;
    for (final block in document.blocks) {
      if (block.type == engine.BlockType.image && block.imagePath != null) {
        imgIndex++;
        final ext = block.imagePath!.split('.').last.toLowerCase();
        buffer.writeln(
            '  <Relationship Id="rId$imgRelId" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image$imgIndex.$ext"/>');
        imgRelId++;
      }
    }

    buffer.writeln('</Relationships>');
    return buffer.toString();
  }

  String _buildDocumentXml(engine.DocumentModel document) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    buffer.writeln(
        '<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" '
        'xmlns:cx="http://schemas.microsoft.com/office/drawing/2014/chartex" '
        'xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" '
        'xmlns:o="urn:schemas-microsoft-com:office:office" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
        'xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" '
        'xmlns:v="urn:schemas-microsoft-com:vml" '
        'xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" '
        'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
        'xmlns:w10="urn:schemas-microsoft-com:office:word" '
        'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
        'xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" '
        'xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" '
        'xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" '
        'xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" '
        'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" '
        'mc:Ignorable="w14 wp14">');
    buffer.writeln('  <w:body>');

    for (final block in document.blocks) {
      switch (block.type) {
        case engine.BlockType.paragraph:
        case engine.BlockType.heading1:
        case engine.BlockType.heading2:
        case engine.BlockType.heading3:
        case engine.BlockType.heading4:
        case engine.BlockType.heading5:
        case engine.BlockType.heading6:
        case engine.BlockType.quote:
        case engine.BlockType.listItem:
          buffer.write(_buildParagraph(block));
          break;
        case engine.BlockType.table:
          buffer.write(_buildTable(block));
          break;
        case engine.BlockType.image:
          buffer.write(_buildImageParagraph(block));
          break;
        case engine.BlockType.pageBreak:
          buffer.writeln(
              '    <w:p><w:r><w:br w:type="page"/></w:r></w:p>');
          break;
        case engine.BlockType.codeBlock:
          buffer.write(_buildParagraph(block));
          break;
      }
    }

    buffer.writeln('  </w:body>');
    buffer.writeln('</w:document>');
    return buffer.toString();
  }

  String _buildParagraph(engine.DocumentBlock block) {
    final buffer = StringBuffer();
    buffer.writeln('    <w:p>');

    buffer.writeln('      <w:pPr>');

    final styleName = _blockTypeToStyleName(block.type);
    if (styleName != null) {
      buffer.writeln(
          '        <w:pStyle w:val="$styleName"/>');
    }

    final fmt = block.format;
    buffer.writeln(
        '        <w:jc w:val="${_alignmentToDocx(fmt.alignment)}"/>');

    if (fmt.indentLeft > 0 || fmt.indentRight > 0 || fmt.indentFirstLine != 0) {
      buffer.writeln('        <w:ind '
          '${fmt.indentLeft > 0 ? 'w:left="${(fmt.indentLeft * 567).round()}" ' : ''}'
          '${fmt.indentRight > 0 ? 'w:right="${(fmt.indentRight * 567).round()}" ' : ''}'
          '${fmt.indentFirstLine != 0 ? 'w:firstLine="${(fmt.indentFirstLine * 567).round()}" ' : ''}'
          '/>');
    }

    if (fmt.listType != engine.ListType.none) {
      buffer.writeln(
          '        <w:numPr><w:ilvl w:val="${fmt.listLevel}"/><w:numId w:val="1"/></w:numPr>');
    }

    if (fmt.isRtl) {
      buffer.writeln('        <w:bidi/>');
    }

    buffer.writeln(
        '        <w:spacing w:before="${(fmt.spaceBefore * 20).round()}" '
        'w:after="${(fmt.spaceAfter * 20).round()}" '
        'w:line="${(fmt.lineSpacing * 240).round()}" '
        'w:lineRule="auto"/>');

    buffer.writeln('      </w:pPr>');

    for (final run in block.textRuns) {
      buffer.writeln('      <w:r>');
      buffer.writeln('        <w:rPr>');

      if (run.format.fontFamily != null) {
        buffer.writeln(
            '          <w:rFonts w:ascii="${run.format.fontFamily}" w:hAnsi="${run.format.fontFamily}" w:cs="${run.format.fontFamily}"/>');
      }
      if (run.format.fontSize != null) {
        buffer.writeln(
            '          <w:sz w:val="${(run.format.fontSize! * 2).round()}"/>');
        buffer.writeln(
            '          <w:szCs w:val="${(run.format.fontSize! * 2).round()}"/>');
      }
      if (run.format.isBold) {
        buffer.writeln('          <w:b/>');
      }
      if (run.format.isItalic) {
        buffer.writeln('          <w:i/>');
      }
      if (run.format.isUnderline) {
        buffer.writeln('          <w:u w:val="single"/>');
      }
      if (run.format.textColor != null) {
        final hex = run.format.textColor!.value
            .toRadixString(16)
            .substring(2)
            .toUpperCase();
        buffer.writeln(
            '          <w:color w:val="$hex"/>');
      }
      if (run.format.highlightColor != null) {
        buffer.writeln(
            '          <w:highlight w:val="yellow"/>');
      }

      buffer.writeln('        </w:rPr>');
      final text = run.text.replaceAll('&', '&amp;')
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;');
      buffer.writeln(
          '        <w:t xml:space="preserve">$text</w:t>');
      buffer.writeln('      </w:r>');
    }

    buffer.writeln('    </w:p>');
    return buffer.toString();
  }

  String _buildImageParagraph(engine.DocumentBlock block) {
    if (block.imagePath == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('    <w:p>');
    buffer.writeln('      <w:pPr><w:jc w:val="center"/></w:pPr>');
    buffer.writeln('      <w:r>');
    buffer.writeln(
        '        <w:rPr><w:noProof/></w:rPr>');
    buffer.writeln(
        '        <w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0">');
    buffer.writeln(
        '          <wp:extent cx="${(block.imageWidth ?? 300) * 914400}" cy="${(block.imageHeight ?? 200) * 914400}"/>');
    buffer.writeln(
        '          <wp:effectExtent l="0" t="0" r="0" b="0"/>');
    buffer.writeln(
        '          <wp:docPr id="1" name="${block.imageAltText ?? 'Image'}"/>');
    buffer.writeln(
        '          <wp:cNvGraphicFramePr><a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/></wp:cNvGraphicFramePr>');
    buffer.writeln(
        '          <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">');
    buffer.writeln(
        '            <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">');
    buffer.writeln(
        '              <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">');
    buffer.writeln(
        '                <pic:nvPicPr><pic:cNvPr id="0" name="${block.imageAltText ?? 'Image'}"/><pic:nvPicPrName pref=""/></pic:nvPicPr>');
    buffer.writeln(
        '                <pic:blipFill><a:blip r:embed="rId1" cstate="print"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>');
    buffer.writeln(
        '                <pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="${(block.imageWidth ?? 300) * 914400}" cy="${(block.imageHeight ?? 200) * 914400}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>');
    buffer.writeln('              </pic:pic>');
    buffer.writeln('            </a:graphicData>');
    buffer.writeln('          </a:graphic>');
    buffer.writeln('        </wp:inline></w:drawing>');
    buffer.writeln('      </w:r>');
    buffer.writeln('    </w:p>');
    return buffer.toString();
  }

  String _buildTable(engine.DocumentBlock block) {
    final buffer = StringBuffer();
    buffer.writeln('    <w:tbl>');

    buffer.writeln(
        '      <w:tblPr><w:tblStyle w:val="TableGrid"/>'
        '<w:tblW w:w="5000" w:type="pct"/><w:tblBorders>'
        '<w:top w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
        '<w:left w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
        '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
        '<w:right w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
        '</w:tblBorders></w:tblPr>');

    if (block.tableCells != null) {
      for (final row in block.tableCells!) {
        buffer.writeln('      <w:tr>');
        for (final cell in row) {
          buffer.writeln('        <w:tc>');
          if (cell.colSpan > 1) {
            buffer.writeln(
                '          <w:tcPr><w:gridSpan w:val="${cell.colSpan}"/></w:tcPr>');
          }
          for (final cellBlock in cell.blocks) {
            buffer.write(_buildParagraph(cellBlock));
          }
          buffer.writeln('        </w:tc>');
        }
        buffer.writeln('      </w:tr>');
      }
    }

    buffer.writeln('    </w:tbl>');
    return buffer.toString();
  }

  String _buildStylesXml(engine.DocumentModel document) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    buffer.writeln(
        '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">');

    buffer.writeln(
        '  <w:style w:type="paragraph" w:styleId="Normal" w:default="1">');
    buffer.writeln(
        '    <w:name w:val="Normal"/><w:pPr><w:spacing w:after="160" w:line="360" w:lineRule="auto"/></w:pPr>');
    buffer.writeln(
        '    <w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>');
    buffer.writeln('  </w:style>');

    buffer.writeln(
        '  <w:style w:type="paragraph" w:styleId="Heading1">');
    buffer.writeln(
        '    <w:name w:val="heading 1"/><w:basedOn w:val="Normal"/>');
    buffer.writeln(
        '    <w:pPr><w:spacing w:before="480" w:after="240"/></w:pPr>');
    buffer.writeln(
        '    <w:rPr><w:b/><w:sz w:val="48"/><w:szCs w:val="48"/></w:rPr>');
    buffer.writeln('  </w:style>');

    buffer.writeln(
        '  <w:style w:type="paragraph" w:styleId="Heading2">');
    buffer.writeln(
        '    <w:name w:val="heading 2"/><w:basedOn w:val="Normal"/>');
    buffer.writeln(
        '    <w:pPr><w:spacing w:before="360" w:after="180"/></w:pPr>');
    buffer.writeln(
        '    <w:rPr><w:b/><w:sz w:val="40"/><w:szCs w:val="40"/></w:rPr>');
    buffer.writeln('  </w:style>');

    buffer.writeln(
        '  <w:style w:type="paragraph" w:styleId="Heading3">');
    buffer.writeln(
        '    <w:name w:val="heading 3"/><w:basedOn w:val="Normal"/>');
    buffer.writeln(
        '    <w:pPr><w:spacing w:before="240" w:after="120"/></w:pPr>');
    buffer.writeln(
        '    <w:rPr><w:b/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr>');
    buffer.writeln('  </w:style>');

    buffer.writeln(
        '  <w:style w:type="paragraph" w:styleId="Quote">');
    buffer.writeln(
        '    <w:name w:val="Quote"/><w:basedOn w:val="Normal"/>');
    buffer.writeln(
        '    <w:pPr><w:spacing w:before="240" w:after="240"/>'
        '<w:ind w:left="567" w:right="567"/></w:pPr>');
    buffer.writeln(
        '    <w:rPr><w:i/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr>');
    buffer.writeln('  </w:style>');

    if (document.styles.isNotEmpty) {
      for (final style in document.styles) {
        final isHeading = style.name.startsWith('Heading');
        if (isHeading) continue;
        buffer.writeln(
            '  <w:style w:type="paragraph" w:styleId="${style.name.replaceAll(' ', '')}">');
        buffer.writeln(
            '    <w:name w:val="${_xmlEscape(style.name)}"/><w:basedOn w:val="Normal"/>');
        buffer.writeln('    <w:rPr>');
        if (style.fontFamily != null) {
          buffer.writeln(
              '      <w:rFonts w:ascii="${style.fontFamily}" w:hAnsi="${style.fontFamily}"/>');
        }
        if (style.fontSize != null) {
          buffer.writeln(
              '      <w:sz w:val="${(style.fontSize! * 2).round()}"/>');
        }
        if (style.isBold) buffer.writeln('      <w:b/>');
        if (style.isItalic) buffer.writeln('      <w:i/>');
        buffer.writeln('    </w:rPr>');
        buffer.writeln('  </w:style>');
      }
    }

    buffer.writeln(
      '  <w:style w:type="table" w:styleId="TableGrid">'
      '<w:name w:val="Table Grid"/>'
      '<w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr>'
      '<w:tblPr><w:tblBorders>'
      '<w:top w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
      '<w:left w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
      '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
      '<w:right w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
      '</w:tblBorders></w:tblPr>'
      '</w:style>',
    );

    buffer.writeln('</w:styles>');
    return buffer.toString();
  }

  String _buildNumberingXml(engine.DocumentModel document) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    buffer.writeln(
        '<w:numbering xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">');
    buffer.writeln(
        '  <w:abstractNum w:abstractNumId="0">');
    buffer.writeln(
        '    <w:multiLevelType w:val="hybridMultilevel"/>');
    buffer.writeln(
        '    <w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="bullet"/><w:lvlText w:val="●"/></w:lvl>');
    buffer.writeln(
        '    <w:lvl w:ilvl="1"><w:start w:val="1"/><w:numFmt w:val="bullet"/><w:lvlText w:val="○"/></w:lvl>');
    buffer.writeln(
        '    <w:lvl w:ilvl="2"><w:start w:val="1"/><w:numFmt w:val="bullet"/><w:lvlText w:val="■"/></w:lvl>');
    buffer.writeln('  </w:abstractNum>');
    buffer.writeln(
        '  <w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num>');
    buffer.writeln('</w:numbering>');
    return buffer.toString();
  }

  engine.TextAlignment _parseAlignment(String? alignment) {
    switch (alignment) {
      case 'right':
        return engine.TextAlignment.right;
      case 'center':
        return engine.TextAlignment.center;
      case 'both':
        return engine.TextAlignment.justify;
      default:
        return engine.TextAlignment.left;
    }
  }

  String _alignmentToDocx(engine.TextAlignment alignment) {
    switch (alignment) {
      case engine.TextAlignment.right:
        return 'right';
      case engine.TextAlignment.center:
        return 'center';
      case engine.TextAlignment.justify:
        return 'both';
      case engine.TextAlignment.left:
        return 'left';
    }
  }

  engine.BlockType _styleToBlockType(String styleId) {
    switch (styleId.toLowerCase()) {
      case 'heading1':
      case 'heading 1':
        return engine.BlockType.heading1;
      case 'heading2':
      case 'heading 2':
        return engine.BlockType.heading2;
      case 'heading3':
      case 'heading 3':
        return engine.BlockType.heading3;
      case 'quote':
        return engine.BlockType.quote;
      case 'listparagraph':
        return engine.BlockType.listItem;
      default:
        return engine.BlockType.paragraph;
    }
  }

  String? _blockTypeToStyleName(engine.BlockType type) {
    switch (type) {
      case engine.BlockType.heading1:
        return 'Heading1';
      case engine.BlockType.heading2:
        return 'Heading2';
      case engine.BlockType.heading3:
        return 'Heading3';
      case engine.BlockType.heading4:
        return 'Heading4';
      case engine.BlockType.heading5:
        return 'Heading5';
      case engine.BlockType.heading6:
        return 'Heading6';
      case engine.BlockType.quote:
        return 'Quote';
      default:
        return null;
    }
  }

  Color _highlightColor(String val) {
    switch (val) {
      case 'yellow':
        return const Color(0xFFFFFF00);
      case 'green':
        return const Color(0xFF00FF00);
      case 'cyan':
        return const Color(0xFF00FFFF);
      case 'magenta':
        return const Color(0xFFFF00FF);
      case 'red':
        return const Color(0xFFFF0000);
      case 'blue':
        return const Color(0xFF0000FF);
      case 'black':
        return const Color(0xFF000000);
      case 'white':
        return const Color(0xFFFFFFFF);
      case 'darkYellow':
        return const Color(0xFF808000);
      case 'darkGreen':
        return const Color(0xFF008000);
      case 'darkCyan':
        return const Color(0xFF008080);
      case 'darkMagenta':
        return const Color(0xFF800080);
      case 'darkRed':
        return const Color(0xFF800000);
      case 'darkBlue':
        return const Color(0xFF000080);
      default:
        return const Color(0xFFFFFF00);
    }
  }

  String _xmlEscape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
