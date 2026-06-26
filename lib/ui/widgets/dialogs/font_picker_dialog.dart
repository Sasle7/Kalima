import 'package:flutter/material.dart';

/// Font picker dialog or bottom sheet.
///
/// Shows available Arabic fonts with preview text,
/// a recent fonts section, and allows selection.
class FontPickerDialog extends StatefulWidget {
  /// Currently selected font family.
  final String? selectedFont;

  /// Callback when a font is selected.
  final ValueChanged<String> onFontSelected;

  const FontPickerDialog({
    super.key,
    this.selectedFont,
    required this.onFontSelected,
  });

  /// Shows the font picker as a bottom sheet.
  static Future<void> show({
    required BuildContext context,
    String? selectedFont,
    required ValueChanged<String> onFontSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FontPickerDialog(
        selectedFont: selectedFont,
        onFontSelected: onFontSelected,
      ),
    );
  }

  @override
  State<FontPickerDialog> createState() => _FontPickerDialogState();
}

class _FontPickerDialogState extends State<FontPickerDialog> {
  String _searchQuery = '';

  final List<_FontInfo> _allFonts = [
    _FontInfo('Traditional Arabic', 'العربية', 'TraditionalArabic'),
    _FontInfo('Amiri', 'العربية', 'Amiri'),
    _FontInfo('Cairo', 'العربية', 'Cairo'),
    _FontInfo('Noto Naskh Arabic', 'العربية', 'NotoNaskhArabic'),
    _FontInfo('Scheherazade New', 'العربية', 'ScheherazadeNew'),
    _FontInfo('Lateef', 'العربية', 'Lateef'),
    _FontInfo('Almarai', 'العربية', 'Almarai'),
    _FontInfo('Readex Pro', 'العربية', 'ReadexPro'),
    _FontInfo('Tajawal', 'العربية', 'Tajawal'),
    _FontInfo('Lalezar', 'العربية', 'Lalezar'),
  ];

  List<String> get _recentFonts => const [
    'Traditional Arabic',
    'Amiri',
    'Cairo',
  ];

  List<_FontInfo> get _filteredFonts {
    if (_searchQuery.isEmpty) return _allFonts;
    return _allFonts
        .where((f) =>
            f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'اختيار الخط',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              // Search field
              TextField(
                decoration: InputDecoration(
                  hintText: 'بحث عن خط...',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 16),
              // Recent fonts section
              if (_searchQuery.isEmpty) ...[
                Text(
                  'الخطوط المستخدمة مؤخراً',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentFonts.map((name) {
                    final isSelected = name == widget.selectedFont;
                    return ActionChip(
                      label: Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      backgroundColor: isSelected
                          ? const Color(0xFF0860CD).withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.08),
                      side: isSelected
                          ? const BorderSide(
                              color: Color(0xFF0860CD), width: 1)
                          : BorderSide.none,
                      onPressed: () {
                        widget.onFontSelected(name);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
              ],
              // Font list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _filteredFonts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final font = _filteredFonts[index];
                    final isSelected = font.name == widget.selectedFont;
                    return InkWell(
                      onTap: () {
                        widget.onFontSelected(font.name);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    font.name,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      color: const Color(0xFF1A1A2E)
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    font.preview,
                                    style: TextStyle(
                                      fontFamily: font.fontFamily,
                                      fontSize: 20,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF0860CD),
                                size: 22,
                              ),
                          ],
                        ),
                      ),
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
}

class _FontInfo {
  final String name;
  final String preview;
  final String fontFamily;

  const _FontInfo(this.name, this.preview, this.fontFamily);
}
