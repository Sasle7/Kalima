import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide TextAlign;
import 'package:kalima/engine/document/document_model.dart';
import 'package:kalima/engine/document/delta_format.dart';

import 'text_layout_engine.dart';
import 'line_breaker.dart';

class LayoutPosition extends Equatable {
  final double x;
  final double y;

  const LayoutPosition(this.x, this.y);

  LayoutPosition translate(double dx, double dy) =>
      LayoutPosition(x + dx, y + dy);

  @override
  List<Object?> get props => [x, y];
}

class LayoutSize extends Equatable {
  final double width;
  final double height;

  const LayoutSize(this.width, this.height);

  @override
  List<Object?> get props => [width, height];
}

class ElementLayout extends Equatable {
  final String elementId;
  final ElementType type;
  final LayoutPosition position;
  final LayoutSize size;
  final List<LineLayout> lines;
  final List<Rect> selectionRects;

  const ElementLayout({
    required this.elementId,
    required this.type,
    required this.position,
    required this.size,
    this.lines = const [],
    this.selectionRects = const [],
  });

  ElementLayout copyWith({
    String? elementId,
    ElementType? type,
    LayoutPosition? position,
    LayoutSize? size,
    List<LineLayout>? lines,
    List<Rect>? selectionRects,
  }) {
    return ElementLayout(
      elementId: elementId ?? this.elementId,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      lines: lines ?? this.lines,
      selectionRects: selectionRects ?? this.selectionRects,
    );
  }

  Rect get rect => Rect.fromLTWH(
        position.x,
        position.y,
        size.width,
        size.height,
      );

  @override
  List<Object?> get props => [
        elementId,
        type,
        position,
        size,
        lines,
        selectionRects,
      ];
}

class PageLayout extends Equatable {
  final int pageNumber;
  final LayoutSize size;
  final DocumentSection section;
  final List<ElementLayout> elements;
  final Map<String, HeaderFooterLayout> headers;
  final Map<String, HeaderFooterLayout> footers;
  final LayoutPosition contentOffset;

  const PageLayout({
    required this.pageNumber,
    required this.size,
    required this.section,
    this.elements = const [],
    this.headers = const {},
    this.footers = const {},
    required this.contentOffset,
  });

  double get contentWidth => size.width - section.margins.left - section.margins.right;
  double get contentHeight => size.height - section.margins.top - section.margins.bottom;

  Rect get contentRect => Rect.fromLTWH(
        contentOffset.x,
        contentOffset.y,
        contentWidth,
        contentHeight,
      );

  PageLayout copyWith({
    int? pageNumber,
    LayoutSize? size,
    DocumentSection? section,
    List<ElementLayout>? elements,
    Map<String, HeaderFooterLayout>? headers,
    Map<String, HeaderFooterLayout>? footers,
    LayoutPosition? contentOffset,
  }) {
    return PageLayout(
      pageNumber: pageNumber ?? this.pageNumber,
      size: size ?? this.size,
      section: section ?? this.section,
      elements: elements ?? this.elements,
      headers: headers ?? this.headers,
      footers: footers ?? this.footers,
      contentOffset: contentOffset ?? this.contentOffset,
    );
  }

  @override
  List<Object?> get props => [
        pageNumber,
        size,
        section,
        elements,
        headers,
        footers,
        contentOffset,
      ];
}

class HeaderFooterLayout extends Equatable {
  final String id;
  final LayoutPosition position;
  final LayoutSize size;
  final Delta content;

  const HeaderFooterLayout({
    required this.id,
    required this.position,
    required this.size,
    this.content = const Delta(),
  });

  @override
  List<Object?> get props => [id, position, size, content];
}

class DocumentLayout extends Equatable {
  final List<PageLayout> pages;
  final int totalPages;

  const DocumentLayout({
    this.pages = const [],
    this.totalPages = 0,
  });

