import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'dart:typed_data';
import 'dart:io';

enum SvgSourceType {
  asset,
  network,
  file,
  memory,
  string,
  custom,
}

class SvgIcon extends StatelessWidget {
  const SvgIcon._({
    super.key,
    required this.sourceType,
    this.assetName,
    this.url,
    this.file,
    this.bytes,
    this.loader,
    this.size,
    this.fill,
    this.weight,
    this.grade,
    this.opticalSize,
    this.color,
    this.shadows,
    this.semanticLabel,
    this.textDirection,
    this.applyTextScaling,
    this.blendMode,
    this.headers,
  }) : assert(fill == null || (0.0 <= fill && fill <= 1.0));

  /// 默认构造函数，直接使用自定义 BytesLoader（等同于 SvgPicture 的用法）
  const SvgIcon(
      this.loader, {
        super.key,
        this.size,
        this.fill,
        this.weight,
        this.grade,
        this.opticalSize,
        this.color,
        this.shadows,
        this.semanticLabel,
        this.textDirection,
        this.applyTextScaling,
        this.blendMode,
      }) : sourceType = SvgSourceType.custom,
        assetName = null,
        url = null,
        file = null,
        bytes = null,
        headers = null;

  // 其他构造函数（略有删减以便聚焦）
  factory SvgIcon.asset(
      String assetName, {
        Key? key,
        double? size,
        double? fill,
        double? weight,
        double? grade,
        double? opticalSize,
        Color? color,
        List<Shadow>? shadows,
        String? semanticLabel,
        TextDirection? textDirection,
        bool? applyTextScaling,
        BlendMode? blendMode,
      }) =>
      SvgIcon._(
        key: key,
        sourceType: SvgSourceType.asset,
        assetName: assetName,
        size: size,
        fill: fill,
        weight: weight,
        grade: grade,
        opticalSize: opticalSize,
        color: color,
        shadows: shadows,
        semanticLabel: semanticLabel,
        textDirection: textDirection,
        applyTextScaling: applyTextScaling,
        blendMode: blendMode,
      );

  factory SvgIcon.network(
      String url, {
        Key? key,
        double? size,
        double? fill,
        double? weight,
        double? grade,
        double? opticalSize,
        Color? color,
        List<Shadow>? shadows,
        String? semanticLabel,
        TextDirection? textDirection,
        bool? applyTextScaling,
        BlendMode? blendMode,
        Map<String, String>? headers,
      }) =>
      SvgIcon._(
        key: key,
        sourceType: SvgSourceType.network,
        url: url,
        size: size,
        fill: fill,
        weight: weight,
        grade: grade,
        opticalSize: opticalSize,
        color: color,
        shadows: shadows,
        semanticLabel: semanticLabel,
        textDirection: textDirection,
        applyTextScaling: applyTextScaling,
        blendMode: blendMode,
        headers: headers,
      );

  factory SvgIcon.file(
      File file, {
        Key? key,
        double? size,
        double? fill,
        double? weight,
        double? grade,
        double? opticalSize,
        Color? color,
        List<Shadow>? shadows,
        String? semanticLabel,
        TextDirection? textDirection,
        bool? applyTextScaling,
        BlendMode? blendMode,
      }) =>
      SvgIcon._(
        key: key,
        sourceType: SvgSourceType.file,
        file: file,
        size: size,
        fill: fill,
        weight: weight,
        grade: grade,
        opticalSize: opticalSize,
        color: color,
        shadows: shadows,
        semanticLabel: semanticLabel,
        textDirection: textDirection,
        applyTextScaling: applyTextScaling,
        blendMode: blendMode,
      );

  factory SvgIcon.memory(
      Uint8List bytes, {
        Key? key,
        double? size,
        double? fill,
        double? weight,
        double? grade,
        double? opticalSize,
        Color? color,
        List<Shadow>? shadows,
        String? semanticLabel,
        TextDirection? textDirection,
        bool? applyTextScaling,
        BlendMode? blendMode,
      }) =>
      SvgIcon._(
        key: key,
        sourceType: SvgSourceType.memory,
        bytes: bytes,
        size: size,
        fill: fill,
        weight: weight,
        grade: grade,
        opticalSize: opticalSize,
        color: color,
        shadows: shadows,
        semanticLabel: semanticLabel,
        textDirection: textDirection,
        applyTextScaling: applyTextScaling,
        blendMode: blendMode,
      );

  factory SvgIcon.string(
      String svgContent, {
        Key? key,
        double? size,
        double? fill,
        double? weight,
        double? grade,
        double? opticalSize,
        Color? color,
        List<Shadow>? shadows,
        String? semanticLabel,
        TextDirection? textDirection,
        bool? applyTextScaling,
        BlendMode? blendMode,
      }) =>
      SvgIcon._(
        key: key,
        sourceType: SvgSourceType.string,
        assetName: svgContent,
        size: size,
        fill: fill,
        weight: weight,
        grade: grade,
        opticalSize: opticalSize,
        color: color,
        shadows: shadows,
        semanticLabel: semanticLabel,
        textDirection: textDirection,
        applyTextScaling: applyTextScaling,
        blendMode: blendMode,
      );

  final SvgSourceType sourceType;
  final String? assetName;
  final String? url;
  final File? file;
  final Uint8List? bytes;
  final BytesLoader? loader;

  final double? size;
  final double? fill;
  final double? weight;
  final double? grade;
  final double? opticalSize;
  final Color? color;
  final List<Shadow>? shadows;
  final String? semanticLabel;
  final TextDirection? textDirection;
  final bool? applyTextScaling;
  final BlendMode? blendMode;

  final Map<String, String>? headers;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final double iconSize = size ?? theme.size ?? 24.0;
    final double iconOpacity = theme.opacity ?? 1.0;
    final Color rawColor = color ?? theme.color ?? Theme.of(context).colorScheme.onSurface;
    final Color iconColor = rawColor.withOpacity(iconOpacity);
    final ColorFilter? colorFilter = ColorFilter.mode(iconColor, blendMode ?? BlendMode.srcIn);

    final SvgTheme svgTheme = SvgTheme(currentColor: iconColor);

    final BytesLoader resolvedLoader;
    if (sourceType == SvgSourceType.custom) {
      resolvedLoader = loader!;
    } else {
      switch (sourceType) {
        case SvgSourceType.asset:
          resolvedLoader = SvgAssetLoader(assetName!, theme: svgTheme);
          break;
        case SvgSourceType.network:
          resolvedLoader = SvgNetworkLoader(url!, headers: headers, theme: svgTheme);
          break;
        case SvgSourceType.file:
          resolvedLoader = SvgFileLoader(file!, theme: svgTheme);
          break;
        case SvgSourceType.memory:
          resolvedLoader = SvgBytesLoader(bytes!, theme: svgTheme);
          break;
        case SvgSourceType.string:
          resolvedLoader = SvgStringLoader(assetName!, theme: svgTheme);
          break;
        default:
          throw UnimplementedError('Unsupported source type');
      }
    }

    return SvgPicture(
      resolvedLoader,
      width: iconSize,
      height: iconSize,
      colorFilter: colorFilter,
      semanticsLabel: semanticLabel,
      matchTextDirection: textDirection != null,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      allowDrawingOutsideViewBox: false,
    );
  }


}
