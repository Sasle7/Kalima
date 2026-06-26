import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../engine/document/document_model.dart' as engine;

class PdfExporter {
  static const _pageWidth = PdfPageFormat.a4.availableWidth;
  static const _pageHeight = PdfPageFormat.a4.availableHeight;
  static const _margin = 72.0;
  static const _contentWidth = _pageWidth - 2 * _margin;

  final bool embedFonts;
  final PdfPageFormat pageFormat;

  PdfExporter({
    this.embedFonts = true,
    this.pageFormat = PdfPageFormat.a4,
  }) : assert(pageFormat.availableWidth > 0 && pageFormat.availableHeight > 0);

  Future<Uint8List> exportToPdf(engine.DocumentModel document) async {
    final doc = pw.Document(
      title: document.title,
      author: document.metadata.author ?? 'Kalima',
      subject: document.metadata.subject,
      creator: 'Kalima Word Processor',
    );

    final fontData = await _loadFontData();
    final font = fontData != null
        ? pw.Font.ttf(fontData.buffer as ByteBuffer)
        : null;

    final fallbackFont = fontData != null
        ? pw.Font.ttf(fontData.buffer as ByteBuffer)
        : null;

    pw.Font? regularFont;
    pw.Font? boldFont;
    pw.Font? italicFont;
    pw.Font? boldItalicFont;

    if (embedFonts) {
      regularFont = font;
      boldFont = font;
      italicFont = font;
      boldItalicFont = font;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.all(_margin),
        build: (pw.Context context) {
          final pages = <pw.Widget>[];
          final blocks = document.blocks;

          for (final block in blocks) {
            switch (block.type) {
              case engine.BlockType.heading1:
                pages.add(_buildHeading(block, 1, regularFont, boldFont));
                break;
              case engine.BlockType.heading2:
                pages.add(_buildHeading(block, 2, regularFont, boldFont));
                break;
              case engine.BlockType.heading3:
                pages.add(_buildHeading(block, 3, regularFont, boldFont));
                break;
              case engine.BlockType.heading4:
                pages.add(_buildHeading(block, 4, regularFont, boldFont));
                break;
              case engine.BlockType.heading5:
                pages.add(_buildHeading(block, 5, regularFont, boldFont));
                break;
              case engine.BlockType.heading6:
                pages.add(_buildHeading(block, 6, regularFont, boldFont));
                break;
              case engine.BlockType.paragraph:
              case engine.BlockType.listItem:
                pages.add(_buildParagraph(block, regularFont, boldFont,
                    italicFont, boldItalicFont));
                break;
              case engine.BlockType.quote:
                pages.add(_buildQuote(block, regularFont, italicFont));
                break;
              case engine.BlockType.codeBlock:
                pages.add(_buildCodeBlock(block, regularFont));
                break;
              case engine.BlockType.image:
                final imgWidget = _buildImage(block);
                if (imgWidget != null) pages.add(imgWidget);
                break;
              case engine.BlockType.table:
                final tableWidget = _buildTable(block, regularFont, boldFont);
                if (tableWidget != null) pages.add(tableWidget);
                break;
              case engine.BlockType.pageBreak:
                pages.add(pw.PageBreak());
                break;
            }
          }

          return pages;
        },
      ),
    );

