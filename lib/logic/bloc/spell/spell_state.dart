import 'package:equatable/equatable.dart';

class SpellState extends Equatable {
  final Map<String, List<String>> misspelledWords;
  final bool isChecking;
  final Set<String> ignoredWords;

  const SpellState({
    this.misspelledWords = const {},
    this.isChecking = false,
    this.ignoredWords = const {},
  });

  SpellState copyWith({
    Map<String, List<String>>? misspelledWords,
    bool? isChecking,
    Set<String>? ignoredWords,
  }) {
    return SpellState(
      misspelledWords: misspelledWords ?? this.misspelledWords,
      isChecking: isChecking ?? this.isChecking,
      ignoredWords: ignoredWords ?? this.ignoredWords,
    );
  }

  List<String>? getSuggestions(String word) => misspelledWords[word];

  bool isMisspelled(String word) =>
      misspelledWords.containsKey(word) && !ignoredWords.contains(word);

  @override
  List<Object?> get props => [misspelledWords, isChecking, ignoredWords];
}
