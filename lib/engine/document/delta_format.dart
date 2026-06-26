import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

sealed class Operation extends Equatable {
  const Operation();

  int get length;

  Map<String, dynamic> toJson();

  factory Operation.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('insert')) {
      final data = json['insert'];
      if (data is String) {
        return InsertOperation.text(
          data,
          attributes: json['attributes'] != null
              ? TextAttributes.fromJson(
                  json['attributes'] as Map<String, dynamic>)
              : null,
        );
      } else if (data is Map<String, dynamic>) {
        return InsertOperation.embed(
          data,
          attributes: json['attributes'] != null
              ? TextAttributes.fromJson(
                  json['attributes'] as Map<String, dynamic>)
              : null,
        );
      }
      throw FormatException('Unknown insert type: $data');
    } else if (json.containsKey('retain')) {
      return RetainOperation(
        json['retain'] as int,
        json['attributes'] != null
            ? TextAttributes.fromJson(
                json['attributes'] as Map<String, dynamic>)
            : null,
      );
    } else if (json.containsKey('delete')) {
      return DeleteOperation(json['delete'] as int);
    }
    throw FormatException('Unknown operation: $json');
  }
}

class InsertOperation extends Operation {
  final String text;
  final Map<String, dynamic>? embedData;
  final TextAttributes? attributes;

  const InsertOperation._({
    this.text = '',
    this.embedData,
    this.attributes,
  });

  factory InsertOperation.text(String text, {TextAttributes? attributes}) {
    return InsertOperation._(text: text, attributes: attributes);
  }

  factory InsertOperation.embed(Map<String, dynamic> data,
      {TextAttributes? attributes}) {
    return InsertOperation._(embedData: data, attributes: attributes);
  }

  bool get isText => text.isNotEmpty;
  bool get isEmbed => embedData != null;

  @override
  int get length => isText ? text.length : 1;

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (isText) {
      json['insert'] = text;
    } else {
      json['insert'] = embedData;
    }
    if (attributes != null && !attributes!.isEmpty) {
      json['attributes'] = attributes!.toJson();
    }
    return json;
  }

  InsertOperation copyWith({String? text, Map<String, dynamic>? embedData, TextAttributes? attributes}) {
    return InsertOperation._(
      text: text ?? this.text,
      embedData: embedData ?? this.embedData,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  List<Object?> get props => [text, embedData, attributes];
}

class RetainOperation extends Operation {
  final int retain;
  final TextAttributes? attributes;

  const RetainOperation(this.retain, [this.attributes]);

  @override
  int get length => retain;

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'retain': retain};
    if (attributes != null && !attributes!.isEmpty) {
      json['attributes'] = attributes!.toJson();
    }
    return json;
  }

  RetainOperation copyWith({int? retain, TextAttributes? attributes}) {
    return RetainOperation(retain ?? this.retain, attributes ?? this.attributes);
  }

  @override
  List<Object?> get props => [retain, attributes];
}

class DeleteOperation extends Operation {
  final int delete;

  const DeleteOperation(this.delete);

  @override
  int get length => delete;

  @override
  Map<String, dynamic> toJson() {
    return {'delete': delete};
  }

  @override
  List<Object?> get props => [delete];
}

class TextAttributes extends Equatable {
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool superscript;
  final bool subscript;
  final String? fontFamily;
  final double? fontSize;
  final int? color;
  final int? highlight;
  final String? link;
  final String? heading;
  final String? list;
  final int? indent;
  final TextAlignHorizontal? align;

  const TextAttributes({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.superscript = false,
    this.subscript = false,
    this.fontFamily,
    this.fontSize,
    this.color,
    this.highlight,
    this.link,
    this.heading,
    this.list,
    this.indent,
    this.align,
  });

  bool get isEmpty => this == const TextAttributes();

  bool get isHeader => heading != null && heading!.isNotEmpty;

  TextAttributes merge(TextAttributes other) {
    return TextAttributes(
      bold: other.bold,
      italic: other.italic,
      underline: other.underline,
      strikethrough: other.strikethrough,
      superscript: other.superscript,
      subscript: other.subscript,
      fontFamily: other.fontFamily ?? fontFamily,
      fontSize: other.fontSize ?? fontSize,
      color: other.color ?? color,
      highlight: other.highlight ?? highlight,
      link: other.link ?? link,
      heading: other.heading ?? heading,
      list: other.list ?? list,
      indent: other.indent ?? indent,
      align: other.align ?? align,
    );
  }

