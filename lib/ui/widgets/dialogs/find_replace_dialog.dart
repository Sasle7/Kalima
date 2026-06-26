import 'package:flutter/material.dart';

/// Find and Replace dialog.
///
/// Provides find and replace functionality with options for
/// match case and tashkeel-aware search. Includes Find Next,
/// Find Previous, Replace, and Replace All buttons with
/// results count display.
class FindReplaceDialog extends StatefulWidget {
  const FindReplaceDialog({super.key});

  /// Shows the find & replace dialog.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const FindReplaceDialog(),
    );
  }

  @override
  State<FindReplaceDialog> createState() => _FindReplaceDialogState();
}

class _FindReplaceDialogState extends State<FindReplaceDialog> {
  final _findController = TextEditingController();
  final _replaceController = TextEditingController();
  bool _matchCase = false;
  bool _tashkeelAware = false;
  int _resultCount = 0;
  int _currentIndex = 0;

  @override
  void dispose() {
    _findController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and close
            Row(
              children: [
                const Text(
                  'بحث واستبدال',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Find field
            TextField(
              controller: _findController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'بحث...',
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              onChanged: (_) => _updateResults(),
            ),
            const SizedBox(height: 12),
            // Replace field
            TextField(
              controller: _replaceController,
              decoration: InputDecoration(
                hintText: 'استبدال بـ...',
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
                prefixIcon: const Icon(Icons.find_replace, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
            const SizedBox(height: 12),
            // Options
            Row(
              children: [
                FilterChip(
                  label: const Text(
                    'مطابقة حالة الأحرف',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11),
                  ),
                  selected: _matchCase,
                  onSelected: (v) => setState(() {
                    _matchCase = v;
                    _updateResults();
                  }),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text(
                    'مراعاة التشكيل',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11),
                  ),
                  selected: _tashkeelAware,
                  onSelected: (v) => setState(() {
                    _tashkeelAware = v;
                    _updateResults();
                  }),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Results count
            Text(
              '$_resultCount نتيجة - $_currentIndex الحالي',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _findPrevious,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A2E),
                      side: BorderSide(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Text(
                      'السابق',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _findNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE5B143),
                      foregroundColor: const Color(0xFF1A1A2E),
                    ),
                    child: const Text(
                      'التالي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _replace,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A2E),
                      side: BorderSide(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Text(
                      'استبدال',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _replaceAll,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A2E),
                      side: BorderSide(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Text(
                      'استبدال الكل',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateResults() {
    final query = _findController.text;
    if (query.isEmpty) {
      setState(() {
        _resultCount = 0;
        _currentIndex = 0;
      });
      return;
    }
    setState(() {
      _resultCount = query.length; // Stub: real count from document engine
      _currentIndex = _resultCount > 0 ? 1 : 0;
    });
  }

  void _findNext() {
    if (_resultCount == 0) return;
    setState(() {
      _currentIndex = (_currentIndex % _resultCount) + 1;
    });
  }

  void _findPrevious() {
    if (_resultCount == 0) return;
    setState(() {
      _currentIndex =
          _currentIndex <= 1 ? _resultCount : _currentIndex - 1;
    });
  }

  void _replace() {}

  void _replaceAll() {}
}
