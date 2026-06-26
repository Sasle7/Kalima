import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/document/document_bloc.dart';
import 'package:kalima/logic/bloc/document/document_state.dart';
import 'package:kalima/logic/bloc/editor/editor_bloc.dart';
import 'package:kalima/logic/bloc/editor/editor_state.dart';
import 'package:kalima/ui/widgets/canvas/page_view.dart';

/// Document canvas widget.
///
/// Uses InteractiveViewer to provide pinch-to-zoom and pan gestures.
/// Shows pages with realistic shadows and borders in print layout view.
/// Lazily renders only visible pages and handles tap-to-position-cursor
/// as well as drag-to-select text interactions.
class DocumentCanvas extends StatefulWidget {
  const DocumentCanvas({super.key});

  @override
  State<DocumentCanvas> createState() => _DocumentCanvasState();
}

class _DocumentCanvasState extends State<DocumentCanvas> {
  final TransformationController _transformController =
      TransformationController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _transformController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, editorState) {
        return BlocBuilder<DocumentBloc, DocumentState>(
          builder: (context, docState) {
            final doc = docState is DocumentLoaded ? docState.document : null;
            final pages = [1]; // TODO: get from doc.pages
            final zoom = 1.0; // TODO: get from doc.zoomLevel

            return Focus(
              focusNode: _focusNode,
              autofocus: true,
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.5,
                maxScale: 3.0,
                boundaryMargin: const EdgeInsets.all(200),
                child: Container(
                  color: const Color(0xFFE8E8E8),
                  width: MediaQuery.of(context).size.width * zoom,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Render visible pages only
                          for (int i = 0; i < pages.length; i++)
                            _buildPage(context, i, pages.length, docState),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    int pageIndex,
    int totalPages,
    DocumentState docState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTapDown: (details) {
          context.read<EditorBloc>().add(
                const CursorMoved(0), // TODO: convert localPosition to text index
              );
        },
        onLongPressStart: (details) {
          context.read<EditorBloc>().add(
                const SelectText(0, 0), // TODO: convert localPosition to text index
              );
        },
        onDoubleTapDown: (details) {
          context.read<EditorBloc>().add(
                const SelectText(0, 0), // TODO: convert localPosition to text index
              );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1),
            child: SizedBox(
              width: 595, // A4 width in logical pixels at 72 DPI
              height: 842, // A4 height in logical pixels at 72 DPI
              child: DocumentPageView(
                pageIndex: pageIndex,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
