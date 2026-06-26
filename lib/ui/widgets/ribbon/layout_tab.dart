import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/document/document_bloc.dart';

/// Layout tab content within the ribbon toolbar.
///
/// Provides page size, orientation, margins, columns,
/// section breaks, and ruler toggle controls.
class LayoutTab extends StatelessWidget {
  const LayoutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        final doc = state is DocumentLoaded ? state.document : null;

        return SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              // Page Size
              _LayoutDropdown(
                icon: Icons.article_outlined,
                label: 'حجم الصفحة',
                value: doc?.pageSize ?? 'A4',
                items: const ['A4', 'Letter', 'A5', 'A3', 'Legal'],
                onChanged: (v) => context
                    .read<DocumentBloc>()
                    .add(SetPageSize(v!)),
              ),
              _Separator(),
              // Orientation toggle
              _LayoutButton(
                icon: doc?.isLandscape ?? false
                    ? Icons.screen_rotation_alt
                    : Icons.portrait,
                label: 'اتجاه',
                onPressed: () => context
                    .read<DocumentBloc>()
                    .add(const ToggleOrientation()),
              ),
              _Separator(),
              // Margins
              _LayoutDropdown(
                icon: Icons.margin,
                label: 'هوامش',
                value: _marginLabel(doc?.marginPreset ?? 'normal'),
                items: const ['Normal', 'Narrow', 'Wide', 'Custom'],
                onChanged: (v) => context
                    .read<DocumentBloc>()
                    .add(SetMarginPreset(v!.toLowerCase())),
              ),
              _Separator(),
              // Columns
              _LayoutDropdown(
                icon: Icons.view_column_outlined,
                label: 'أعمدة',
                value: _columnsLabel(doc?.columnCount ?? 1),
                items: const ['1', '2', '3'],
                onChanged: (v) => context
                    .read<DocumentBloc>()
                    .add(SetColumnCount(int.parse(v!))),
              ),
              _Separator(),
              // Section break
              _LayoutButton(
                icon: Icons.horizontal_rule,
                label: 'فاصل مقطعي',
                onPressed: () => context
                    .read<DocumentBloc>()
                    .add(const InsertSectionBreak()),
              ),
              _Separator(),
              // Ruler toggle
              _LayoutButton(
                icon: Icons.straighten,
                label: 'مسطرة',
                isToggle: true,
                isActive: doc?.showRuler ?? true,
                onPressed: () => context
                    .read<DocumentBloc>()
                    .add(const ToggleRuler()),
              ),
            ],
          ),
        );
      },
    );
  }

  String _marginLabel(String preset) {
    switch (preset) {
      case 'normal':
        return 'عادي';
      case 'narrow':
        return 'ضيق';
      case 'wide':
        return 'واسع';
      default:
        return 'مخصص';
    }
  }

  String _columnsLabel(int count) {
    return '$count';
  }
}

class _LayoutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isToggle;
  final bool isActive;
  final VoidCallback onPressed;

  const _LayoutButton({
    required this.icon,
    required this.label,
    this.isToggle = false,
    this.isActive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: label,
        child: Material(
          color: isActive
              ? const Color(0xFF0860CD).withValues(alpha: 0.15)
              : Colors.transparent,
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
                    color: isActive
                        ? const Color(0xFF0860CD)
                        : const Color(0xFF1A1A2E).withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 9,
                      color: isActive
                          ? const Color(0xFF0860CD)
                          : const Color(0xFF1A1A2E).withValues(alpha: 0.6),
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

class _LayoutDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _LayoutDropdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Container(
        constraints: const BoxConstraints(minWidth: 72),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isDense: true,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Color(0xFF1A1A2E),
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
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
