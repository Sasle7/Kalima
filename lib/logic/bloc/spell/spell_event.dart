import 'package:equatable/equatable.dart';

sealed class SpellEvent extends Equatable {
  const SpellEvent();

  @override
  List<Object?> get props => [];
}

final class CheckWord extends SpellEvent {
  final String word;

  const CheckWord(this.word);

  @override
  List<Object?> get props => [word];
}

final class CheckText extends SpellEvent {
  final String text;

  const CheckText(this.text);

  @override
  List<Object?> get props => [text];
}

final class AddToDictionary extends SpellEvent {
  final String word;

  const AddToDictionary(this.word);

  @override
  List<Object?> get props => [word];
}

final class IgnoreWord extends SpellEvent {
  final String word;

  const IgnoreWord(this.word);

  @override
  List<Object?> get props => [word];
}
