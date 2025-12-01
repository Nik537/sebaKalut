import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_state_provider.dart';

/// Brightness adjustment slider with dark to light gradient
class BrightnessSlider extends ConsumerWidget {
  const BrightnessSlider({super.key});

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
              'Brightness',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '${state.brightness.round()}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: Stack(
            children: [
              // Dark to light gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF000000), // Dark (-150)
                        Color(0xFF808080), // Neutral (0)
                        Color(0xFFFFFFFF), // Light (+150)
                      ],
                    ),
                  ),
                ),
              ),
              // Slider
              Slider(
                value: state.brightness,
                min: -150,
                max: 150,
                divisions: 300,
                activeColor: Colors.white.withOpacity(0.8),
                inactiveColor: Colors.transparent,
                onChanged: notifier.setBrightness,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
