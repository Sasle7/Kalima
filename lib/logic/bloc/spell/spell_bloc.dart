import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/spell/spell_event.dart';
import 'package:kalima/logic/bloc/spell/spell_state.dart';

class SpellBloc extends Bloc<SpellEvent, SpellState> {
  SpellBloc() : super(const SpellState()) {
    on<CheckWord>(_onCheckWord);
    on<CheckText>(_onCheckText);
    on<AddToDictionary>(_onAddToDictionary);
    on<IgnoreWord>(_onIgnoreWord);
  }

  Future<void> _onCheckWord(CheckWord event, Emitter<SpellState> emit) async {
    emit(state.copyWith(isChecking: true));

    try {
      final word = event.word.trim();
      if (word.isEmpty) {
        emit(state.copyWith(isChecking: false));
        return;
      }

      if (_isCorrectlySpelled(word) || state.ignoredWords.contains(word)) {
        emit(state.copyWith(isChecking: false));
        return;
      }

      final suggestions = await _getSpellingSuggestions(word);
      final updatedMisspelled = Map<String, List<String>>.from(state.misspelledWords)
        ..[word] = suggestions;

      emit(state.copyWith(
        misspelledWords: updatedMisspelled,
        isChecking: false,
      ));
    } catch (_) {
      emit(state.copyWith(isChecking: false));
    }
  }

  Future<void> _onCheckText(CheckText event, Emitter<SpellState> emit) async {
    emit(state.copyWith(isChecking: true));

    try {
      final words = _extractWords(event.text);
      final newMisspelled = <String, List<String>>{};

      for (final word in words) {
        if (state.ignoredWords.contains(word)) continue;
        if (newMisspelled.containsKey(word)) continue;

        if (!_isCorrectlySpelled(word)) {
          final suggestions = await _getSpellingSuggestions(word);
          newMisspelled[word] = suggestions;
        }
      }

      emit(state.copyWith(
        misspelledWords: newMisspelled,
        isChecking: false,
      ));
    } catch (_) {
      emit(state.copyWith(isChecking: false));
    }
  }

  void _onAddToDictionary(AddToDictionary event, Emitter<SpellState> emit) {
    _userDictionary.add(event.word.toLowerCase());

    final updatedMisspelled = Map<String, List<String>>.from(state.misspelledWords)
      ..remove(event.word);
    final updatedIgnored = Set<String>.from(state.ignoredWords)..add(event.word);

    emit(state.copyWith(
      misspelledWords: updatedMisspelled,
      ignoredWords: updatedIgnored,
    ));
  }

  void _onIgnoreWord(IgnoreWord event, Emitter<SpellState> emit) {
    final updatedIgnored = Set<String>.from(state.ignoredWords)..add(event.word);

    final updatedMisspelled = Map<String, List<String>>.from(state.misspelledWords)
      ..remove(event.word);

    emit(state.copyWith(
      misspelledWords: updatedMisspelled,
      ignoredWords: updatedIgnored,
    ));
  }

  List<String> _extractWords(String text) {
    final regex = RegExp(r"[\p{L}\p{M}']+", unicode: true);
    return regex.allMatches(text).map((m) => m.group(0)!.toLowerCase()).toSet().toList();
  }

  /// Check against internal Arabic/English dictionary and known word lists.
  bool _isCorrectlySpelled(String word) {
    final lower = word.toLowerCase();
    if (_userDictionary.contains(lower)) return true;
    if (_arabicCommonWords.contains(lower)) return true;
    if (_englishCommonWords.contains(lower)) return true;
    if (_arabicPrefixSuffixPatterns.any((p) => p.hasMatch(lower))) return true;
    if (RegExp(r'^[\d\s\-.,!?;:()""''\[\]{}@#\$%^&*+=/\\|~`<>]+$').hasMatch(lower)) return true;
    return false;
  }

