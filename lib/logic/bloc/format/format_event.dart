import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TextAlignment { right, left, center, justify }

sealed class FormatEvent extends Equatable {
  const FormatEvent();

  @override
  List<Object?> get props => [];
}

final class SetFont extends FormatEvent {
  final String fontFamily;

  const SetFont(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}

final class SetFontSize extends FormatEvent {
  final double size;

  const SetFontSize(this.size);

  @override
  List<Object?> get props => [size];
}

final class SetBold extends FormatEvent {
  final bool enabled;

  const SetBold(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

final class SetItalic extends FormatEvent {
  final bool enabled;

  const SetItalic(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

final class SetUnderline extends FormatEvent {
  final bool enabled;

  const SetUnderline(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

final class SetStrikethrough extends FormatEvent {
  final bool enabled;

  const SetStrikethrough(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

final class SetColor extends FormatEvent {
  final Color color;

  const SetColor(this.color);

  @override
  List<Object?> get props => [color];
}

final class SetHighlight extends FormatEvent {
  final Color? color;

  const SetHighlight(this.color);

  @override
  List<Object?> get props => [color];
}

final class SetAlignment extends FormatEvent {
  final TextAlignment alignment;

  const SetAlignment(this.alignment);

  @override
  List<Object?> get props => [alignment];
}

final class SetLineSpacing extends FormatEvent {
  final double spacing;

  const SetLineSpacing(this.spacing);

  @override
  List<Object?> get props => [spacing];
}

final class SetParagraphIndent extends FormatEvent {
  final double left;
  final double right;
  final double firstLine;

  const SetParagraphIndent({
    this.left = 0,
    this.right = 0,
    this.firstLine = 0,
  });

  @override
  List<Object?> get props => [left, right, firstLine];
}

final class ApplyStyle extends FormatEvent {
  final String styleName;

  const ApplyStyle(this.styleName);

  @override
  List<Object?> get props => [styleName];
}