  PageLayout? getPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > pages.length) return null;
    return pages[pageNumber - 1];
  }

  DocumentLayout copyWith({
    List<PageLayout>? pages,
    int? totalPages,
  }) {
    return DocumentLayout(
      pages: pages ?? this.pages,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [pages, totalPages];
}

class PageLayoutEngine {
  final TextLayoutEngine _textEngine;
  final LineBreaker _lineBreaker;

  PageLayoutEngine({
    required TextLayoutEngine textEngine,
    LineBreaker? lineBreaker,
  })  : _textEngine = textEngine,
        _lineBreaker = lineBreaker ?? LineBreaker(textEngine: textEngine);

  DocumentLayout layoutDocument(DocumentModel document) {
    final pages = <PageLayout>[];
    final section = document.sections.isNotEmpty
        ? document.sections.first
        : const DocumentSection();
    var currentElements = <DocumentElement>[];

    for (final page in document.pages) {
      currentElements.addAll(page.elements);
    }

    if (currentElements.isEmpty) {
      final emptyPage = _createEmptyPage(1, section);
      pages.add(emptyPage);
    } else {
      int pageNumber = 1;
      var pendingElements = currentElements;
      final pendingDeltaList = <Delta>[];
      Delta currentDelta = Delta();

      for (final element in pendingElements) {
        if (element.type == ElementType.sectionBreak) {
          if (currentDelta.operations.isNotEmpty) {
            pendingDeltaList.add(currentDelta);
            currentDelta = Delta();
          }
          pendingDeltaList.add(Delta([
            InsertOperation.embed({
              'type': 'sectionBreak',
              'sectionId': element.id,
            })
          ]));
        } else if (element.type == ElementType.paragraph) {
          currentDelta = currentDelta.concat(element.content);
          currentDelta = currentDelta.insert('\n');
        } else if (element.type == ElementType.table ||
            element.type == ElementType.image ||
            element.type == ElementType.shape) {
          if (currentDelta.operations.isNotEmpty) {
            pendingDeltaList.add(currentDelta);
            currentDelta = Delta();
          }
          pendingDeltaList.add(element.content);
        }
      }

      if (currentDelta.operations.isNotEmpty) {
        pendingDeltaList.add(currentDelta);
      }

      int deltaIndex = 0;
      while (deltaIndex < pendingDeltaList.length) {
        final pageLayout = _layoutPage(
          pageNumber,
          section,
          pendingDeltaList,
          deltaIndex,
        );
        pages.add(pageLayout.page);
        deltaIndex = pageLayout.nextDeltaIndex;
        pageNumber++;
      }
    }

    if (pages.isEmpty) {
      pages.add(_createEmptyPage(1, section));
    }

    return DocumentLayout(
      pages: pages,
      totalPages: pages.length,
    );
  }

  _PageLayoutResult _layoutPage(
    int pageNumber,
    DocumentSection section,
    List<Delta> deltas,
    int startDeltaIndex,
  ) {
    final elements = <ElementLayout>[];
    double currentY = section.margins.top;
    final double maxY =
        section.pageHeight - section.margins.bottom;
    final double contentWidth =
        section.pageWidth - section.margins.left - section.margins.right;
    int deltaIndex = startDeltaIndex;

    while (deltaIndex < deltas.length) {
      final delta = deltas[deltaIndex];

      if (delta.operations.isEmpty) {
        deltaIndex++;
        continue;
      }

      final firstOp = delta.operations.first;
      if (firstOp is InsertOperation && firstOp.isEmbed &&
          firstOp.embedData?['type'] == 'sectionBreak') {
        if (elements.isNotEmpty) {
          break;
        }
        final sectionData = firstOp.embedData!;
        final newSection = DocumentSection(
          pageSize: PageSize(
            width: (sectionData['pageWidth'] as num?)?.toDouble() ??
                section.pageSize.width,
            height: (sectionData['pageHeight'] as num?)?.toDouble() ??
                section.pageSize.height,
          ),
          orientation: (sectionData['orientation'] as String?) == 'landscape'
              ? PageOrientation.landscape
              : PageOrientation.portrait,
          margins: sectionData['margins'] != null
              ? PageMargins.fromJson(
                  sectionData['margins'] as Map<String, dynamic>)
              : section.margins,
        );
        deltaIndex++;
        return _PageLayoutResult(
          page: _createEmptyPage(pageNumber, newSection),
          nextDeltaIndex: deltaIndex,
        );
      }

      final elementLayout =
          _layoutParagraph(delta, contentWidth, section);
      final elementHeight = elementLayout.size.height;

      if (currentY + elementHeight > maxY) {
        if (elements.isEmpty) {
          elements.add(elementLayout);
          currentY += elementHeight;
        }
        break;
      }

      elements.add(elementLayout);
      currentY += elementHeight;
      deltaIndex++;
    }

    final contentOffset = LayoutPosition(section.margins.left, section.margins.top);

    return _PageLayoutResult(
      page: PageLayout(
        pageNumber: pageNumber,
        size: LayoutSize(section.pageWidth, section.pageHeight),
        section: section,
        elements: elements,
        contentOffset: contentOffset,
      ),
      nextDeltaIndex: deltaIndex,
    );
  }

  ElementLayout _layoutParagraph(
    Delta delta,
    double contentWidth,
    DocumentSection section,
  ) {
    final lines = _lineBreaker.breakLines(
      delta,
      maxWidth: contentWidth,
      isRtl: true,
    );

    final totalHeight =
        lines.fold(0.0, (sum, line) => sum + line.height + line.lineSpacing);

    return ElementLayout(
      elementId: _generateId(),
      type: ElementType.paragraph,
      position: LayoutPosition(0, 0),
      size: LayoutSize(contentWidth, totalHeight),
      lines: lines,
    );
  }

  PageLayout _createEmptyPage(int pageNumber, DocumentSection section) {
    return PageLayout(
      pageNumber: pageNumber,
      size: LayoutSize(section.pageWidth, section.pageHeight),
      section: section,
      contentOffset:
          LayoutPosition(section.margins.left, section.margins.top),
    );
  }

  DocumentLayout relayoutPage(
    DocumentLayout currentLayout,
    int pageNumber,
    Delta newContent,
  ) {
    final pageIndex = pageNumber - 1;
    if (pageIndex < 0 || pageIndex >= currentLayout.pages.length) {
      return currentLayout;
    }

    final oldPage = currentLayout.pages[pageIndex];
    final rebuilt = _layoutPage(
      pageNumber,
      oldPage.section,
      [newContent],
      0,
    );

    final newPages = List<PageLayout>.from(currentLayout.pages);
    newPages[pageIndex] = rebuilt.page;

    if (rebuilt.nextDeltaIndex > 1) {
    }

    return DocumentLayout(
      pages: newPages,
      totalPages: newPages.length,
    );
  }

  String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }
}

class _PageLayoutResult {
  final PageLayout page;
  final int nextDeltaIndex;
  const _PageLayoutResult({
    required this.page,
    required this.nextDeltaIndex,
  });
}