  Future<List<String>> _getSpellingSuggestions(String word) async {
    final suggestions = <String>{};

    // Character-level edit distance (substitutions)
    for (int i = 0; i < word.length; i++) {
      for (final c in _arabicAlphabet) {
        final suggestion = word.substring(0, i) + c + word.substring(i + 1);
        if (_isCorrectlySpelled(suggestion)) suggestions.add(suggestion);
      }
    }

    // Character insertions
    for (int i = 0; i <= word.length; i++) {
      for (final c in _arabicAlphabet) {
        final suggestion = word.substring(0, i) + c + word.substring(i);
        if (_isCorrectlySpelled(suggestion)) suggestions.add(suggestion);
      }
    }

    // Character deletions
    for (int i = 0; i < word.length; i++) {
      final suggestion = word.substring(0, i) + word.substring(i + 1);
      if (_isCorrectlySpelled(suggestion)) suggestions.add(suggestion);
    }

    // Adjacent character transpositions
    for (int i = 0; i < word.length - 1; i++) {
      final chars = word.split('');
      final temp = chars[i];
      chars[i] = chars[i + 1];
      chars[i + 1] = temp;
      final suggestion = chars.join();
      if (_isCorrectlySpelled(suggestion)) suggestions.add(suggestion);
    }

    return suggestions.take(10).toList();
  }

  static final Set<String> _userDictionary = {};

