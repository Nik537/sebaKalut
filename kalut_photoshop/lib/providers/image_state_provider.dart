import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/image_processor.dart';
import '../services/color_converter.dart';

/// Image adjustment state
class ImageAdjustmentState {
  final ui.Image? originalImage;
  final ui.Image? maskImage;
  final ui.Image? processedImage;
  final double hueShift;
  final double saturation;
  final double brightness;
  final Color tintColor;
  final double tintStrength;
  final TintMode tintMode;
  final bool isProcessing;
  final bool isLoading;
  final String? error;

  const ImageAdjustmentState({
    this.originalImage,
    this.maskImage,
    this.processedImage,
    this.hueShift = 0.0,
    this.saturation = 1.0,
    this.brightness = 0.0,
    this.tintColor = const Color(0xFFFFFFFF), // Default to white instead of transparent
    this.tintStrength = 0.0,
    this.tintMode = TintMode.hslHueReplacement,
    this.isProcessing = false,
    this.isLoading = false,
    this.error,
  });

  ImageAdjustmentState copyWith({
    ui.Image? originalImage,
    ui.Image? maskImage,
    ui.Image? processedImage,
    double? hueShift,
    double? saturation,
    double? brightness,
    Color? tintColor,
    double? tintStrength,
    TintMode? tintMode,
    bool? isProcessing,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ImageAdjustmentState(
      originalImage: originalImage ?? this.originalImage,
      maskImage: maskImage ?? this.maskImage,
      processedImage: processedImage ?? this.processedImage,
      hueShift: hueShift ?? this.hueShift,
      saturation: saturation ?? this.saturation,
      brightness: brightness ?? this.brightness,
      tintColor: tintColor ?? this.tintColor,
      tintStrength: tintStrength ?? this.tintStrength,
      tintMode: tintMode ?? this.tintMode,
      isProcessing: isProcessing ?? this.isProcessing,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// State notifier for image adjustments
class ImageAdjustmentNotifier extends StateNotifier<ImageAdjustmentState> {
  Timer? _debounceTimer;

  ImageAdjustmentNotifier() : super(const ImageAdjustmentState()) {
    _loadImages();
  }

  /// Load images from assets
  Future<void> _loadImages() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final spool = await ImageProcessor.loadAssetImage('assets/images/Spool.png');
      final karton = await ImageProcessor.loadAssetImage('assets/images/Karton.png');

      state = state.copyWith(
        originalImage: spool,
        maskImage: karton,
        isLoading: false,
      );

      // Process initial image
      await _processImage();
    } catch (e, stack) {
      debugPrint('Error loading images: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load images: $e',
      );
    }
  }

  /// Update hue shift
  void setHueShift(double value) {
    state = state.copyWith(hueShift: value);
    _debouncedProcess();
  }

  /// Update saturation
  void setSaturation(double value) {
    state = state.copyWith(saturation: value);
    _debouncedProcess();
  }

  /// Update brightness
  void setBrightness(double value) {
    state = state.copyWith(brightness: value);
    _debouncedProcess();
  }

  /// Update tint color
  void setTintColor(Color value) {
    state = state.copyWith(tintColor: value);
    _debouncedProcess();
  }

  /// Update tint strength
  void setTintStrength(double value) {
    state = state.copyWith(tintStrength: value);
    _debouncedProcess();
  }

  /// Update tint mode
  void setTintMode(TintMode value) {
    state = state.copyWith(tintMode: value);
    _debouncedProcess();
  }

  /// Debounced processing
  void _debouncedProcess() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _processImage();
    });
  }

  /// Process image with current adjustments
  Future<void> _processImage() async {
    if (state.originalImage == null || state.maskImage == null) {
      return;
    }

    try {
      state = state.copyWith(isProcessing: true, clearError: true);

      final result = await ImageProcessor.processImage(
        originalImage: state.originalImage!,
        maskImage: state.maskImage!,
        hueShift: state.hueShift,
        saturation: state.saturation,
        brightness: state.brightness,
        tintColor: state.tintColor,
        tintStrength: state.tintStrength,
        tintMode: state.tintMode,
      );

      debugPrint('Image processed in ${result.processingTime.inMilliseconds}ms');

      state = state.copyWith(
        processedImage: result.image,
        isProcessing: false,
      );
    } catch (e, stack) {
      debugPrint('Error processing image: $e\n$stack');
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to process image: $e',
      );
    }
  }

  /// Reset all adjustments to default
  void reset() {
    state = ImageAdjustmentState(
      originalImage: state.originalImage,
      maskImage: state.maskImage,
    );
    _processImage();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for image adjustment state
final imageAdjustmentProvider =
    StateNotifierProvider<ImageAdjustmentNotifier, ImageAdjustmentState>((ref) {
  return ImageAdjustmentNotifier();
});
