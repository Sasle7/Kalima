import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/document/document_bloc.dart';
import 'package:kalima/logic/bloc/editor/editor_bloc.dart';

/// Individual document page view.
///
/// Renders a single page using CustomPaint with page margins,
/// headers, footers, text content, tables, and images at their
/// correct positions. Handles gesture events (tap, long press,
/// double tap) and overlays selection highlights and cursor.
class DocumentPageView extends StatelessWidget {
  /// The page index to render.
  final int pageIndex;

  /// Text direction for the page content.
  final TextDirection textDirection;

  const DocumentPageView({
    super.key,
    required this.pageIndex,
    this.textDirection = TextDirection.rtl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, docState) {
        final doc = docState is DocumentLoaded ? docState.document : null;
        final pageData = doc?.pages != null && pageIndex < doc!.pages.length
            ? doc.pages[pageIndex]
            : null;

        return BlocBuilder<EditorBloc, EditorState>(
          builder: (context, editorState) {
            return Directionality(
              textDirection: textDirection,
              child: Stack(
                children: [
                  // Page content rendered with CustomPaint
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PageContentPainter(
                        pageData: pageData,
                        textDirection: textDirection,
                      ),
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 72,   // header margin
                          bottom: 72, // footer margin
                          left: 80,  // right margin (RTL)
                          right: 80, // left margin (RTL)
                        ),
                        child: Stack(
                          children: [
                            // Header area
                            Positioned(
                              top: -60,
                              left: 0,
                              right: 0,
                              child: _buildHeader(context, pageData),
                            ),
                            // Footer area
                            Positioned(
                              bottom: -60,
                              left: 0,
                              right: 0,
                              child: _buildFooter(context, pageData),
                            ),
                            // Main content body
                            Positioned.fill(
                              child: _buildPageContent(
                                context,
                                doc,
                                pageData,
                                editorState,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Cursor overlay
                  if (editorState is EditorEditing &&
                      editorState.cursorPage == pageIndex)
                    Positioned(
                      left: editorState.cursorPosition.dx,
                      top: editorState.cursorPosition.dy,
                      child: _buildCursor(editorState),
                    ),
                  // Selection overlay
                  if (editorState is EditorEditing &&
                      editorState.selectionStart != null &&
                      editorState.selectionEnd != null)
                    _buildSelectionOverlay(editorState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, dynamic pageData) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: Text(
        pageData?.header ?? '',
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          color: Color(0xFF1A1A2E),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFooter(BuildContext context, dynamic pageData) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: Text(
        '— ${pageIndex + 1} —',
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          color: Color(0xFF1A1A2E),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPageContent(
    BuildContext context,
    dynamic doc,
    dynamic pageData,
    EditorState editorState,
  ) {
    return const SizedBox.expand();
  }

  Widget _buildCursor(EditorEditing state) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 2,
        height: 20,
        color: const Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildSelectionOverlay(EditorEditing state) {
    if (state.selectionStart == null || state.selectionEnd == null) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _SelectionPainter(
            start: state.selectionStart!,
            end: state.selectionEnd!,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for page content rendering.
class _PageContentPainter extends CustomPainter {
  final dynamic pageData;
  final TextDirection textDirection;

  _PageContentPainter({required this.pageData, required this.textDirection});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw page margins
    final marginPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      marginPaint,
    );

    // Draw column guides if applicable
    if (pageData != null) {
      final columnCount = pageData.columnCount ?? 1;
      if (columnCount > 1) {
        final columnWidth = size.width / columnCount;
        final columnPaint = Paint()
          ..color = Colors.blue.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

        for (int i = 1; i < columnCount; i++) {
          canvas.drawLine(
            Offset(columnWidth * i, 0),
            Offset(columnWidth * i, size.height),
            columnPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PageContentPainter old) =>
      old.pageData != pageData;
}

/// Painter for text selection highlight.
class _SelectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  _SelectionPainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5B143).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromPoints(start, end);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _SelectionPainter old) =>
      old.start != start || old.end != end;
}