  static const Set<String> _arabicCommonWords = {
    'في', 'من', 'على', 'إلى', 'عن', 'كان', 'هذا', 'هذه', 'ذلك', 'تلك',
    'مع', 'لا', 'ما', 'لم', 'لن', 'إن', 'أن', 'قد', 'لقد', 'هل',
    'و', 'ف', 'ب', 'ل', 'ك', 'أ', 'هو', 'هي', 'هم', 'هن',
    'الذي', 'التي', 'الذين', 'اللواتي', 'اللائي',
    'كانت', 'كانوا', 'كن', 'يكون', 'تكون', 'أكون',
    'قال', 'قالت', 'قالوا', 'قل', 'يقول', 'تقول',
    'ذهب', 'ذهبت', 'ذهبوا', 'يذهب', 'تذهب', 'اذهب',
    'عمل', 'عملت', 'عملوا', 'يعمل', 'تعمل', 'اعمل',
    'قرأ', 'قرأت', 'قرأوا', 'يقرأ', 'تقرأ', 'اقرأ',
    'كتب', 'كتبت', 'كتبوا', 'يكتب', 'تكتب', 'اكتب',
    'درس', 'درست', 'درسوا', 'يدرس', 'تدرس', 'ادرس',
    'فهم', 'فهمت', 'فهموا', 'يفهم', 'تفهم', 'افهم',
    'عرف', 'عرفت', 'عرفوا', 'يعرف', 'تعرف', 'اعرف',
    'أخذ', 'أخذت', 'أخذوا', 'يأخذ', 'تأخذ', 'خذ',
    'جاء', 'جاءت', 'جاءوا', 'يجيء', 'يجئ', 'تجيء', 'تعال',
    'خرج', 'خرجت', 'خرجوا', 'يخرج', 'تخرج', 'اخرج',
    'دخل', 'دخلت', 'دخلوا', 'يدخل', 'تدخل', 'ادخل',
    'جلس', 'جلست', 'جلسوا', 'يجلس', 'تجلس', 'اجلس',
    'وقف', 'وقفت', 'وقفوا', 'يقف', 'تقف', 'قف',
    'نام', 'نامت', 'ناموا', 'ينام', 'تنام', 'نم',
    'أكل', 'أكلت', 'أكلوا', 'يأكل', 'تأكل', 'كل',
    'شرب', 'شربت', 'شربوا', 'يشرب', 'تشرب', 'اشرب',
    'لعب', 'لعبت', 'لعبوا', 'يلعب', 'تلعب', 'العب',
    'سافر', 'سافرت', 'سافروا', 'يسافر', 'تسافر', 'سافر',
    'بعد', 'قبل', 'فوق', 'تحت', 'يمين', 'يسار', 'أمام', 'خلف',
    'دائماً', 'أبداً', 'أحياناً', 'نادراً', 'غالباً',
    'جداً', 'كثيراً', 'قليلاً', 'تماماً', 'تقريباً',
    'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة',
    'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة',
    'أنا', 'أنت', 'أنتِ', 'أنتم', 'أنتن', 'نحن',
    'كلمة', 'كتاب', 'قلم', 'بيت', 'مدرسة', 'جامعة',
    'ولد', 'بنت', 'رجل', 'امرأة', 'طفل', 'طفلة',
    'يوم', 'شهر', 'سنة', 'ساعة', 'دقيقة', 'ثانية',
    'صغير', 'كبير', 'طويل', 'قصير', 'جميل', 'قبيح',
    'حار', 'بارد', 'نظيف', 'وسخ', 'غني', 'فقير',
    'سريع', 'بطيء', 'قوي', 'ضعيف', 'ثقيل', 'خفيف',
    'عربي', 'إنجليزي', 'فرنسي', 'ألماني', 'صيني',
    'مصر', 'سوريا', 'العراق', 'السعودية', 'الكويت',
    'قطر', 'الإمارات', 'عمان', 'البحرين', 'اليمن',
    'الأردن', 'فلسطين', 'لبنان', 'ليبيا', 'تونس',
    'الجزائر', 'المغرب', 'السودان', 'موريتانيا', 'الصومال',
    'برنامج', 'تطبيق', 'ملف', 'مستند', 'صفحة', 'نص',
    'حفظ', 'فتح', 'إغلاق', 'طباعة', 'تصدير', 'استيراد',
    'خط', 'لون', 'حجم', 'نمط', 'تنسيق', 'محاذاة',
    'الصفحة', 'السنة', 'العدد', 'الشهر', 'اليوم', 'الوقت',
    'مرحبا', 'السلام', 'تحية', 'شكرا', 'عفوا', 'من فضلك',
    'نعم', 'لا', 'بلى', 'ربما', 'طبعا', 'بالتأكيد',
    'تفاحة', 'موز', 'برتقال', 'عنب', 'فراولة', 'بطيخ',
    'خبز', 'لحم', 'دجاج', 'سمك', 'أرز', 'حليب',
    'ماء', 'عصير', 'قهوة', 'شاي', 'حساء', 'سلطة',
    'مطبخ', 'غرفة', 'حمام', 'حديقة', 'باب', 'نافذة',
    'سيارة', 'طائرة', 'قطار', 'سفينة', 'دراجة', 'حافلة',
    'طبيب', 'مهندس', 'معلم', 'محام', 'تاجر', 'فلاح',
    'مستشفى', 'صيدلية', 'مخبر', 'عيادة', 'طوارئ',
    'الأسبوع', 'الشهر', 'العام', 'القرن', 'اليوم',
    'السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة',
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    'الربيع', 'الصيف', 'الخريف', 'الشتاء',
    'الشمال', 'الجنوب', 'الشرق', 'الغرب',
    'الدهر', 'اليوم', 'وقت', 'زمن', 'عصر', 'حقبة',
    'سماء', 'أرض', 'شمس', 'قمر', 'نجم', 'بحر',
    'جبل', 'نهر', 'وادي', 'صحراء', 'غابة', 'محيط',
  };

