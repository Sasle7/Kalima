import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/format/format_bloc.dart';

/// Styles panel displayed in the editor sidebar.
///
/// Lists available document styles (Heading 1, 2, 3, Body, Quote)
/// with previews showing font, size, color, and alignment.
/// Tap to apply, long press for modify options.
class StylesPanel extends StatelessWidget {
  const StylesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormatBloc, FormatState>(
      builder: (context, state) {
        final styles = _getStyles();

        return Container(
          width: 260,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: const Text(
                  'الأنماط',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              // Styles list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: styles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final style = styles[index];
                    final isActive = state.styleName == style.name;

                    return _StyleCard(
                      style: style,
                      isActive: isActive,
                      onTap: () => context
                          .read<FormatBloc>()
                          .add(ApplyStyle(style.name)),
                      onLongPress: () => _showModifyDialog(context, style),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_StyleInfo> _getStyles() {
    return const [
      _StyleInfo(
        name: 'Heading 1',
        label: 'العنوان 1',
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
        alignment: TextAlign.right,
        description: 'للعناوين الرئيسية',
      ),
      _StyleInfo(
        name: 'Heading 2',
        label: 'العنوان 2',
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
        alignment: TextAlign.right,
        description: 'للعناوين الفرعية',
      ),
      _StyleInfo(
        name: 'Heading 3',
        label: 'العنوان 3',
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
        alignment: TextAlign.right,
        description: 'لأقسام المحتوى',
      ),
      _StyleInfo(
        name: 'Normal',
        label: 'نص عادي',
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: Color(0xFF1A1A2E),
        alignment: TextAlign.right,
        description: 'النص الأساسي',
      ),
      _StyleInfo(
        name: 'Quote',
        label: 'اقتباس',
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: Color(0xFF555555),
        alignment: TextAlign.right,
        description: 'للنصوص المقتبسة',
      ),
    ];
  }

  void _showModifyDialog(BuildContext context, _StyleInfo style) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'تعديل النمط: ${style.label}',
          style: const TextStyle(fontFamily: 'Amiri'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'يمكن تعديل خصائص النمط من هنا',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('الخط', style: TextStyle(fontFamily: 'Cairo')),
              subtitle: Text(
                style.fontSize.toString(),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.format_color_text),
              title: const Text('اللون', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.space_bar),
              title: const Text('التباعد', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إغلاق',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleInfo {
  final String name;
  final String label;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign alignment;
  final String description;

  const _StyleInfo({
    required this.name,
    required this.label,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    required this.alignment,
    required this.description,
  });
}

class _StyleCard extends StatelessWidget {
  final _StyleInfo style;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _StyleCard({
    required this.style,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFE5B143).withValues(alpha: 0.1)
              : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? const Color(0xFFE5B143).withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.15),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: style.fontSize.clamp(14.0, 24.0),
                      fontWeight: style.fontWeight,
                      color: style.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    style.description,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFE5B143)
                      : const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 16, color: Color(0xFFE5B143))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
