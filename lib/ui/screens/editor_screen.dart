import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/document/document_bloc.dart';
import 'package:kalima/logic/cubit/ui_cubit.dart';
import 'package:kalima/ui/adapters/keyboard_shortcuts.dart';
import 'package:kalima/ui/adapters/mouse_handler.dart';
import 'package:kalima/ui/adapters/stylus_handler.dart';
import 'package:kalima/ui/widgets/canvas/document_canvas.dart';
import 'package:kalima/ui/widgets/common/ruler_widget.dart';
import 'package:kalima/ui/widgets/common/status_bar.dart';
import 'package:kalima/ui/widgets/ribbon/ribbon_bar.dart';
import 'package:kalima/ui/widgets/sidebar/comments_panel.dart';
import 'package:kalima/ui/widgets/sidebar/styles_panel.dart';

/// Main editor screen for the Kalima word processor.
///
/// Composed of a ribbon toolbar at the top, a document canvas in the center,
/// an optional sidebar (comments/styles), and a status bar at the bottom.
/// Supports RTL layout, keyboard shortcuts, and responsive ribbon (landscape
/// shows full ribbon, portrait shows compact ribbon).
class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutHandler(
      child: MouseHandler(
        child: StylusHandler(
          child: BlocBuilder<UiCubit, UiState>(
            builder: (context, uiState) {
              return Scaffold(
                backgroundColor: const Color(0xFFE8E8E8),
                body: SafeArea(
                  child: Column(
                    children: [
                      // Ribbon toolbar
                      const RibbonBar(),
                      // Ruler (optional)
                      BlocBuilder<DocumentBloc, DocumentState>(
                        builder: (context, docState) {
                          final doc = docState is DocumentLoaded
                              ? docState.document
                              : null;
                          if (doc?.showRuler ?? true) {
                            return const RulerWidget();
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // Main editor area with optional sidebar
                      Expanded(
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            // Sidebar (comments or styles)
                            if (uiState.sidebarType == SidebarType.comments)
                              const CommentsPanel(),
                            if (uiState.sidebarType == SidebarType.styles)
                              const StylesPanel(),
                            // Document canvas
                            Expanded(
                              child: ClipRect(
                                child: Stack(
                                  children: [
                                    const DocumentCanvas(),
                                    // Sidebar toggle buttons
                                    Positioned(
                                      left: 8,
                                      top: 8,
                                      child: _SidebarToggle(
                                        icon: Icons.comment_outlined,
                                        tooltip: 'التعليقات',
                                        isActive: uiState.sidebarType ==
                                            SidebarType.comments,
                                        onTap: () => context
                                            .read<UiCubit>()
                                            .toggleSidebar(SidebarType.comments),
                                      ),
                                    ),
                                    Positioned(
                                      left: 8,
                                      top: 52,
                                      child: _SidebarToggle(
                                        icon: Icons.text_fields,
                                        tooltip: 'الأنماط',
                                        isActive: uiState.sidebarType ==
                                            SidebarType.styles,
                                        onTap: () => context
                                            .read<UiCubit>()
                                            .toggleSidebar(SidebarType.styles),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status bar
                      const StatusBar(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SidebarToggle extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarToggle({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? const Color(0xFF0860CD)
          : Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: isActive ? 3 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: isActive
                ? const Color(0xFF1A1A2E)
                : const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
