import 'package:flutter/material.dart';

extension StringExtensions on String {
  bool get containsArabic {
    if (isEmpty) return false;
    return runes.any((rune) =>
        (rune >= 0x0600 && rune <= 0x06FF) ||
        (rune >= 0x0750 && rune <= 0x077F) ||
        (rune >= 0x08A0 && rune <= 0x08FF) ||
        (rune >= 0xFB50 && rune <= 0xFDFF) ||
        (rune >= 0xFE70 && rune <= 0xFEFF));
  }

  bool get isArabicOnly {
    if (isEmpty) return false;
    return runes.every((rune) =>
        (rune >= 0x0600 && rune <= 0x06FF) ||
        (rune >= 0x0750 && rune <= 0x077F) ||
        (rune >= 0x08A0 && rune <= 0x08FF) ||
        (rune >= 0xFB50 && rune <= 0xFDFF) ||
        (rune >= 0xFE70 && rune <= 0xFEFF) ||
        rune == 0x0020 ||
        (rune >= 0x0660 && rune <= 0x0669) ||
        (rune >= 0x06F0 && rune <= 0x06F9));
  }

  int get arabicCharCount {
    if (isEmpty) return 0;
    return runes
        .where((rune) =>
            (rune >= 0x0600 && rune <= 0x06FF) ||
            (rune >= 0x0750 && rune <= 0x077F) ||
            (rune >= 0x08A0 && rune <= 0x08FF) ||
            (rune >= 0xFB50 && rune <= 0xFDFF) ||
            (rune >= 0xFE70 && rune <= 0xFEFF))
        .length;
  }

  String truncate(int maxLength, {String ellipsis = '\u2026'}) {
    if (characters.length <= maxLength) return this;
    return '${characters.take(maxLength).toString()}$ellipsis';
  }

  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  String toCamelCase() {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_\-]+'));
    final buffer = StringBuffer(words.first.toLowerCase());
    for (int i = 1; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        buffer.write(words[i].capitalize());
      }
    }
    return buffer.toString();
  }

  String toSnakeCase() {
    if (isEmpty) return this;
    return replaceAll(RegExp(r'[A-Z]'), '_$0')
        .replaceAll(RegExp(r'[\s\-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .toLowerCase()
        .trim('_');
  }

  String titleCase() {
    if (isEmpty) return this;
    const exceptions = {
      'a', 'an', 'the', 'and', 'or', 'but',
      'in', 'on', 'at', 'to', 'for', 'of', 'by', 'with',
    };
    final words = split(' ');
    final buffer = StringBuffer();
    for (int i = 0; i < words.length; i++) {
      if (i > 0) buffer.write(' ');
      if (i == 0 ||
          i == words.length - 1 ||
          !exceptions.contains(words[i].toLowerCase())) {
        buffer.write(words[i].capitalize());
      } else {
        buffer.write(words[i].toLowerCase());
      }
    }
    return buffer.toString();
  }

  String stripTashkeel() {
    return replaceAll(
      RegExp(
          '[\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652\u0653\u0654\u0655]'),
      '',
    );
  }

  String toArabicIndicDigits() {
    final buffer = StringBuffer();
    for (final rune in runes) {
      if (rune >= 0x0030 && rune <= 0x0039) {
        buffer.writeCharCode(0x0660 + (rune - 0x0030));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  String toWesternDigits() {
    final buffer = StringBuffer();
    for (final rune in runes) {
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

  TextDirection get textDirection {
    if (isEmpty) return TextDirection.rtl;
    int rtlCount = 0;
    int ltrCount = 0;
    for (final rune in runes) {
      if ((rune >= 0x0600 && rune <= 0x06FF) ||
          (rune >= 0x0750 && rune <= 0x077F) ||
          (rune >= 0x08A0 && rune <= 0x08FF)) {
        rtlCount++;
      } else if ((rune >= 0x0041 && rune <= 0x005A) ||
          (rune >= 0x0061 && rune <= 0x007A)) {
        ltrCount++;
      }
    }
    return rtlCount >= ltrCount ? TextDirection.rtl : TextDirection.ltr;
  }
}
