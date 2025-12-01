import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_state_provider.dart';

/// Saturation adjustment slider with grayscale to color gradient
class SaturationSlider extends ConsumerWidget {
  const SaturationSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageAdjustmentProvider);
    final notifier = ref.read(imageAdjustmentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Saturation',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '${(state.saturation * 100).round()}%',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: Stack(
            children: [
              // Grayscale to color gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF808080), // Gray (0% saturation)
                        Color(0xFF4080C0), // Moderate color
                        Color(0xFF0080FF), // Full saturation
                        Color(0xFF0080FF), // Super saturated (200%)
                      ],
                      stops: [0.0, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
              // Slider
              Slider(
                value: state.saturation,
                min: 0.0,
                max: 2.0,
                divisions: 200,
                activeColor: Colors.white.withOpacity(0.8),
                inactiveColor: Colors.transparent,
                onChanged: notifier.setSaturation,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
