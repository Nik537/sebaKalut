import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Image preview widget with aspect ratio preservation
class ImagePreview extends StatelessWidget {
  final ui.Image? image;
  final bool isLoading;

  const ImagePreview({
    super.key,
    this.image,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (image == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No image loaded',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _ImagePainter(image!),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering ui.Image
class _ImagePainter extends CustomPainter {
  final ui.Image image;

  _ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate aspect ratio preserving dimensions
    final double imageAspect = image.width / image.height;
    final double canvasAspect = size.width / size.height;

    double targetWidth, targetHeight;
    double offsetX = 0, offsetY = 0;

    if (imageAspect > canvasAspect) {
      // Image is wider than canvas
      targetWidth = size.width;
      targetHeight = size.width / imageAspect;
      offsetY = (size.height - targetHeight) / 2;
    } else {
      // Image is taller than canvas
      targetHeight = size.height;
      targetWidth = size.height * imageAspect;
      offsetX = (size.width - targetWidth) / 2;
    }

    // Draw image
    final srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final dstRect = Rect.fromLTWH(
      offsetX,
      offsetY,
      targetWidth,
      targetHeight,
    );

    canvas.drawImageRect(image, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(_ImagePainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
