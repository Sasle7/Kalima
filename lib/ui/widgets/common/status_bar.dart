import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/document/document_bloc.dart';

/// Status bar widget displayed at the bottom of the editor.
///
/// Shows page counter, word/character count, zoom level, and language indicator.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        final doc = state is DocumentLoaded ? state.document : null;
        final wordCount = doc?.stats?.wordCount ?? 0;
        final charCount = doc?.stats?.charCount ?? 0;
        final currentPage = doc?.currentPage ?? 1;
        final totalPages = doc?.totalPages ?? 1;
        final zoom = doc?.zoomLevel ?? 1.0;

        return Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              _StatusItem(
                icon: Icons.pages_outlined,
                label: 'صفحة $currentPage من $totalPages',
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.white.withValues(alpha: 0.15),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              _StatusItem(
                icon: Icons.text_fields,
                label: '$wordCount كلمة',
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.white.withValues(alpha: 0.15),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              _StatusItem(
                icon: Icons.keyboard,
                label: '$charCount حرف',
              ),
              const Spacer(),
              _StatusItem(
                icon: Icons.zoom_in,
                label: '${(zoom * 100).round()}%',
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.white.withValues(alpha: 0.15),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              _StatusItem(
                icon: Icons.language,
                label: 'AR',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
