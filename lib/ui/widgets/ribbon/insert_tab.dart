import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kalima/logic/bloc/document/document_bloc.dart';
import 'package:kalima/ui/widgets/dialogs/table_dialog.dart';

/// Insert tab content within the ribbon toolbar.
///
/// Provides buttons for inserting tables, images, shapes,
/// headers/footers, page numbers, and text boxes.
class InsertTab extends StatelessWidget {
  const InsertTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _InsertButton(
            icon: Icons.grid_on,
            label: 'جدول',
            onPressed: () => _showTableDialog(context),
          ),
          _Separator(),
          _InsertButton(
            icon: Icons.image_outlined,
            label: 'صورة',
            onPressed: () {
              // TODO: InsertImageRequested
            },
          ),
          _Separator(),
          _InsertButton(
            icon: Icons.category_outlined,
            label: 'شكل',
            onPressed: () => _showShapeMenu(context),
          ),
          _Separator(),
          _InsertButton(
            icon: Icons.title,
            label: 'رأس الصفحة',
            isToggle: true,
            onPressed: () {
              // TODO: ToggleHeaderFooter
            },
          ),
          _InsertButton(
            icon: Icons.text_snippet,
            label: 'تذييل الصفحة',
            isToggle: true,
            onPressed: () {
              // TODO: ToggleHeaderFooter
            },
          ),
          _Separator(),
          _InsertButton(
            icon: Icons.looks_one,
            label: 'رقم الصفحة',
            onPressed: () {
              // TODO: InsertPageNumber
            },
          ),
          _Separator(),
          _InsertButton(
            icon: Icons.text_fields,
            label: 'مربع نص',
            onPressed: () {
              // TODO: InsertTextBox
            },
          ),
        ],
      ),
    );
  }

  void _showTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const TableInsertDialog(),
    );
  }

  void _showShapeMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إدراج شكل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ShapeOption(icon: Icons.rectangle_outlined, label: 'مستطيل'),
                  _ShapeOption(icon: Icons.circle_outlined, label: 'دائرة'),
                  _ShapeOption(icon: Icons.arrow_forward_outlined, label: 'سهم'),
                  _ShapeOption(icon: Icons.star_outline, label: 'نجمة'),
                  _ShapeOption(icon: Icons.line_axis, label: 'خط'),
                  _ShapeOption(icon: Icons.change_history, label: 'مثلث'),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _InsertButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isToggle;
  final VoidCallback onPressed;

  const _InsertButton({
    required this.icon,
    required this.label,
    this.isToggle = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onPressed,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 9,
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }
}

class _ShapeOption extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ShapeOption({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // TODO: InsertShape
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
