import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum TextWrapType { inline, square, tight, through, topAndBottom, behindText, inFrontOfText }

enum ImageHorizontalAlignment { left, center, right, absolute }

enum ImageVerticalAlignment { top, middle, bottom, absolute }

class ImageSize extends Equatable {
  final double width;
  final double height;
  final bool preserveAspectRatio;

  const ImageSize({
    required this.width,
    required this.height,
    this.preserveAspectRatio = true,
  });

  double get aspectRatio => width / height;

  ImageSize scaleToFit(double maxWidth, double maxHeight) {
    if (!preserveAspectRatio) {
      return ImageSize(
        width: min(width, maxWidth),
        height: min(height, maxHeight),
        preserveAspectRatio: false,
      );
    }
    final scale = min(maxWidth / width, maxHeight / height);
    return ImageSize(
      width: width * scale,
      height: height * scale,
      preserveAspectRatio: true,
    );
  }

  ImageSize scaleToWidth(double newWidth) {
    if (!preserveAspectRatio) {
      return ImageSize(width: newWidth, height: height, preserveAspectRatio: false);
    }
    final scale = newWidth / width;
    return ImageSize(
      width: newWidth,
      height: height * scale,
      preserveAspectRatio: true,
    );
  }

  ImageSize scaleToHeight(double newHeight) {
    if (!preserveAspectRatio) {
      return ImageSize(width: width, height: newHeight, preserveAspectRatio: false);
    }
    final scale = newHeight / height;
    return ImageSize(
      width: width * scale,
      height: newHeight,
      preserveAspectRatio: true,
    );
  }

  ImageSize copyWith({double? width, double? height, bool? preserveAspectRatio}) {
    return ImageSize(
      width: width ?? this.width,
      height: height ?? this.height,
      preserveAspectRatio: preserveAspectRatio ?? this.preserveAspectRatio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'preserveAspectRatio': preserveAspectRatio,
    };
  }

  factory ImageSize.fromJson(Map<String, dynamic> json) {
    return ImageSize(
      width: (json['width'] as num?)?.toDouble() ?? 100.0,
      height: (json['height'] as num?)?.toDouble() ?? 100.0,
      preserveAspectRatio: json['preserveAspectRatio'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [width, height, preserveAspectRatio];
}

class ImageObject extends Equatable {
  final String id;
  final Uint8List? imageData;
  final String? imagePath;
  final String mimeType;
  final ImageSize size;
  final ImageSize originalSize;
  final double rotation;
  final double opacity;
  final TextWrapType textWrap;
  final ImageHorizontalAlignment horizontalAlignment;
  final ImageVerticalAlignment verticalAlignment;
  final double horizontalOffset;
  final double verticalOffset;
  final String altText;
  final bool isLocked;
  final bool isInline;

  const ImageObject({
    String? id,
    this.imageData,
    this.imagePath,
    this.mimeType = 'image/png',
    this.size = const ImageSize(width: 200, height: 200),
    this.originalSize = const ImageSize(width: 200, height: 200),
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.textWrap = TextWrapType.inline,
    this.horizontalAlignment = ImageHorizontalAlignment.left,
    this.verticalAlignment = ImageVerticalAlignment.top,
    this.horizontalOffset = 0.0,
    this.verticalOffset = 0.0,
    this.altText = '',
    this.isLocked = false,
    this.isInline = true,
  }) : id = id ?? _uuid.v4();

  bool get hasImageData => imageData != null && imageData!.isNotEmpty;

  ImageObject copyWith({
    String? id,
    Uint8List? imageData,
    String? imagePath,
    String? mimeType,
    ImageSize? size,
    ImageSize? originalSize,
    double? rotation,
    double? opacity,
    TextWrapType? textWrap,
    ImageHorizontalAlignment? horizontalAlignment,
    ImageVerticalAlignment? verticalAlignment,
    double? horizontalOffset,
    double? verticalOffset,
    String? altText,
    bool? isLocked,
    bool? isInline,
  }) {
    return ImageObject(
      id: id ?? this.id,
      imageData: imageData ?? this.imageData,
      imagePath: imagePath ?? this.imagePath,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      originalSize: originalSize ?? this.originalSize,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      textWrap: textWrap ?? this.textWrap,
      horizontalAlignment: horizontalAlignment ?? this.horizontalAlignment,
      verticalAlignment: verticalAlignment ?? this.verticalAlignment,
      horizontalOffset: horizontalOffset ?? this.horizontalOffset,
      verticalOffset: verticalOffset ?? this.verticalOffset,
      altText: altText ?? this.altText,
      isLocked: isLocked ?? this.isLocked,
      isInline: isInline ?? this.isInline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'mimeType': mimeType,
      'size': size.toJson(),
      'originalSize': originalSize.toJson(),
      'rotation': rotation,
      'opacity': opacity,
      'textWrap': textWrap.name,
      'horizontalAlignment': horizontalAlignment.name,
      'verticalAlignment': verticalAlignment.name,
      'horizontalOffset': horizontalOffset,
      'verticalOffset': verticalOffset,
      'altText': altText,
      'isLocked': isLocked,
      'isInline': isInline,
    };
  }

  factory ImageObject.fromJson(Map<String, dynamic> json) {
    return ImageObject(
      id: json['id'] as String?,
      imageData: null,
      imagePath: json['imagePath'] as String?,
      mimeType: json['mimeType'] as String? ?? 'image/png',
      size: json['size'] != null
          ? ImageSize.fromJson(json['size'] as Map<String, dynamic>)
          : const ImageSize(width: 200, height: 200),
      originalSize: json['originalSize'] != null
          ? ImageSize.fromJson(json['originalSize'] as Map<String, dynamic>)
          : const ImageSize(width: 200, height: 200),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      textWrap: json['textWrap'] != null
          ? TextWrapType.values.byName(json['textWrap'] as String)
          : TextWrapType.inline,
      horizontalAlignment: json['horizontalAlignment'] != null
          ? ImageHorizontalAlignment.values
              .byName(json['horizontalAlignment'] as String)
          : ImageHorizontalAlignment.left,
      verticalAlignment: json['verticalAlignment'] != null
          ? ImageVerticalAlignment.values
              .byName(json['verticalAlignment'] as String)
          : ImageVerticalAlignment.top,
      horizontalOffset:
          (json['horizontalOffset'] as num?)?.toDouble() ?? 0.0,
      verticalOffset:
          (json['verticalOffset'] as num?)?.toDouble() ?? 0.0,
      altText: json['altText'] as String? ?? '',
      isLocked: json['isLocked'] as bool? ?? false,
      isInline: json['isInline'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        imageData,
        imagePath,
        mimeType,
        size,
        originalSize,
        rotation,
        opacity,
        textWrap,
        horizontalAlignment,
        verticalAlignment,
        horizontalOffset,
        verticalOffset,
        altText,
        isLocked,
        isInline,
      ];
}