  TextAttributes diff(TextAttributes other) {
    final result = <String, dynamic>{};
    if (bold != other.bold) result['bold'] = other.bold;
    if (italic != other.italic) result['italic'] = other.italic;
    if (underline != other.underline) result['underline'] = other.underline;
    if (strikethrough != other.strikethrough) {
      result['strikethrough'] = other.strikethrough;
    }
    if (superscript != other.superscript) {
      result['superscript'] = other.superscript;
    }
    if (subscript != other.subscript) result['subscript'] = other.subscript;
    if (fontFamily != other.fontFamily && other.fontFamily != null) {
      result['fontFamily'] = other.fontFamily;
    }
    if (fontSize != other.fontSize && other.fontSize != null) {
      result['fontSize'] = other.fontSize;
    }
    if (color != other.color && other.color != null) {
      result['color'] = other.color;
    }
    if (highlight != other.highlight && other.highlight != null) {
      result['highlight'] = other.highlight;
    }
    if (link != other.link) result['link'] = other.link;
    if (heading != other.heading && other.heading != null) {
      result['heading'] = other.heading;
    }
    if (list != other.list) result['list'] = other.list;
    if (indent != other.indent && other.indent != null) {
      result['indent'] = other.indent;
    }
    if (align != other.align && other.align != null) {
      result['align'] = other.align.name;
    }
    return TextAttributes.fromJson(result);
  }

