import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/cubit/ui_cubit.dart';
import 'package:kalima/ui/widgets/ribbon/home_tab.dart';
import 'package:kalima/ui/widgets/ribbon/insert_tab.dart';
import 'package:kalima/ui/widgets/ribbon/layout_tab.dart';
import 'package:kalima/ui/widgets/ribbon/review_tab.dart';

/// Main ribbon toolbar for the Kalima editor.
///
/// Displays a tabbed toolbar with Home, Insert, Layout, and Review tabs.
/// Adapts to landscape (full text labels) and portrait (icons only) orientations.
/// Fully RTL-aware with proper tab alignment.
class RibbonBar extends StatelessWidget {
  const RibbonBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocBuilder<UiCubit, UiState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab header row
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    _RibbonTab(
                      icon: Icons.home_outlined,
                      label: 'الصفحة الرئيسية',
                      isSelected: state.currentRibbonTab == RibbonTab.home,
                      showLabel: isLandscape,
                      onTap: () => context
                          .read<UiCubit>()
                          .setRibbonTab(RibbonTab.home),
                    ),
                    _RibbonTab(
                      icon: Icons.add_circle_outline,
                      label: 'إدراج',
                      isSelected: state.currentRibbonTab == RibbonTab.insert,
                      showLabel: isLandscape,
                      onTap: () => context
                          .read<UiCubit>()
                          .setRibbonTab(RibbonTab.insert),
                    ),
                    _RibbonTab(
                      icon: Icons.dashboard_outlined,
                      label: 'تخطيط',
                      isSelected: state.currentRibbonTab == RibbonTab.layout,
                      showLabel: isLandscape,
                      onTap: () => context
                          .read<UiCubit>()
                          .setRibbonTab(RibbonTab.layout),
                    ),
                    _RibbonTab(
                      icon: Icons.rate_review_outlined,
                      label: 'مراجعة',
                      isSelected: state.currentRibbonTab == RibbonTab.review,
                      showLabel: isLandscape,
                      onTap: () => context
                          .read<UiCubit>()
                          .setRibbonTab(RibbonTab.review),
                    ),
                  ],
                ),
              ),
              // Tab content
              _buildTabContent(state.currentRibbonTab),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(RibbonTab tab) {
    switch (tab) {
      case RibbonTab.home:
        return const HomeTab();
      case RibbonTab.insert:
        return const InsertTab();
      case RibbonTab.layout:
        return const LayoutTab();
      case RibbonTab.review:
        return const ReviewTab();
    }
  }
}

class _RibbonTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;

  const _RibbonTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF0860CD) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF0860CD)
                  : const Color(0xFF1A1A2E).withValues(alpha: 0.6),
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF0860CD)
                      : const Color(0xFF1A1A2E).withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
