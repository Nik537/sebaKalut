import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/image_state_provider.dart';
import '../services/image_processor.dart';
import 'hue_slider.dart';
import 'saturation_slider.dart';
import 'brightness_slider.dart';
import 'color_picker_widget.dart';

/// Controls panel with all adjustment widgets and export button
class ControlsPanel extends ConsumerWidget {
  const ControlsPanel({super.key});

  Future<void> _exportImage(BuildContext context, WidgetRef ref) async {
    final state = ref.read(imageAdjustmentProvider);

    if (state.processedImage == null) {
      _showSnackBar(context, 'No image to export', isError: true);
      return;
    }

    try {
      // Show save file dialog
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Colored Spool Image',
        fileName: 'spool_colored.png',
        type: FileType.image,
        allowedExtensions: ['png'],
      );

      if (result == null) {
        // User cancelled
        return;
      }

      // Convert ui.Image to img.Image
      final imgImage = await ImageProcessor.uiImageToImage(
        state.processedImage!,
      );

      // Export to PNG bytes
      final pngBytes = ImageProcessor.exportToPng(imgImage);

      // Write to file
      final file = File(result);
      await file.writeAsBytes(pngBytes);

      if (context.mounted) {
        _showSnackBar(context, 'Image exported successfully to\n${file.path}');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error exporting image: $e', isError: true);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageAdjustmentProvider);
    final notifier = ref.read(imageAdjustmentProvider.notifier);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Adjustments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Hue slider
            const HueSlider(),
            const SizedBox(height: 20),
            // Saturation slider
            const SaturationSlider(),
            const SizedBox(height: 20),
            // Brightness slider
            const BrightnessSlider(),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Color picker
            const ColorPickerWidget(),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Buttons row
            Row(
              children: [
                // Reset button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isProcessing ? null : notifier.reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                // Export button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: state.isProcessing || state.processedImage == null
                        ? null
                        : () => _exportImage(context, ref),
                    icon: const Icon(Icons.save),
                    label: const Text('Export Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            // Processing indicator
            if (state.isProcessing) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Processing...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            // Error message
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  state.error!,
                  style: TextStyle(fontSize: 12, color: Colors.red[900]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
