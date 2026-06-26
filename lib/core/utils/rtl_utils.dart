import 'package:flutter/material.dart';

class RtlUtils {
  RtlUtils._();

  // Arabic Unicode ranges
  static const int arabicStart = 0x0600;
  static const int arabicEnd = 0x06FF;
  static const int arabicSupplementStart = 0x0750;
  static const int arabicSupplementEnd = 0x077F;
  static const int arabicExtendedAStart = 0x08A0;
  static const int arabicExtendedAEnd = 0x08FF;

  // Arabic presentation forms for context analysis
  static const int arabicPresentationFormsAStart = 0xFB50;
  static const int arabicPresentationFormsAEnd = 0xFDFF;
  static const int arabicPresentationFormsBStart = 0xFE70;
  static const int arabicPresentationFormsBEnd = 0xFEFF;

  static bool isArabicScript(String text) {
    if (text.isEmpty) return false;
    for (final char in text.runes) {
      if (_isArabicChar(char)) return true;
    }
    return false;
  }

  static bool isArabicOnly(String text) {
    if (text.isEmpty) return false;
    return text.runes.every((rune) =>
        _isArabicChar(rune) || rune == 0x0020 || _isDigit(rune));
  }

  static bool _isArabicChar(int codePoint) {
    return (codePoint >= arabicStart && codePoint <= arabicEnd) ||
        (codePoint >= arabicSupplementStart &&
            codePoint <= arabicSupplementEnd) ||
        (codePoint >= arabicExtendedAStart &&
            codePoint <= arabicExtendedAEnd) ||
        (codePoint >= arabicPresentationFormsAStart &&
            codePoint <= arabicPresentationFormsAEnd) ||
        (codePoint >= arabicPresentationFormsBStart &&
            codePoint <= arabicPresentationFormsBEnd);
  }

  static bool _isDigit(int codePoint) {
    return (codePoint >= 0x0030 && codePoint <= 0x0039) ||
        (codePoint >= 0x0660 && codePoint <= 0x0669) ||
        (codePoint >= 0x06F0 && codePoint <= 0x06F9);
  }

  static bool _isLatinChar(int codePoint) {
    return (codePoint >= 0x0041 && codePoint <= 0x005A) ||
        (codePoint >= 0x0061 && codePoint <= 0x007A);
  }

  static bool isStrongRtl(String text) {
    if (text.isEmpty) return false;
    int rtlCount = 0;
    int ltrCount = 0;
    for (final rune in text.runes) {
      if (_isArabicChar(rune)) {
        rtlCount++;
      } else if (_isLatinChar(rune)) {
        ltrCount++;
      }
    }
    return rtlCount > ltrCount;
  }

  static TextDirection resolveTextDirection(String text) {
    if (text.isEmpty) return TextDirection.rtl;
    return isStrongRtl(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  static String stripTashkeel(String text) {
    return text.replaceAll(
      RegExp('[\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652\u0653\u0654\u0655]'),
      '',
    );
  }

  static bool hasTashkeel(String text) {
    return RegExp(
      '[\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652\u0653\u0654\u0655]',
    ).hasMatch(text);
  }

  static String toArabicIndicDigits(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      if (rune >= 0x0030 && rune <= 0x0039) {
        buffer.writeCharCode(0x0660 + (rune - 0x0030));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static String toWesternDigits(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.writeCharCode(0x0030 + (rune - 0x0660));
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.writeCharCode(0x0030 + (rune - 0x06F0));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static String toEasternArabicIndicDigits(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      if (rune >= 0x0030 && rune <= 0x0039) {
        buffer.writeCharCode(0x06F0 + (rune - 0x0030));
      } else if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.writeCharCode(0x06F0 + (rune - 0x0660));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static String wrapWithUnicodeControls(String text, {required bool isRtl}) {
    if (isRtl) {
      return '\u202B$text\u202C';
    }
    return '\u202A$text\u202C';
  }

  static String addRtlMark(String text) {
    return '\u200F$text';
  }

  static String addLtrMark(String text) {
    return '\u200E$text';
  }

  static String resolveBidi(String text) {
    final rtlRun = RegExp(
      '[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]+',
    );
    return text.replaceAllMapped(rtlRun, (match) {
      return '\u202B${match.group(0)}\u202C';
    });
  }

  static String truncateWithRtlAwareness(
    String text,
    int maxLength, {
    String ellipsis = '\u2026',
  }) {
    if (text.characters.length <= maxLength) return text;
    final truncated = text.characters.take(maxLength).toString();
    return '$truncated$ellipsis';
  }

  static Alignment rtlAwareAlignment(bool isRtl) {
    return isRtl ? Alignment.centerRight : Alignment.centerLeft;
  }

  static EdgeInsets rtlAwarePadding({
    required double left,
    required double right,
    double top = 0,
    double bottom = 0,
    bool isRtl = true,
  }) {
    if (isRtl) {
      return EdgeInsets.only(
        top: top,
        bottom: bottom,
        left: right,
        right: left,
      );
    }
    return EdgeInsets.only(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
  }
}
