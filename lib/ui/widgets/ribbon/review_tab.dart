import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kalima/logic/bloc/document/document_bloc.dart';
import 'package:kalima/logic/bloc/document/document_state.dart';
import 'package:kalima/logic/cubit/ui_cubit.dart';

/// Review tab content within the ribbon toolbar.
///
/// Provides spell check toggle, track changes, comments panel toggle,
/// accept/reject changes, and navigation through tracked changes.
class ReviewTab extends StatelessWidget {
  const ReviewTab({super.key});

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
              _ReviewButton(
                icon: Icons.spellcheck,
                label: 'تدقيق إملائي',
                isToggle: true,
                isActive: false, // TODO: get from doc.spellCheckEnabled
                onPressed: () {
                  // TODO: ToggleSpellCheck
                },
              ),
              _Separator(),
              _ReviewButton(
                icon: Icons.track_changes,
                label: 'تتبع التغييرات',
                isToggle: true,
                isActive: false, // TODO: get from doc.trackChanges
                onPressed: () {
                  // TODO: ToggleTrackChanges
                },
              ),
              _Separator(),
              _ReviewButton(
                icon: Icons.comment_outlined,
                label: 'تعليقات',
                isToggle: true,
                isActive: context.read<UiCubit>().state.showSidebar, // TODO: was doc?.showComments
                onPressed: () => context
                    .read<UiCubit>()
                    .toggleSidebar(SidebarType.comments),
              ),
              _Separator(),
              _ReviewButton(
                icon: Icons.check_circle_outline,
                label: 'قبول',
                onPressed: () {
                  // TODO: AcceptChange
                },
              ),
              _ReviewButton(
                icon: Icons.cancel_outlined,
                label: 'رفض',
                onPressed: () {
                  // TODO: RejectChange
                },
              ),
              _Separator(),
              _ReviewButton(
                icon: Icons.navigate_before,
                label: 'سابق',
                onPressed: () {
                  // TODO: PreviousChange
                },
              ),
              _ReviewButton(
                icon: Icons.navigate_next,
                label: 'تالي',
                onPressed: () {
                  // TODO: NextChange
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isToggle;
  final bool isActive;
  final VoidCallback onPressed;

  const _ReviewButton({
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
