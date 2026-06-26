import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/document/document_bloc.dart';

/// Main home screen for Kalima word processor.
///
/// Displays a grid of recent documents for tablet users, a "New Document"
/// button with template options, an "Open File" button, and an app bar
/// with the app name "كلمة" and a settings icon.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'كلمة',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: const Color(0xFF1A1A2E),
            tooltip: 'الإعدادات',
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildActionBar(context),
              const SizedBox(height: 8),
              Expanded(
                child: state is DocumentsLoaded && state.documents.isNotEmpty
                    ? _buildRecentDocumentsGrid(context, state)
                    : _buildEmptyState(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _showNewDocumentDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE5B143),
                foregroundColor: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'مستند جديد',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () {
              context.read<DocumentBloc>().add(const OpenFileRequested());
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A1A2E),
              side: const BorderSide(color: Color(0xFF1A1A2E)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.folder_open_outlined),
            label: const Text(
              'فتح ملف',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDocumentsGrid(BuildContext context, DocumentsLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.documents.length,
        itemBuilder: (context, index) {
          final doc = state.documents[index];
          return _DocumentCard(
            filename: doc.filename,
            lastModified: doc.lastModified,
            onTap: () {
              context.read<DocumentBloc>().add(OpenDocument(doc.id));
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE5B143).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                size: 100,
                color: Color(0xFFE5B143),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'مرحباً بك في كلمة',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ابدأ بإنشاء مستند جديد أو افتح ملفاً موجوداً',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showNewDocumentDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE5B143),
                foregroundColor: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'إنشاء أول مستند',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewDocumentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مستند جديد',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 20),
              _TemplateOption(
                icon: Icons.description_outlined,
                label: 'مستند فارغ',
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<DocumentBloc>().add(const CreateNewDocument());
                },
              ),
              const Divider(height: 1),
              _TemplateOption(
                icon: Icons.article_outlined,
                label: 'تقرير',
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<DocumentBloc>().add(const CreateFromTemplate('report'));
                },
              ),
              const Divider(height: 1),
              _TemplateOption(
                icon: Icons.email_outlined,
                label: 'رسالة',
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<DocumentBloc>().add(const CreateFromTemplate('letter'));
                },
              ),
              const Divider(height: 1),
              _TemplateOption(
                icon: Icons.menu_book_outlined,
                label: 'سيرة ذاتية',
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<DocumentBloc>().add(const CreateFromTemplate('resume'));
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String filename;
  final DateTime lastModified;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.filename,
    required this.lastModified,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filename,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(lastModified),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقائق';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعات';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TemplateOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TemplateOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1A1A2E)),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