    return doc.save();
  }

  Future<void> exportToFile(
    engine.DocumentModel document,
    String filePath,
  ) async {
    final pdfBytes = await exportToPdf(document);
    await File(filePath).writeAsBytes(pdfBytes);
  }

  Future<Uint8List?> _loadFontData() async {
    try {
      final fontBundle = await PdfGoogleFonts.cairoRegular();
      return fontBundle;
    } catch (_) {
      try {
        final fontBundle = await PdfGoogleFonts.notoSansArabic();
        return fontBundle;
      } catch (_) {
        return null;
      }
    }
  }

  pw.Widget _buildHeading(
    engine.DocumentBlock block,
    int level,
    pw.Font? regularFont,
    pw.Font? boldFont,
  ) {
    final sizes = [24, 20, 16, 14, 12, 11];
    final size = sizes[level.clamp(1, 6) - 1];

    return pw.Padding(
      padding: pw.EdgeInsets.only(
        top: 16 + (6 - level) * 4,
        bottom: 8 + (6 - level) * 2,
      ),
      child: _buildRichText(
        block,
        pw.TextStyle(
          fontSize: size,
          fontWeight: pw.FontWeight.bold,
          font: boldFont ?? regularFont,
          color: PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _buildParagraph(
    engine.DocumentBlock block,
    pw.Font? regularFont,
    pw.Font? boldFont,
    pw.Font? italicFont,
    pw.Font? boldItalicFont,
  ) {
    final fmt = block.format;
    final alignment = _toPdfAlignment(fmt.alignment);

    return pw.Padding(
      padding: pw.EdgeInsets.only(
        top: fmt.spaceBefore,
        bottom: fmt.spaceAfter,
        left: fmt.indentLeft + (fmt.listLevel * 20),
        right: fmt.indentRight,
      ),
      child: _buildRichText(
        block,
        pw.TextStyle(
          fontSize: 12,
          font: regularFont,
          color: PdfColors.black,
        ),
        alignment: alignment,
        lineSpacing: fmt.lineSpacing,
      ),
    );
  }

  pw.Widget _buildQuote(
    engine.DocumentBlock block,
    pw.Font? regularFont,
    pw.Font? italicFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 16),
      padding: const pw.EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: 12,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.grey400, width: 3),
        ),
      ),
      child: _buildRichText(
        block,
        pw.TextStyle(
          fontSize: 14,
          font: italicFont ?? regularFont,
          fontStyle: pw.FontStyle.italic,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  pw.Widget _buildCodeBlock(
    engine.DocumentBlock block,
    pw.Font? regularFont,
  ) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: _buildRichText(
        block,
        pw.TextStyle(
          fontSize: 10,
          font: regularFont,
          color: PdfColors.grey900,
        ),
      ),
    );
  }

  pw.Widget? _buildImage(engine.DocumentBlock block) {
    if (block.imagePath == null) return null;

    try {
      final file = File(block.imagePath!);
      if (!file.existsSync()) return null;

      final bytes = file.readAsBytesSync();
      final img = pw.MemoryImage(Uint8List.fromList(bytes));

      double width = block.imageWidth ?? 300;
      double height = block.imageHeight ?? 200;

      if (width > _contentWidth) {
        height = height * (_contentWidth / width);
        width = _contentWidth;
      }

      return pw.Center(
        child: pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 12),
          child: pw.Column(
            children: [
              pw.Image(img, width: width, height: height),
              if (block.imageAltText != null && block.imageAltText!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(
                    block.imageAltText!,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  pw.Widget? _buildTable(
    engine.DocumentBlock block,
    pw.Font? regularFont,
    pw.Font? boldFont,
  ) {
    if (block.tableCells == null || block.tableCells!.isEmpty) return null;

    final rows = <pw.TableRow>[];
    for (final row in block.tableCells!) {
      final cells = <pw.Widget>[];
      for (final cell in row) {
        final cellContent = <pw.Widget>[];
        for (final cellBlock in cell.blocks) {
          cellContent.add(
            _buildParagraph(
              cellBlock,
              regularFont,
              boldFont,
              regularFont,
              regularFont,
            ),
          );
        }

        cells.add(
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
              color: cell.isHeader ? PdfColors.grey100 : null,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: cellContent,
            ),
          ),
        );
      }
      rows.add(pw.TableRow(
        children: cells,
      ));
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      child: pw.Table(
        border: pw.TableBorder.all(
          color: PdfColors.grey400,
          width: 0.5,
        ),
        children: rows,
      ),
    );
  }

  pw.Widget _buildRichText(
    engine.DocumentBlock block,
    pw.TextStyle baseStyle, {
    pw.TextAlign? alignment,
    double? lineSpacing,
  }) {
    final spans = <pw.WidgetSpan>[];
    final runs = block.textRuns;

    if (runs.isEmpty) {
      return pw.Paragraph(
        text: '',
        style: baseStyle.copyWith(fontSize: baseStyle.fontSize),
        textAlign: alignment ?? pw.TextAlign.left,
      );
    }

    for (final run in runs) {
      final style = baseStyle.copyWith(
        fontSize: run.format.fontSize ?? baseStyle.fontSize,
        fontWeight: run.format.isBold ? pw.FontWeight.bold : baseStyle.fontWeight,
        fontStyle: run.format.isItalic ? pw.FontStyle.italic : baseStyle.fontStyle,
        decoration: run.format.isUnderline
            ? pw.TextDecoration.underline
            : baseStyle.decoration,
        color: run.format.textColor != null
            ? PdfColor.fromInt(run.format.textColor!.value)
            : baseStyle.color,
        background: run.format.highlightColor != null
            ? PdfColor.fromInt(run.format.highlightColor!.withOpacity(0.3).value)
            : null,
      );

      spans.add(
        pw.WidgetSpan(
          child: pw.Text(run.text, style: style),
        ),
      );
    }

    return pw.RichText(
      text: pw.TextSpan(children: spans),
      textAlign: alignment ?? pw.TextAlign.left,
    );
  }

  pw.TextAlign _toPdfAlignment(engine.TextAlignment alignment) {
    switch (alignment) {
      case engine.TextAlignment.right:
        return pw.TextAlign.right;
      case engine.TextAlignment.center:
        return pw.TextAlign.center;
      case engine.TextAlignment.justify:
        return pw.TextAlign.justify;
      case engine.TextAlignment.left:
        return pw.TextAlign.left;
    }
  }

  static Future<void> printDocument(engine.DocumentModel document) async {
    final exporter = PdfExporter();
    final pdfBytes = await exporter.exportToPdf(document);
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
    );
  }
}
