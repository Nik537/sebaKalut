import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/image_state_provider.dart';
import '../services/color_converter.dart';

/// Color picker widget with hex input and tint mode selector
class ColorPickerWidget extends ConsumerStatefulWidget {
  const ColorPickerWidget({super.key});

  @override
  ConsumerState<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends ConsumerState<ColorPickerWidget> {
  late TextEditingController _hexController;
  bool _showPicker = false;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController();
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    final hex = color.value.toRadixString(16).padLeft(8, '0');
    // Return WITHOUT # prefix since TextField has prefixText: '#'
    return hex.substring(2).toUpperCase();
  }

  Color? _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length != 6) return null;

    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageAdjustmentProvider);
    final notifier = ref.read(imageAdjustmentProvider.notifier);

    // Update hex controller when color changes externally
    if (_hexController.text != _colorToHex(state.tintColor)) {
      _hexController.text = _colorToHex(state.tintColor);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color Tint',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Color preview button
            GestureDetector(
              onTap: () {
                setState(() => _showPicker = !_showPicker);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: state.tintColor,
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Hex input
            Expanded(
              child: TextField(
                controller: _hexController,
                decoration: InputDecoration(
                  labelText: 'Hex Code',
                  prefixText: '#',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (value) {
                  final color = _hexToColor(value);
                  if (color != null) {
                    notifier.setTintColor(color);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Strength slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Strength', style: TextStyle(fontSize: 13)),
            Text(
              '${(state.tintStrength * 100).round()}%',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        Slider(
          value: state.tintStrength,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          onChanged: notifier.setTintStrength,
        ),
        const SizedBox(height: 8),
        // Tint mode dropdown
        Row(
          children: [
            const Text('Mode:', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<TintMode>(
                value: state.tintMode,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: TintMode.hslHueReplacement,
                    child: Text('HSL Hue Replace'),
                  ),
                  DropdownMenuItem(
                    value: TintMode.additive,
                    child: Text('Additive Blend'),
                  ),
                  DropdownMenuItem(
                    value: TintMode.multiplicative,
                    child: Text('Multiplicative Tint'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    notifier.setTintMode(value);
                  }
                },
              ),
            ),
          ],
        ),
        // Color picker dialog
        if (_showPicker)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              children: [
                ColorPicker(
                  pickerColor: state.tintColor,
                  onColorChanged: notifier.setTintColor,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                  displayThumbColor: true,
                  labelTypes: const [],
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _showPicker = false);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
