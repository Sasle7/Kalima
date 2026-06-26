import 'package:flutter/material.dart';

/// Table insert dialog with a visual grid picker.
///
/// Displays a grid of cells (up to 10x10) for selecting the
/// number of rows and columns to insert. The grid highlights
/// the current selection size.
class TableInsertDialog extends StatefulWidget {
  const TableInsertDialog({super.key});

  @override
  State<TableInsertDialog> createState() => _TableInsertDialogState();
}

class _TableInsertDialogState extends State<TableInsertDialog> {
  int _hoverColumns = 1;
  int _hoverRows = 1;

  static const int _maxColumns = 10;
  static const int _maxRows = 10;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'إدراج جدول',
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A2E),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grid selector
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (int row = 0; row < _maxRows; row++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int col = 0; col < _maxColumns; col++)
                        _GridCell(
                          isHighlighted: col < _hoverColumns && row < _hoverRows,
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Selection info
          Text(
            '$_hoverRows صفوف × $_hoverColumns أعمدة',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          // Quick size buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickSize(
                label: '2×2',
                onTap: () => setState(() {
                  _hoverRows = 2;
                  _hoverColumns = 2;
                }),
              ),
              _QuickSize(
                label: '3×3',
                onTap: () => setState(() {
                  _hoverRows = 3;
                  _hoverColumns = 3;
                }),
              ),
              _QuickSize(
                label: '4×4',
                onTap: () => setState(() {
                  _hoverRows = 4;
                  _hoverColumns = 4;
                }),
              ),
              _QuickSize(
                label: '5×5',
                onTap: () => setState(() {
                  _hoverRows = 5;
                  _hoverColumns = 5;
                }),
              ),
              _QuickSize(
                label: '2×5',
                onTap: () => setState(() {
                  _hoverRows = 2;
                  _hoverColumns = 5;
                }),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'إلغاء',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0860CD),
            foregroundColor: const Color(0xFF1A1A2E),
          ),
          onPressed: () {
            Navigator.pop(context, {
              'rows': _hoverRows,
              'columns': _hoverColumns,
            });
          },
          child: const Text(
            'إدراج',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  final bool isHighlighted;

  const _GridCell({required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFF0860CD).withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFF0860CD)
              : Colors.grey.withValues(alpha: 0.3),
          width: isHighlighted ? 1.5 : 0.5,
        ),
      ),
    );
  }
}

class _QuickSize extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickSize({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }
}
