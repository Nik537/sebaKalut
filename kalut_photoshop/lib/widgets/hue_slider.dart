import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_state_provider.dart';

/// Hue adjustment slider with rainbow gradient
class HueSlider extends ConsumerWidget {
  const HueSlider({super.key});

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
              'Hue',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '${state.hueShift.round()}°',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: Stack(
            children: [
              // Rainbow gradient background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF0000), // Red
                        Color(0xFFFFFF00), // Yellow
                        Color(0xFF00FF00), // Green
                        Color(0xFF00FFFF), // Cyan
                        Color(0xFF0000FF), // Blue
                        Color(0xFFFF00FF), // Magenta
                        Color(0xFFFF0000), // Red
                      ],
                    ),
                  ),
                ),
              ),
              // Slider
              Slider(
                value: state.hueShift,
                min: -180,
                max: 180,
                divisions: 360,
                activeColor: Colors.white.withOpacity(0.8),
                inactiveColor: Colors.transparent,
                onChanged: notifier.setHueShift,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
