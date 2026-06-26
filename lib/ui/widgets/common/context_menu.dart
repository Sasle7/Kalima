import 'package:flutter/material.dart';

/// Context menu that appears on text selection (long press or right-click).
///
/// Provides Cut, Copy, Paste, Select All, and formatting shortcuts.
class ContextMenu extends StatefulWidget {
  /// The screen position where the menu should appear.
  final Offset position;

  /// Whether text is currently selected.
  final bool hasSelection;

  /// Whether clipboard content is available for paste.
  final bool canPaste;

  /// Callback when an action is selected.
  final ValueChanged<ContextMenuAction> onAction;

  const ContextMenu({
    super.key,
    required this.position,
    this.hasSelection = false,
    this.canPaste = true,
    required this.onAction,
  });

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(color: Colors.transparent),
        ),
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              surfaceTintColor: const Color(0xFF1A1A2E),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.hasSelection) ...[
                      _MenuItem(
                        icon: Icons.content_cut,
                        label: 'قص',
                        shortcut: 'Ctrl+X',
                        onTap: () => _select(ContextMenuAction.cut),
                      ),
                      _MenuItem(
                        icon: Icons.content_copy,
                        label: 'نسخ',
                        shortcut: 'Ctrl+C',
                        onTap: () => _select(ContextMenuAction.copy),
                      ),
                    ],
                    if (widget.canPaste)
                      _MenuItem(
                        icon: Icons.content_paste,
                        label: 'لصق',
                        shortcut: 'Ctrl+V',
                        onTap: () => _select(ContextMenuAction.paste),
                      ),
                    _MenuItem(
                      icon: Icons.select_all,
                      label: 'تحديد الكل',
                      shortcut: 'Ctrl+A',
                      onTap: () => _select(ContextMenuAction.selectAll),
                    ),
                    if (widget.hasSelection) ...[
                      const _Divider(),
                      _MenuItem(
                        icon: Icons.format_bold,
                        label: 'عريض',
                        shortcut: 'Ctrl+B',
                        onTap: () => _select(ContextMenuAction.bold),
                      ),
                      _MenuItem(
                        icon: Icons.format_italic,
                        label: 'مائل',
                        shortcut: 'Ctrl+I',
                        onTap: () => _select(ContextMenuAction.italic),
                      ),
                      _MenuItem(
                        icon: Icons.format_underline,
                        label: 'تسطير',
                        shortcut: 'Ctrl+U',
                        onTap: () => _select(ContextMenuAction.underline),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _select(ContextMenuAction action) {
    Navigator.of(context).pop();
    widget.onAction(action);
  }
}

/// Actions that can be triggered from the context menu.
enum ContextMenuAction {
  cut,
  copy,
  paste,
  selectAll,
  bold,
  italic,
  underline,
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String shortcut;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.shortcut,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1A1A2E)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 24),
            Text(
              shortcut,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withValues(alpha: 0.15),
      indent: 8,
      endIndent: 8,
    );
  }
}
