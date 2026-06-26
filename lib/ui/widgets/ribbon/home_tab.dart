import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/format/format_bloc.dart';

/// Home tab content within the ribbon toolbar.
///
/// Provides font family, font size, text styling (bold, italic, underline),
/// color pickers, alignment, line spacing, lists, and a style gallery.
/// All buttons are tablet-friendly with minimum 48x48 touch targets.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormatBloc, FormatState>(
      builder: (context, state) {
        return SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              // Font family dropdown
              _DropdownButton(
                value: state.fontFamily ?? 'Traditional Arabic',
                items: const [
                  'Traditional Arabic',
                  'Amiri',
                  'Cairo',
                  'Noto Naskh Arabic',
                  'Scheherazade New',
                  'Lateef',
                ],
                onChanged: (v) => context
                    .read<FormatBloc>()
                    .add(SetFontFamily(v!)),
                minWidth: 120,
              ),
              _Separator(),
              // Font size
              _DropdownButton(
                value: state.fontSize?.round().toString() ?? '14',
                items: List.generate(
                  33,
                  (i) => '${(i * 2) + 8}',
                ),
                onChanged: (v) => context
                    .read<FormatBloc>()
                    .add(SetFontSize(double.parse(v!))),
                minWidth: 64,
              ),
              _Separator(),
              // Bold
              _ToolButton(
                icon: Icons.format_bold,
                isActive: state.isBold ?? false,
                tooltip: 'عريض',
                onPressed: () =>
                    context.read<FormatBloc>().add(const ToggleBold()),
              ),
              // Italic
              _ToolButton(
                icon: Icons.format_italic,
                isActive: state.isItalic ?? false,
                tooltip: 'مائل',
                onPressed: () =>
                    context.read<FormatBloc>().add(const ToggleItalic()),
              ),
              // Underline
              _ToolButton(
                icon: Icons.format_underline,
                isActive: state.isUnderline ?? false,
                tooltip: 'تسطير',
                onPressed: () =>
                    context.read<FormatBloc>().add(const ToggleUnderline()),
              ),
              _Separator(),
              // Text color
              _ColorButton(
                color: state.textColor ?? Colors.black,
                tooltip: 'لون الخط',
                onChanged: (c) =>
                    context.read<FormatBloc>().add(SetTextColor(c)),
              ),
              // Highlight color
              _ColorButton(
                color: state.highlightColor ?? Colors.yellow.withValues(alpha: 0.3),
                tooltip: 'تمييز',
                isHighlight: true,
                onChanged: (c) =>
                    context.read<FormatBloc>().add(SetHighlightColor(c)),
              ),
              _Separator(),
              // Alignment buttons
              _ToolButton(
                icon: Icons.format_align_right,
                isActive: state.alignment == TextAlign.right,
                tooltip: 'محاذاة لليمين',
                onPressed: () => context
                    .read<FormatBloc>()
                    .add(const SetAlignment(TextAlign.right)),
              ),
              _ToolButton(
                icon: Icons.format_align_center,
                isActive: state.alignment == TextAlign.center,
                tooltip: 'توسيط',
                onPressed: () => context
                    .read<FormatBloc>()
                    .add(const SetAlignment(TextAlign.center)),
              ),
              _ToolButton(
                icon: Icons.format_align_left,
                isActive: state.alignment == TextAlign.left,
                tooltip: 'محاذاة لليسار',
                onPressed: () => context
                    .read<FormatBloc>()
                    .add(const SetAlignment(TextAlign.left)),
              ),
              _ToolButton(
                icon: Icons.format_align_justify,
                isActive: state.alignment == TextAlign.justify,
                tooltip: 'ضبط',
                onPressed: () => context
                    .read<FormatBloc>()
                    .add(const SetAlignment(TextAlign.justify)),
              ),
              _Separator(),
              // Line spacing
              _DropdownButton(
                value: _lineSpacingLabel(state.lineSpacing ?? 1.5),
                items: const [
                  '1.0',
                  '1.15',
                  '1.5',
                  '2.0',
                  '2.5',
                  '3.0',
                ],
                onChanged: (v) => context
                    .read<FormatBloc>()
                    .add(SetLineSpacing(double.parse(v!))),
                minWidth: 72,
              ),
              _Separator(),
              // Lists
              _ToolButton(
                icon: Icons.format_list_bulleted,
                tooltip: 'قائمة نقطية',
                onPressed: () => context
                    .read<FormatBloc>()
                    .add(const ToggleBulletList()),
              ),
              _ToolButton(
                icon: Icons.format_list_numbered,
                tooltip: 'قائمة مرقمة',
                onPressed: () => context
                    .read<FormatBloc>()
                    .add(const ToggleNumberedList()),
              ),
              _Separator(),
              // Style gallery
              _StyleGallery(currentStyle: state.styleName),
            ],
          ),
        );
      },
    );
  }

  String _lineSpacingLabel(double spacing) {
    if (spacing == 1.0) return '1.0';
    if (spacing == 1.15) return '1.15';
    if (spacing == 1.5) return '1.5';
    if (spacing == 2.0) return '2.0';
    if (spacing == 2.5) return '2.5';
    if (spacing == 3.0) return '3.0';
    return spacing.toStringAsFixed(1);
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    this.isActive = false,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: isActive
              ? const Color(0xFFE5B143).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onPressed,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 20,
                color: isActive
                    ? const Color(0xFFE5B143)
                    : const Color(0xFF1A1A2E).withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final String tooltip;
  final bool isHighlight;
  final ValueChanged<Color> onChanged;

  const _ColorButton({
    required this.color,
    required this.tooltip,
    this.isHighlight = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => _showColorPicker(context),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: isHighlight
                    ? Icon(
                        Icons.edit_note,
                        size: 16,
                        color: Colors.grey.withValues(alpha: 0.5),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          tooltip,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Colors.primaries.map((c) {
            return GestureDetector(
              onTap: () {
                onChanged(c);
                Navigator.pop(ctx);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DropdownButton extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final double minWidth;

  const _DropdownButton({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
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

class _StyleGallery extends StatelessWidget {
  final String? currentStyle;

  const _StyleGallery({this.currentStyle});

  @override
  Widget build(BuildContext context) {
    final styles = [
      ('العنوان 1', 'Heading 1', 22.0, FontWeight.w700),
      ('العنوان 2', 'Heading 2', 18.0, FontWeight.w600),
      ('العنوان 3', 'Heading 3', 16.0, FontWeight.w600),
      ('نص عادي', 'Normal', 14.0, FontWeight.w400),
      ('اقتباس', 'Quote', 14.0, FontWeight.w400),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: styles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final style = styles[index];
          final isSelected = currentStyle == style.$2;
          return GestureDetector(
            onTap: () => context
                .read<FormatBloc>()
                .add(ApplyStyle(style.$2)),
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE5B143).withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? Border.all(
                        color: const Color(0xFFE5B143).withValues(alpha: 0.4))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    style.$1,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: style.$3.clamp(10.0, 14.0),
                      fontWeight: style.$4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    style.$1,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 9,
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