  static const Set<String> _englishCommonWords = {
    'the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have', 'it',
    'for', 'not', 'on', 'with', 'he', 'as', 'you', 'do', 'at', 'this',
    'but', 'his', 'by', 'from', 'they', 'we', 'say', 'her', 'she', 'or',
    'an', 'will', 'my', 'one', 'all', 'would', 'there', 'their', 'what', 'so',
    'up', 'out', 'if', 'about', 'who', 'get', 'which', 'go', 'me', 'when',
    'make', 'can', 'like', 'time', 'no', 'just', 'him', 'know', 'take', 'people',
    'into', 'year', 'your', 'good', 'some', 'could', 'them', 'see', 'other', 'than',
    'then', 'now', 'look', 'only', 'come', 'its', 'over', 'think', 'also', 'back',
    'after', 'use', 'two', 'how', 'our', 'work', 'first', 'well', 'way', 'even',
    'new', 'want', 'because', 'any', 'these', 'give', 'day', 'most', 'us',
    'is', 'are', 'was', 'were', 'been', 'has', 'had', 'does', 'did', 'being',
    'am', 'shall', 'should', 'may', 'might', 'must', 'need', 'dare',
    'text', 'word', 'document', 'file', 'open', 'save', 'close', 'edit',
    'copy', 'paste', 'cut', 'undo', 'redo', 'bold', 'italic', 'underline',
    'font', 'size', 'color', 'align', 'center', 'justify', 'spacing',
    'page', 'print', 'export', 'import', 'template', 'style', 'format',
    'arabic', 'english', 'language', 'spell', 'check', 'dictionary',
    'left', 'right', 'top', 'bottom', 'margin', 'indent', 'bullet',
    'list', 'number', 'table', 'image', 'shape', 'draw', 'insert',
    'header', 'footer', 'footnote', 'endnote', 'bookmark', 'comment',
    'review', 'track', 'change', 'accept', 'reject', 'previous', 'next',
    'view', 'zoom', 'ruler', 'grid', 'guide', 'layout', 'outline',
    'draft', 'web', 'full', 'screen', 'window', 'toolbar', 'ribbon',
    'menu', 'dialog', 'section', 'paragraph', 'line', 'column', 'break',
    'this', 'that', 'these', 'those', 'each', 'every', 'both', 'few',
    'more', 'less', 'many', 'much', 'some', 'any', 'no', 'none',
    'hello', 'world', 'example', 'test', 'sample', 'demo', 'trial',
    'apple', 'microsoft', 'google', 'android', 'linux', 'windows',
    'software', 'hardware', 'computer', 'phone', 'tablet', 'device',
    'network', 'internet', 'website', 'email', 'message', 'chat',
    'write', 'read', 'speak', 'listen', 'learn', 'teach', 'study',
    'school', 'college', 'university', 'class', 'lesson', 'course',
    'book', 'page', 'chapter', 'volume', 'edition', 'version',
    'city', 'country', 'world', 'state', 'capital', 'region',
    'north', 'south', 'east', 'west', 'center', 'middle',
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
    'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december',
    'spring', 'summer', 'autumn', 'fall', 'winter',
    'red', 'blue', 'green', 'yellow', 'black', 'white', 'gray', 'grey',
    'brown', 'orange', 'purple', 'pink', 'gold', 'silver',
    'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven',
    'eight', 'nine', 'ten', 'hundred', 'thousand', 'million', 'billion',
  };

  static const String _arabicAlphabet = 'ابتثجحخدذرزسشصضطظعغفقكلمنهويىةأإآءئؤ';

  static final List<RegExp> _arabicPrefixSuffixPatterns = [
    RegExp(r'^ال'),     // definite article prefix
    RegExp(r'^بال'),    // ب + ال
    RegExp(r'^كال'),    // ك + ال
    RegExp(r'^فل'),     // ف + ل
    RegExp(r'^وبال'),   // و + ب + ال
    RegExp(r'^فبال'),   // ف + ب + ال
    RegExp(r'ية$'),     // feminine suffix
    RegExp(r'يّ$'),     // nisba suffix
    RegExp(r'يون$'),    // masculine plural
    RegExp(r'ين$'),     // masculine plural (accusative)
    RegExp(r'ات$'),     // feminine plural
    RegExp(r'ان$'),     // dual
    RegExp(r'ون$'),     // plural suffix
    RegExp(r'كما$'),    // suffix pronoun
    RegExp(r'كم$'),     // suffix pronoun
    RegExp(r'كن$'),     // suffix pronoun
    RegExp(r'نا$'),     // suffix pronoun
    RegExp(r'ها$'),     // suffix pronoun
    RegExp(r'هم$'),     // suffix pronoun
    RegExp(r'هن$'),     // suffix pronoun
    RegExp(r'ني$'),     // suffix pronoun
    RegExp(r'ك$'),      // suffix pronoun
    RegExp(r'ه$'),      // suffix pronoun
    RegExp(r'ي$'),      // suffix pronoun (1st person)
  ];
}
