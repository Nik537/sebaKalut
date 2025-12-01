import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/painting.dart';
import 'color_converter.dart';

/// Image processing parameters
class ProcessingParams {
  final img.Image sourceImage;
  final img.Image maskImage;
  final double hueShift;
  final double saturation;
  final double brightness;
  final int tintColorValue; // Color.value as int
  final double tintStrength;
  final TintMode tintMode;

  const ProcessingParams({
    required this.sourceImage,
    required this.maskImage,
    required this.hueShift,
    required this.saturation,
    required this.brightness,
    required this.tintColorValue,
    required this.tintStrength,
    required this.tintMode,
  });
}

/// Result of image processing
class ProcessedImageResult {
  final ui.Image image;
  final Duration processingTime;

  const ProcessedImageResult(this.image, this.processingTime);
}

/// Image processing service
class ImageProcessor {
  /// Load image from assets
  static Future<ui.Image> loadAssetImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  /// Convert ui.Image to image.Image
  static Future<img.Image> uiImageToImage(ui.Image uiImage) async {
    final ByteData? byteData = await uiImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    if (byteData == null) {
      throw Exception('Failed to convert ui.Image to bytes');
    }

    return img.Image.fromBytes(
      width: uiImage.width,
      height: uiImage.height,
      bytes: byteData.buffer,
      numChannels: 4,
    );
  }

  /// Convert image.Image to ui.Image
  static Future<ui.Image> imageToUiImage(img.Image image) async {
    final pngBytes = img.encodePng(image);
    final ui.Codec codec = await ui.instantiateImageCodec(pngBytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  /// Process image with all adjustments and masking
  static Future<ProcessedImageResult> processImage({
    required ui.Image originalImage,
    required ui.Image maskImage,
    required double hueShift,
    required double saturation,
    required double brightness,
    required Color tintColor,
    required double tintStrength,
    required TintMode tintMode,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Convert ui.Image to img.Image for processing
    final sourceImg = await uiImageToImage(originalImage);
    final maskImg = await uiImageToImage(maskImage);

    // Create parameters for processing
    final params = ProcessingParams(
      sourceImage: sourceImg,
      maskImage: maskImg,
      hueShift: hueShift,
      saturation: saturation,
      brightness: brightness,
      tintColorValue: tintColor.value,
      tintStrength: tintStrength,
      tintMode: tintMode,
    );

    // Process pixels (this is CPU-intensive)
    final processedImg = _processPixels(params);

    // Convert back to ui.Image
    final resultImage = await imageToUiImage(processedImg);

    stopwatch.stop();
    return ProcessedImageResult(resultImage, stopwatch.elapsed);
  }

  /// Core pixel processing loop
  static img.Image _processPixels(ProcessingParams params) {
    final source = params.sourceImage;
    final result = img.Image.from(source);

    // Reconstruct Color from int value
    final tintColor = Color(params.tintColorValue);

    for (int y = 0; y < source.height; y++) {
      for (int x = 0; x < source.width; x++) {
        // Get source pixel
        final srcPixel = source.getPixel(x, y);
        final r = srcPixel.r.toInt();
        final g = srcPixel.g.toInt();
        final b = srcPixel.b.toInt();
        final a = srcPixel.a.toInt();

        // Convert to HSL
        var hsl = ColorConverter.rgbToHsl(r, g, b);

        // Apply hue shift
        hsl = hsl.copyWith(
          h: ColorConverter.shiftHue(hsl.h, params.hueShift),
        );

        // Apply saturation
        hsl = hsl.copyWith(
          s: ColorConverter.adjustSaturation(hsl.s, params.saturation),
        );

        // Convert back to RGB
        var rgb = ColorConverter.hslToRgb(hsl.h, hsl.s, hsl.l);

        // Apply brightness
        rgb = ColorConverter.adjustBrightness(rgb, params.brightness);

        // Apply tint
        if (params.tintStrength > 0) {
          rgb = ColorConverter.applyTint(
            rgb,
            tintColor,
            params.tintStrength,
            params.tintMode,
          );
        }

        // Set pixel with original alpha
        result.setPixelRgba(x, y, rgb.r, rgb.g, rgb.b, a);
      }
    }

    return result;
  }

  /// Export image to PNG bytes
  static Uint8List exportToPng(img.Image image) {
    return Uint8List.fromList(img.encodePng(image));
  }
}