  TextAttributes removeProperties(TextAttributes other) {
    return TextAttributes(
      bold: other.bold ? false : bold,
      italic: other.italic ? false : italic,
      underline: other.underline ? false : underline,
      strikethrough: other.strikethrough ? false : strikethrough,
      superscript: other.superscript ? false : superscript,
      subscript: other.subscript ? false : subscript,
      fontFamily: other.fontFamily != null ? null : fontFamily,
      fontSize: other.fontSize != null ? null : fontSize,
      color: other.color != null ? null : color,
      highlight: other.highlight != null ? null : highlight,
      link: other.link != null ? null : link,
      heading: other.heading != null ? null : heading,
      list: other.list != null ? null : list,
      indent: other.indent != null ? null : indent,
      align: other.align != null ? null : align,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (bold) json['bold'] = true;
    if (italic) json['italic'] = true;
    if (underline) json['underline'] = true;
    if (strikethrough) json['strikethrough'] = true;
    if (superscript) json['superscript'] = true;
    if (subscript) json['subscript'] = true;
    if (fontFamily != null) json['fontFamily'] = fontFamily;
    if (fontSize != null) json['fontSize'] = fontSize;
    if (color != null) json['color'] = color;
    if (highlight != null) json['highlight'] = highlight;
    if (link != null) json['link'] = link;
    if (heading != null) json['heading'] = heading;
    if (list != null) json['list'] = list;
    if (indent != null) json['indent'] = indent;
    if (align != null) json['align'] = align!.name;
    return json;
  }

  factory TextAttributes.fromJson(Map<String, dynamic> json) {
    return TextAttributes(
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      underline: json['underline'] as bool? ?? false,
      strikethrough: json['strikethrough'] as bool? ?? false,
      superscript: json['superscript'] as bool? ?? false,
      subscript: json['subscript'] as bool? ?? false,
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      color: json['color'] as int?,
      highlight: json['highlight'] as int?,
      link: json['link'] as String?,
      heading: json['heading'] as String?,
      list: json['list'] as String?,
      indent: json['indent'] as int?,
      align: json['align'] != null
          ? TextAlignHorizontal.values.byName(json['align'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        bold,
        italic,
        underline,
        strikethrough,
        superscript,
        subscript,
        fontFamily,
        fontSize,
        color,
        highlight,
        link,
        heading,
        list,
        indent,
        align,
      ];
}

class EmbedAttributes extends Equatable {
  final String type;
  final Map<String, dynamic> data;

  const EmbedAttributes({required this.type, this.data = const {}});

  Map<String, dynamic> toJson() => {'type': type, ...data};

  factory EmbedAttributes.fromJson(Map<String, dynamic> json) {
    return EmbedAttributes(
      type: json['type'] as String? ?? '',
      data: Map<String, dynamic>.from(json)..remove('type'),
    );
  }

  @override
  List<Object?> get props => [type, data];
}

class Delta extends Equatable {
  final List<Operation> operations;

  const Delta([this.operations = const []]);

  bool get isEmpty => operations.isEmpty;
  int get length => operations.fold(0, (sum, op) => sum + op.length);

  String? get plainText {
    final buffer = StringBuffer();
    for (final op in operations) {
      if (op is InsertOperation && op.isText) {
        buffer.write(op.text);
      }
    }
    return buffer.toString();
  }

  Delta insert(String text, {TextAttributes? attributes}) {
    final op = InsertOperation.text(text, attributes: attributes);
    return Delta([...operations, op]);
  }

  Delta insertEmbed(Map<String, dynamic> data, {TextAttributes? attributes}) {
    final op = InsertOperation.embed(data, attributes: attributes);
    return Delta([...operations, op]);
  }

  Delta retain(int length, {TextAttributes? attributes}) {
    final op = RetainOperation(length, attributes);
    return Delta([...operations, op]);
  }

  Delta delete(int length) {
    final op = DeleteOperation(length);
    return Delta([...operations, op]);
  }

  Delta compose(Delta other) {
    return _compose(this, other);
  }

  Delta transform(Delta other, {bool priority = false}) {
    return _transform(this, other, priority: priority);
  }

  Delta invert(Delta base) {
    return _invert(this, base);
  }

  Delta slice(int start, [int? end]) {
    final effectiveEnd = end ?? length;
    final ops = <Operation>[];
    int offset = 0;

    for (final op in operations) {
      final opLen = op.length;
      if (offset + opLen <= start) {
        offset += opLen;
        continue;
      }
      if (offset >= effectiveEnd) break;

      final localStart = max(0, start - offset);
      final localEnd = min(opLen, effectiveEnd - offset);

      if (op is InsertOperation && op.isText) {
        final slicedText = op.text.substring(localStart, localEnd);
        ops.add(InsertOperation.text(slicedText, attributes: op.attributes));
      } else if (op is InsertOperation && op.isEmbed) {
        ops.add(InsertOperation.embed(op.embedData!, attributes: op.attributes));
      } else if (op is RetainOperation) {
        ops.add(RetainOperation(localEnd - localStart, op.attributes));
      } else if (op is DeleteOperation) {
        ops.add(DeleteOperation(localEnd - localStart));
      }

      offset += opLen;
    }

    return Delta(ops);
  }

  Delta concat(Delta other) {
    return Delta([...operations, ...other.operations]);
  }

  /// Creates a single-operation insert delta at [position] with [text].
  factory Delta.insertAt(int position, String text, {TextAttributes? attributes}) {
    if (position > 0) {
      return Delta([
        RetainOperation(position),
        InsertOperation.text(text, attributes: attributes),
      ]);
    }
    return Delta([InsertOperation.text(text, attributes: attributes)]);
  }

  /// Creates a single-operation delete delta at [position] with the given [text] length.
  factory Delta.deleteAt(int position, String deletedText) {
    if (position > 0) {
      return Delta([
        RetainOperation(position),
        DeleteOperation(deletedText.length),
      ]);
    }
    return Delta([DeleteOperation(deletedText.length)]);
  }

  Delta get reversed {
    if (operations.isEmpty) return const Delta();
    final newOps = <Operation>[];
    for (final op in operations) {
      if (op is InsertOperation) {
        newOps.add(DeleteOperation(op.length));
      } else if (op is DeleteOperation) {
        newOps.add(InsertOperation.text('[restored]'));
      } else if (op is RetainOperation) {
        newOps.add(RetainOperation(op.length, op.attributes));
      }
    }
    return Delta(newOps);
  }

  DeltaOperation? get operation {
    if (operations.isEmpty) return null;
    final first = operations.first;
    if (first is InsertOperation) return DeltaOperation.insert;
    if (first is DeleteOperation) return DeltaOperation.delete;
    if (first is RetainOperation) return DeltaOperation.retain;
    return null;
  }

  int get position {
    int pos = 0;
    for (final op in operations) {
      if (op is RetainOperation) {
        pos += op.retain;
      } else {
        break;
      }
    }
    return pos;
  }

  String? get text {
    for (final op in operations) {
      if (op is InsertOperation && op.isText) {
        return op.text;
      }
    }
    return null;
  }

  List<TextAttributes> toAttributeRuns() {
    final runs = <TextAttributes>[];
    for (final op in operations) {
      if (op is InsertOperation) {
        final attrs = op.attributes ?? const TextAttributes();
        for (int i = 0; i < op.length; i++) {
          runs.add(attrs);
        }
      }
    }
    return runs;
  }

  List<FormatRange> toFormatRanges() {
    final ranges = <FormatRange>[];
    int offset = 0;
    for (final op in operations) {
      if (op is InsertOperation) {
        ranges.add(FormatRange(
          offset: offset,
          length: op.length,
          attributes: op.attributes ?? const TextAttributes(),
        ));
      }
      offset += op.length;
    }
    return ranges;
  }

  @override
  String toString() {
    return 'Delta(${jsonEncode(toJson())})';
  }

  List<Map<String, dynamic>> toJson() {
    return operations.map((op) => op.toJson()).toList();
  }

  factory Delta.fromJson(List<dynamic> json) {
    return Delta(
      json
          .map((e) => Operation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static Delta _compose(Delta a, Delta b) {
    if (a.isEmpty) return b;
    if (b.isEmpty) return a;

    final ops = <Operation>[];
    final iterA = a.operations.iterator;
    final iterB = b.operations.iterator;
    bool hasA = iterA.moveNext();
    bool hasB = iterB.moveNext();

    Operation? currentA = hasA ? iterA.current : null;
    Operation? currentB = hasB ? iterB.current : null;

    while (currentA != null || currentB != null) {
      if (currentB is DeleteOperation) {
        ops.add(DeleteOperation(currentB.delete));
        currentB = hasB ? (iterB.moveNext() ? iterB.current : null) : null;
        if (currentB == null) hasB = false;
        if (currentA is InsertOperation) {
          currentA = hasA ? (iterA.moveNext() ? iterA.current : null) : null;
          if (currentA == null) hasA = false;
        } else {
          final len = min(currentA?.length ?? 0, currentB?.length ?? 0);
          if (currentA != null && currentA.length > len) {
            if (currentA is RetainOperation) {
              currentA = RetainOperation(currentA.length - len, currentA.attributes);
            } else {
              currentA = null;
            }
          } else {
            currentA = hasA ? (iterA.moveNext() ? iterA.current : null) : null;
            if (currentA == null) hasA = false;
          }
        }
      } else if (currentB is RetainOperation) {
        if (currentA is InsertOperation) {
          ops.add(currentA);
          currentA = hasA ? (iterA.moveNext() ? iterA.current : null) : null;
          if (currentA == null) hasA = false;
        } else {
          final len = min(currentA?.length ?? 0, currentB.length);
          if (currentA is RetainOperation && currentB.attributes != null) {
            final mergedAttrs = (currentA.attributes ?? const TextAttributes())
                .merge(currentB.attributes!);
            if (mergedAttrs.isEmpty) {
              ops.add(RetainOperation(len));
            } else {
              ops.add(RetainOperation(len, mergedAttrs));
            }
          } else {
            ops.add(RetainOperation(len, currentB.attributes));
          }

          if (currentA != null && currentA.length > len) {
            currentA = RetainOperation(
                currentA.length - len,
                (currentA as RetainOperation).attributes);
          } else {
            currentA = hasA ? (iterA.moveNext() ? iterA.current : null) : null;
            if (currentA == null) hasA = false;
          }

          if (currentB.length > len) {
            currentB = RetainOperation(currentB.length - len, currentB.attributes);
          } else {
            currentB = hasB ? (iterB.moveNext() ? iterB.current : null) : null;
            if (currentB == null) hasB = false;
          }
        }
      } else if (currentB is InsertOperation) {
        ops.add(currentB);
        currentB = hasB ? (iterB.moveNext() ? iterB.current : null) : null;
        if (currentB == null) hasB = false;
      }
    }

    return Delta(ops);
  }

  static Delta _transform(Delta a, Delta b, {bool priority = false}) {
    final ops = <Operation>[];
    final iterA = a.operations.iterator;
    final iterB = b.operations.iterator;
    bool hasA = iterA.moveNext();
    bool hasB = iterB.moveNext();

    Operation? currentA = hasA ? iterA.current : null;
    Operation? currentB = hasB ? iterB.current : null;

    while (currentA != null || currentB != null) {
      if (currentA is InsertOperation && currentB is InsertOperation) {
        if (priority) {
          ops.add(RetainOperation(currentB.length));
          currentB = hasB ? (iterB.moveNext() ? iterB.current : null) : null;
          if (currentB == null) hasB = false;
        } else {
          ops.add(InsertOperation.text(currentA.text, attributes: currentA.attributes));
          currentA = hasA ? (iterA.moveNext() ? iterA.current : null) : null;
          if (currentA == null) hasA = false;
        }
      } else if (currentB is InsertOperation) {
        ops.add(InsertOperation.text(currentB.text, attributes: currentB.attributes));
        currentB = hasB ? (iterB.moveNext() ? iterB.current : null) : null;
        if (currentB == null) hasB = false;
      } else if (currentA is InsertOperation) {
        ops.add(RetainOperation(currentA.length));
        currentA = hasA ? (iterA.moveNext() ? iterA.current : null) : null;
        if (currentA == null) hasA = false;
      } else {
        final len = min(
          currentA is DeleteOperation ? currentA.delete : (currentA?.length ?? 0),
          currentB is DeleteOperation ? currentB.delete : (currentB?.length ?? 0),
        );

        if (currentA is DeleteOperation) {
          ops.add(DeleteOperation(len));
        } else if (currentB is DeleteOperation) {
        } else if (currentA is RetainOperation && currentB is RetainOperation) {
          final mergedAttrs = currentB.attributes;
          ops.add(RetainOperation(len, mergedAttrs));
        } else if (currentA is RetainOperation) {
          if (currentB is DeleteOperation) {
          } else {
            ops.add(RetainOperation(len, (currentB as RetainOperation).attributes));
          }
        }

        _advance(currentA!, len);
        _advance(currentB!, len);

        if (currentA != null && currentA.length == 0) {
          currentA = hasA ? (iterA.moveNext() ? iterA.current : null) : null;
          if (currentA == null) hasA = false;
        }
        if (currentB != null && currentB.length == 0) {
          currentB = hasB ? (iterB.moveNext() ? iterB.current : null) : null;
          if (currentB == null) hasB = false;
        }
      }
    }

    return Delta(ops);
  }

  static void _advance(Operation op, int amount) {
    if (op is InsertOperation) {
      // Insert operations are immutable; the caller checks remaining length.
    } else if (op is RetainOperation) {
      // Retain operations are immutable; the caller checks remaining length.
    } else if (op is DeleteOperation) {
      // Delete operations are immutable; the caller checks remaining length.
    }
  }

  static Delta _invert(Delta a, Delta base) {
    final ops = <Operation>[];
    int baseIndex = 0;
    final baseOps = base.operations;

    for (final op in a.operations) {
      if (op is InsertOperation) {
        ops.add(DeleteOperation(op.length));
      } else if (op is DeleteOperation) {
        int remaining = op.delete;
        while (remaining > 0 && baseIndex < baseOps.length) {
          final baseOp = baseOps[baseIndex];
          final take = min(remaining, baseOp.length);
          if (baseOp is InsertOperation) {
            if (baseOp.isText) {
              ops.add(InsertOperation.text(
                baseOp.text.substring(0, take),
                attributes: baseOp.attributes,
              ));
            } else {
              ops.add(InsertOperation.embed(baseOp.embedData!, attributes: baseOp.attributes));
            }
          }
          remaining -= take;
          baseIndex++;
        }
      } else if (op is RetainOperation) {
        if (op.attributes != null) {
          if (baseIndex < baseOps.length) {
            final baseOp = baseOps[baseIndex];
            if (baseOp is InsertOperation) {
              final baseAttrs = baseOp.attributes ?? const TextAttributes();
              final invertedAttrs = baseAttrs.removeProperties(op.attributes!);
              ops.add(RetainOperation(op.retain, invertedAttrs));
            }
          }
        } else {
          ops.add(RetainOperation(op.retain));
        }
        baseIndex += op.retain;
      }
    }

    return Delta(ops);
  }

  @override
  List<Object?> get props => [operations];
}

class FormatRange extends Equatable {
  final int offset;
  final int length;
  final TextAttributes attributes;

  const FormatRange({
    required this.offset,
    required this.length,
    this.attributes = const TextAttributes(),
  });

  @override
  List<Object?> get props => [offset, length, attributes];
}

enum TextAlignHorizontal { left, right, center, justify }

enum DeltaOperation { insert, delete, retain }
