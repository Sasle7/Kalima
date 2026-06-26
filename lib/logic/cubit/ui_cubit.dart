import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

enum SidebarType { comments, styles }

class UiState extends Equatable {
  final bool isRibbonExpanded;
  final String activeTab;
  final bool showRuler;
  final bool showSidebar;
  final SidebarType? sidebarType;
  final double zoomLevel;

  const UiState({
    this.isRibbonExpanded = true,
    this.activeTab = 'home',
    this.showRuler = true,
    this.showSidebar = false,
    this.sidebarType,
    this.zoomLevel = 1.0,
  });

  UiState copyWith({
    bool? isRibbonExpanded,
    String? activeTab,
    bool? showRuler,
    bool? showSidebar,
    SidebarType? sidebarType,
    double? zoomLevel,
    bool clearSidebar = false,
  }) {
    return UiState(
      isRibbonExpanded: isRibbonExpanded ?? this.isRibbonExpanded,
      activeTab: activeTab ?? this.activeTab,
      showRuler: showRuler ?? this.showRuler,
      showSidebar: showSidebar ?? this.showSidebar,
      sidebarType: clearSidebar ? null : (sidebarType ?? this.sidebarType),
      zoomLevel: zoomLevel ?? this.zoomLevel,
    );
  }

  @override
  List<Object?> get props => [
        isRibbonExpanded,
        activeTab,
        showRuler,
        showSidebar,
        sidebarType,
        zoomLevel,
      ];
}

class UiCubit extends Cubit<UiState> {
  UiCubit() : super(const UiState());

  void toggleRibbon() {
    emit(state.copyWith(isRibbonExpanded: !state.isRibbonExpanded));
  }

  void setRibbonExpanded(bool expanded) {
    emit(state.copyWith(isRibbonExpanded: expanded));
  }

  void switchTab(String tab) {
    final validTabs = {'home', 'insert', 'layout', 'review'};
    if (!validTabs.contains(tab)) return;
    emit(state.copyWith(activeTab: tab));
  }

  void toggleRuler() {
    emit(state.copyWith(showRuler: !state.showRuler));
  }

  void setShowRuler(bool show) {
    emit(state.copyWith(showRuler: show));
  }

  void toggleSidebar([SidebarType? type]) {
    if (type != null) {
      if (state.sidebarType == type) {
        emit(state.copyWith(showSidebar: false, clearSidebar: true));
      } else {
        emit(state.copyWith(showSidebar: true, sidebarType: type));
      }
    } else {
      emit(state.copyWith(showSidebar: !state.showSidebar));
    }
  }

  void setShowSidebar(bool show) {
    emit(state.copyWith(showSidebar: show));
  }

  void setZoom(double level) {
    final clamped = level.clamp(0.25, 4.0);
    final rounded = (clamped * 100).roundToDouble() / 100;
    emit(state.copyWith(zoomLevel: rounded));
  }

  void zoomIn() {
    final newLevel = (state.zoomLevel + 0.1).clamp(0.25, 4.0);
    final rounded = (newLevel * 100).roundToDouble() / 100;
    emit(state.copyWith(zoomLevel: rounded));
  }

  void zoomOut() {
    final newLevel = (state.zoomLevel - 0.1).clamp(0.25, 4.0);
    final rounded = (newLevel * 100).roundToDouble() / 100;
    emit(state.copyWith(zoomLevel: rounded));
  }

  void resetZoom() {
    emit(state.copyWith(zoomLevel: 1.0));
  }

  void collapseAll() {
    emit(const UiState(zoomLevel: 1.0));
  }
}
