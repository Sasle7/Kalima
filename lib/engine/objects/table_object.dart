import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'package:kalima/engine/document/delta_format.dart';

const _uuid = Uuid();

class TableBorderSettings extends Equatable {
  final double width;
  final int color;
  final BorderStyle style;
  final bool visible;

  const TableBorderSettings({
    this.width = 0.5,
    this.color = 0xFF000000,
    this.style = BorderStyle.solid,
    this.visible = true,
  });

  static const none = TableBorderSettings(visible: false);

  TableBorderSettings copyWith({
    double? width,
    int? color,
    BorderStyle? style,
    bool? visible,
  }) {
    return TableBorderSettings(
      width: width ?? this.width,
      color: color ?? this.color,
      style: style ?? this.style,
      visible: visible ?? this.visible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'color': color,
      'style': style.name,
      'visible': visible,
    };
  }

  factory TableBorderSettings.fromJson(Map<String, dynamic> json) {
    return TableBorderSettings(
      width: (json['width'] as num?)?.toDouble() ?? 0.5,
      color: json['color'] as int? ?? 0xFF000000,
      style: json['style'] != null
          ? BorderStyle.values.byName(json['style'] as String)
          : BorderStyle.solid,
      visible: json['visible'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [width, color, style, visible];
}

enum BorderStyle { solid, dashed, dotted, double, groove, ridge, inset, outset }

class CellBorders extends Equatable {
  final TableBorderSettings top;
  final TableBorderSettings right;
  final TableBorderSettings bottom;
  final TableBorderSettings left;

  const CellBorders({
    this.top = const TableBorderSettings(),
    this.right = const TableBorderSettings(),
    this.bottom = const TableBorderSettings(),
    this.left = const TableBorderSettings(),
  });

  const CellBorders.all(TableBorderSettings settings)
      : top = settings,
        right = settings,
        bottom = settings,
        left = settings;

  const CellBorders.none()
      : top = TableBorderSettings(visible: false),
        right = TableBorderSettings(visible: false),
        bottom = TableBorderSettings(visible: false),
        left = TableBorderSettings(visible: false);

  CellBorders copyWith({
    TableBorderSettings? top,
    TableBorderSettings? right,
    TableBorderSettings? bottom,
    TableBorderSettings? left,
  }) {
    return CellBorders(
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top': top.toJson(),
      'right': right.toJson(),
      'bottom': bottom.toJson(),
      'left': left.toJson(),
    };
  }

  factory CellBorders.fromJson(Map<String, dynamic> json) {
    return CellBorders(
      top: json['top'] != null
          ? TableBorderSettings.fromJson(json['top'] as Map<String, dynamic>)
          : const TableBorderSettings(),
      right: json['right'] != null
          ? TableBorderSettings.fromJson(json['right'] as Map<String, dynamic>)
          : const TableBorderSettings(),
      bottom: json['bottom'] != null
          ? TableBorderSettings.fromJson(
              json['bottom'] as Map<String, dynamic>)
          : const TableBorderSettings(),
      left: json['left'] != null
          ? TableBorderSettings.fromJson(json['left'] as Map<String, dynamic>)
          : const TableBorderSettings(),
    );
  }

  @override
  List<Object?> get props => [top, right, bottom, left];
}

class CellPadding extends Equatable {
  final double top;
  final double right;
  final double bottom;
  final double left;

  const CellPadding({
    this.top = 4.0,
    this.right = 4.0,
    this.bottom = 4.0,
    this.left = 4.0,
  });

  CellPadding copyWith({
    double? top,
    double? right,
    double? bottom,
    double? left,
  }) {
    return CellPadding(
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top': top,
      'right': right,
      'bottom': bottom,
      'left': left,
    };
  }

  factory CellPadding.fromJson(Map<String, dynamic> json) {
    return CellPadding(
      top: (json['top'] as num?)?.toDouble() ?? 4.0,
      right: (json['right'] as num?)?.toDouble() ?? 4.0,
      bottom: (json['bottom'] as num?)?.toDouble() ?? 4.0,
      left: (json['left'] as num?)?.toDouble() ?? 4.0,
    );
  }

  @override
  List<Object?> get props => [top, right, bottom, left];
}

class TableCell extends Equatable {
  final String id;
  final Delta content;
  final int rowSpan;
  final int colSpan;
  final CellBorders borders;
  final CellPadding padding;
  final int? backgroundColor;
  final VerticalAlign verticalAlign;
  final double preferredWidth;

  const TableCell({
    String? id,
    this.content = const Delta(),
    this.rowSpan = 1,
    this.colSpan = 1,
    this.borders = const CellBorders(),
    this.padding = const CellPadding(),
    this.backgroundColor,
    this.verticalAlign = VerticalAlign.top,
    this.preferredWidth = 0.0,
  }) : id = id ?? _uuid.v4();

  TableCell copyWith({
    String? id,
    Delta? content,
    int? rowSpan,
    int? colSpan,
    CellBorders? borders,
    CellPadding? padding,
    int? backgroundColor,
    VerticalAlign? verticalAlign,
    double? preferredWidth,
  }) {
    return TableCell(
      id: id ?? this.id,
      content: content ?? this.content,
      rowSpan: rowSpan ?? this.rowSpan,
      colSpan: colSpan ?? this.colSpan,
      borders: borders ?? this.borders,
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      verticalAlign: verticalAlign ?? this.verticalAlign,
      preferredWidth: preferredWidth ?? this.preferredWidth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content.toJson(),
      'rowSpan': rowSpan,
      'colSpan': colSpan,
      'borders': borders.toJson(),
      'padding': padding.toJson(),
      'backgroundColor': backgroundColor,
      'verticalAlign': verticalAlign.name,
      'preferredWidth': preferredWidth,
    };
  }

  factory TableCell.fromJson(Map<String, dynamic> json) {
    return TableCell(
      id: json['id'] as String?,
      content: json['content'] != null
          ? Delta.fromJson(json['content'] as List<dynamic>)
          : const Delta(),
      rowSpan: json['rowSpan'] as int? ?? 1,
      colSpan: json['colSpan'] as int? ?? 1,
      borders: json['borders'] != null
          ? CellBorders.fromJson(json['borders'] as Map<String, dynamic>)
          : const CellBorders(),
      padding: json['padding'] != null
          ? CellPadding.fromJson(json['padding'] as Map<String, dynamic>)
          : const CellPadding(),
      backgroundColor: json['backgroundColor'] as int?,
      verticalAlign: json['verticalAlign'] != null
          ? VerticalAlign.values.byName(json['verticalAlign'] as String)
          : VerticalAlign.top,
      preferredWidth: (json['preferredWidth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        rowSpan,
        colSpan,
        borders,
        padding,
        backgroundColor,
        verticalAlign,
        preferredWidth,
      ];
}

enum VerticalAlign { top, middle, bottom }

class TableRow extends Equatable {
  final String id;
  final List<TableCell> cells;
  final double preferredHeight;
  final bool isHeader;

  const TableRow({
    String? id,
    this.cells = const [],
    this.preferredHeight = 0.0,
    this.isHeader = false,
  }) : id = id ?? _uuid.v4();

  int get cellCount => cells.length;

  TableRow copyWith({
    String? id,
    List<TableCell>? cells,
    double? preferredHeight,
    bool? isHeader,
  }) {
    return TableRow(
      id: id ?? this.id,
      cells: cells ?? this.cells,
      preferredHeight: preferredHeight ?? this.preferredHeight,
      isHeader: isHeader ?? this.isHeader,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cells': cells.map((c) => c.toJson()).toList(),
      'preferredHeight': preferredHeight,
      'isHeader': isHeader,
    };
  }

  factory TableRow.fromJson(Map<String, dynamic> json) {
    return TableRow(
      id: json['id'] as String?,
      cells: (json['cells'] as List<dynamic>?)
              ?.map(
                  (c) => TableCell.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      preferredHeight:
          (json['preferredHeight'] as num?)?.toDouble() ?? 0.0,
      isHeader: json['isHeader'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, cells, preferredHeight, isHeader];
}

class TableObject extends Equatable {
  final String id;
  final List<TableRow> rows;
  final int columns;
  final double totalWidth;
  final List<double> columnWidths;
  final CellBorders tableBorders;
  final bool isRtl;

  const TableObject({
    String? id,
    this.rows = const [],
    this.columns = 1,
    this.totalWidth = 500.0,
    this.columnWidths = const [],
    this.tableBorders = const CellBorders(),
    this.isRtl = true,
  })  : id = id ?? _uuid.v4(),
        assert(columns > 0, 'Table must have at least one column'),
        assert(columnWidths.isEmpty || columnWidths.length == columns,
            'Column widths must match column count');

  int get rowCount => rows.length;

  List<double> get effectiveColumnWidths {
    if (columnWidths.length == columns) {
      return columnWidths;
    }
    final equalWidth = totalWidth / columns;
    return List.filled(columns, equalWidth);
  }

  TableCell? cellAt(int row, int col) {
    if (row < 0 || row >= rows.length) return null;
    if (col < 0 || col >= columns) return null;
    final rowData = rows[row];
    if (col >= rowData.cells.length) return null;
    return rowData.cells[col];
  }

  bool hasSpanAt(int row, int col) {
    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < rows[r].cells.length; c++) {
        final cell = rows[r].cells[c];
        final endRow = r + cell.rowSpan;
        final endCol = c + cell.colSpan;
        if (row >= r && row < endRow && col >= c && col < endCol) {
          return row != r || col != c;
        }
      }
    }
    return false;
  }

  TableCell? spanningCellAt(int row, int col) {
    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < rows[r].cells.length; c++) {
        final cell = rows[r].cells[c];
        final endRow = r + cell.rowSpan;
        final endCol = c + cell.colSpan;
        if (row >= r && row < endRow && col >= c && col < endCol) {
          return cell;
        }
      }
    }
    return null;
  }

  TableObject copyWith({
    String? id,
    List<TableRow>? rows,
    int? columns,
    double? totalWidth,
    List<double>? columnWidths,
    CellBorders? tableBorders,
    bool? isRtl,
  }) {
    return TableObject(
      id: id ?? this.id,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      totalWidth: totalWidth ?? this.totalWidth,
      columnWidths: columnWidths ?? this.columnWidths,
      tableBorders: tableBorders ?? this.tableBorders,
      isRtl: isRtl ?? this.isRtl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rows': rows.map((r) => r.toJson()).toList(),
      'columns': columns,
      'totalWidth': totalWidth,
      'columnWidths': columnWidths,
      'tableBorders': tableBorders.toJson(),
      'isRtl': isRtl,
    };
  }

  factory TableObject.fromJson(Map<String, dynamic> json) {
    return TableObject(
      id: json['id'] as String?,
      rows: (json['rows'] as List<dynamic>?)
              ?.map(
                  (r) => TableRow.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      columns: json['columns'] as int? ?? 1,
      totalWidth: (json['totalWidth'] as num?)?.toDouble() ?? 500.0,
      columnWidths: (json['columnWidths'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      tableBorders: json['tableBorders'] != null
          ? CellBorders.fromJson(json['tableBorders'] as Map<String, dynamic>)
          : const CellBorders(),
      isRtl: json['isRtl'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        rows,
        columns,
        totalWidth,
        columnWidths,
        tableBorders,
        isRtl,
      ];
}
