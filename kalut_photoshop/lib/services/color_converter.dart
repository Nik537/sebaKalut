import 'dart:math' as math;
import 'dart:ui';

/// HSL color representation
class HSL {
  final double h; // Hue: 0-360
  final double s; // Saturation: 0-1
  final double l; // Lightness: 0-1

  const HSL(this.h, this.s, this.l);

  HSL copyWith({double? h, double? s, double? l}) {
    return HSL(h ?? this.h, s ?? this.s, l ?? this.l);
  }

  @override
  String toString() => 'HSL($h, $s, $l)';
}

/// RGB color representation
class RGB {
  final int r; // Red: 0-255
  final int g; // Green: 0-255
  final int b; // Blue: 0-255

  const RGB(this.r, this.g, this.b);

  @override
  String toString() => 'RGB($r, $g, $b)';
}

/// Tint blending modes
enum TintMode {
  hslHueReplacement,
  additive,
  multiplicative,
}

/// Color conversion and adjustment utilities
class ColorConverter {
  /// Convert RGB (0-255) to HSL (H:0-360, S:0-1, L:0-1)
  static HSL rgbToHsl(int r, int g, int b) {
    final double rd = r / 255.0;
    final double gd = g / 255.0;
    final double bd = b / 255.0;

    final double max = math.max(rd, math.max(gd, bd));
    final double min = math.min(rd, math.min(gd, bd));
    final double delta = max - min;

    double h = 0.0;
    double s = 0.0;
    final double l = (max + min) / 2.0;

    if (delta != 0) {
      s = l > 0.5 ? delta / (2.0 - max - min) : delta / (max + min);

      if (max == rd) {
        h = ((gd - bd) / delta + (gd < bd ? 6 : 0)) / 6;
      } else if (max == gd) {
        h = ((bd - rd) / delta + 2) / 6;
      } else {
        h = ((rd - gd) / delta + 4) / 6;
      }
    }

    return HSL(h * 360, s, l);
  }

  /// Convert HSL (H:0-360, S:0-1, L:0-1) to RGB (0-255)
  static RGB hslToRgb(double h, double s, double l) {
    h = h / 360.0;

    if (s == 0) {
      final int gray = (l * 255).round().clamp(0, 255);
      return RGB(gray, gray, gray);
    }

    final double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    final double p = 2 * l - q;

    final double r = _hueToRgb(p, q, h + 1 / 3);
    final double g = _hueToRgb(p, q, h);
    final double b = _hueToRgb(p, q, h - 1 / 3);

    return RGB(
      (r * 255).round().clamp(0, 255),
      (g * 255).round().clamp(0, 255),
      (b * 255).round().clamp(0, 255),
    );
  }

  /// Helper function for HSL to RGB conversion
  static double _hueToRgb(double p, double q, double t) {
    double tc = t;
    if (tc < 0) tc += 1;
    if (tc > 1) tc -= 1;
    if (tc < 1 / 6) return p + (q - p) * 6 * tc;
    if (tc < 1 / 2) return q;
    if (tc < 2 / 3) return p + (q - p) * (2 / 3 - tc) * 6;
    return p;
  }

  /// Apply hue shift
  static double shiftHue(double currentHue, double shift) {
    final result = (currentHue + shift) % 360;
    return result < 0 ? result + 360 : result;
  }

  /// Apply saturation adjustment
  static double adjustSaturation(double currentSaturation, double multiplier) {
    return (currentSaturation * multiplier).clamp(0.0, 1.0);
  }

  /// Apply brightness adjustment to RGB
  static RGB adjustBrightness(RGB rgb, double brightness) {
    return RGB(
      (rgb.r + brightness).round().clamp(0, 255),
      (rgb.g + brightness).round().clamp(0, 255),
      (rgb.b + brightness).round().clamp(0, 255),
    );
  }

  /// Apply color tint with specified blending mode
  static RGB applyTint(
    RGB rgb,
    Color tintColor,
    double strength,
    TintMode mode,
  ) {
    if (strength <= 0) return rgb;

    switch (mode) {
      case TintMode.hslHueReplacement:
        return _applyHslHueReplacement(rgb, tintColor, strength);
      case TintMode.additive:
        return _applyAdditiveTint(rgb, tintColor, strength);
      case TintMode.multiplicative:
        return _applyMultiplicativeTint(rgb, tintColor, strength);
    }
  }

  /// HSL Hue Replacement: Replace hue with target and blend saturation
  static RGB _applyHslHueReplacement(RGB rgb, Color tintColor, double strength) {
    // Convert current color to HSL
    final hsl = rgbToHsl(rgb.r, rgb.g, rgb.b);

    // Convert tint color to HSL to get target hue and saturation
    final tintHsl = rgbToHsl(tintColor.red, tintColor.green, tintColor.blue);

    // Interpolate hue towards target
    final newHue = hsl.h + (tintHsl.h - hsl.h) * strength;

    // Also blend saturation towards tint saturation to ensure visible effect
    // on grayscale/low-saturation pixels
    final newSat = hsl.s + (tintHsl.s - hsl.s) * strength;

    // Convert back to RGB with blended hue and saturation
    return hslToRgb(newHue, newSat.clamp(0.0, 1.0), hsl.l);
  }

  /// Additive Blend: Adjust RGB channels toward target color
  static RGB _applyAdditiveTint(RGB rgb, Color tintColor, double strength) {
    return RGB(
      (rgb.r + (tintColor.red - 128) * strength).round().clamp(0, 255),
      (rgb.g + (tintColor.green - 128) * strength).round().clamp(0, 255),
      (rgb.b + (tintColor.blue - 128) * strength).round().clamp(0, 255),
    );
  }

  /// Multiplicative Tint: Multiply RGB by normalized target color
  static RGB _applyMultiplicativeTint(RGB rgb, Color tintColor, double strength) {
    final tintR = tintColor.red / 255.0;
    final tintG = tintColor.green / 255.0;
    final tintB = tintColor.blue / 255.0;

    // Blend between original and multiplied
    final blendedR = rgb.r * (1 - strength) + (rgb.r * tintR) * strength;
    final blendedG = rgb.g * (1 - strength) + (rgb.g * tintG) * strength;
    final blendedB = rgb.b * (1 - strength) + (rgb.b * tintB) * strength;

    return RGB(
      blendedR.round().clamp(0, 255),
      blendedG.round().clamp(0, 255),
      blendedB.round().clamp(0, 255),
    );
  }
}
