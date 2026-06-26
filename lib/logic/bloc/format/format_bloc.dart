import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/format/format_event.dart';
import 'package:kalima/logic/bloc/format/format_state.dart';
import 'package:kalima/logic/bloc/editor/editor_bloc.dart';

class FormatBloc extends Bloc<FormatEvent, FormatState> {
  final EditorBloc? _editorBloc;

  FormatBloc({EditorBloc? editorBloc})
      : _editorBloc = editorBloc,
        super(const FormatState()) {
    on<SetFont>(_onSetFont);
    on<SetFontSize>(_onSetFontSize);
    on<SetBold>(_onSetBold);
    on<SetItalic>(_onSetItalic);
    on<SetUnderline>(_onSetUnderline);
    on<SetStrikethrough>(_onSetStrikethrough);
    on<SetColor>(_onSetColor);
    on<SetHighlight>(_onSetHighlight);
    on<SetAlignment>(_onSetAlignment);
    on<SetLineSpacing>(_onSetLineSpacing);
    on<SetParagraphIndent>(_onSetParagraphIndent);
    on<ApplyStyle>(_onApplyStyle);
  }

  void _onSetFont(SetFont event, Emitter<FormatState> emit) {
    emit(state.copyWith(fontFamily: event.fontFamily));
    _applyCurrentFormat();
  }

  void _onSetFontSize(SetFontSize event, Emitter<FormatState> emit) {
    emit(state.copyWith(fontSize: event.size));
    _applyCurrentFormat();
  }

  void _onSetBold(SetBold event, Emitter<FormatState> emit) {
    emit(state.copyWith(isBold: event.enabled));
    _applyCurrentFormat();
  }

  void _onSetItalic(SetItalic event, Emitter<FormatState> emit) {
    emit(state.copyWith(isItalic: event.enabled));
    _applyCurrentFormat();
  }

  void _onSetUnderline(SetUnderline event, Emitter<FormatState> emit) {
    emit(state.copyWith(isUnderline: event.enabled));
    _applyCurrentFormat();
  }

  void _onSetStrikethrough(SetStrikethrough event, Emitter<FormatState> emit) {
    emit(state.copyWith(isStrikethrough: event.enabled));
    _applyCurrentFormat();
  }

  void _onSetColor(SetColor event, Emitter<FormatState> emit) {
    emit(state.copyWith(textColor: event.color));
    _applyCurrentFormat();
  }

  void _onSetHighlight(SetHighlight event, Emitter<FormatState> emit) {
    emit(state.copyWith(
      highlightColor: event.color,
      clearHighlight: event.color == null,
    ));
    _applyCurrentFormat();
  }

  void _onSetAlignment(SetAlignment event, Emitter<FormatState> emit) {
    emit(state.copyWith(alignment: event.alignment));
    _applyCurrentFormat();
  }

  void _onSetLineSpacing(SetLineSpacing event, Emitter<FormatState> emit) {
    emit(state.copyWith(lineSpacing: event.spacing));
    _applyCurrentFormat();
  }

  void _onSetParagraphIndent(SetParagraphIndent event, Emitter<FormatState> emit) {
    emit(state.copyWith(
      indentLeft: event.left,
      indentRight: event.right,
      indentFirstLine: event.firstLine,
    ));
    _applyCurrentFormat();
  }

  void _onApplyStyle(ApplyStyle event, Emitter<FormatState> emit) {
    final style = _styles[event.styleName];
    if (style == null) {
      emit(state.copyWith(
        activeStyle: event.styleName,
        clearStyle: false,
      ));
      return;
    }

    emit(state.copyWith(
      fontFamily: style.fontFamily,
      fontSize: style.fontSize,
      isBold: style.isBold,
      isItalic: style.isItalic,
      isUnderline: style.isUnderline,
      isStrikethrough: style.isStrikethrough,
      alignment: style.alignment,
      lineSpacing: style.lineSpacing,
      activeStyle: event.styleName,
    ));
    _applyCurrentFormat();
  }

  void _applyCurrentFormat() {
    _editorBloc?.applyFormatToSelection(state.attributes);
  }

  void clearFormatting() {
    emit(const FormatState());
  }
}

class _StyleDefinition {
  final String fontFamily;
  final double fontSize;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrikethrough;
  final TextAlignment alignment;
  final double lineSpacing;

  const _StyleDefinition({
    this.fontFamily = 'Cairo',
    this.fontSize = 14.0,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikethrough = false,
    this.alignment = TextAlignment.right,
    this.lineSpacing = 1.5,
  });
}

final Map<String, _StyleDefinition> _styles = {
  'Normal': const _StyleDefinition(),
  'Heading 1': const _StyleDefinition(fontSize: 28.0, isBold: true, lineSpacing: 1.2),
  'Heading 2': const _StyleDefinition(fontSize: 22.0, isBold: true, lineSpacing: 1.3),
  'Heading 3': const _StyleDefinition(fontSize: 18.0, isBold: true, lineSpacing: 1.4),
  'Title': const _StyleDefinition(fontSize: 36.0, isBold: true, lineSpacing: 1.1),
  'Subtitle': const _StyleDefinition(fontSize: 20.0, lineSpacing: 1.3),
  'Quote': const _StyleDefinition(fontSize: 16.0, isItalic: true, lineSpacing: 1.6),
  'Code': const _StyleDefinition(fontFamily: 'monospace', fontSize: 13.0, lineSpacing: 1.2),
};
