import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_state_provider.dart';
import '../widgets/image_preview.dart';
import '../widgets/controls_panel.dart';

/// Main home screen with image preview and controls
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageAdjustmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filament Spool Color Adjuster'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: state.isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading images...'),
                ],
              ),
            )
          : Row(
              children: [
                // Left side: Image preview
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ImagePreview(
                      image: state.processedImage ?? state.originalImage,
                      isLoading: state.isLoading,
                    ),
                  ),
                ),
                // Right side: Controls
                SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    child: ControlsPanel(),
                  ),
                ),
              ],
            ),
    );
  }
}
