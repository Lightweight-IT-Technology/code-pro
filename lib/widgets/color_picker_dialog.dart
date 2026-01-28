
import 'package:flutter/material.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;
  late double _hue;
  late double _saturation;
  late double _value;
  late double _red;
  late double _green;
  late double _blue;
  late double _alpha;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _updateColorValues();
  }

  void _updateColorValues() {
    final hslColor = HSLColor.fromColor(_selectedColor);
    _hue = hslColor.hue;
    _saturation = hslColor.saturation;
    _value = hslColor.lightness;
    _red = _selectedColor.red.toDouble();
    _green = _selectedColor.green.toDouble();
    _blue = _selectedColor.blue.toDouble();
    _alpha = _selectedColor.alpha.toDouble();
  }

  void _updateColorFromHSV() {
    setState(() {
      _selectedColor = HSLColor.fromAHSL(
        _alpha / 255,
        _hue,
        _saturation,
        _value,
      ).toColor();
      _red = _selectedColor.red.toDouble();
      _green = _selectedColor.green.toDouble();
      _blue = _selectedColor.blue.toDouble();
    });
    widget.onColorChanged(_selectedColor);
  }

  void _updateColorFromRGB() {
    setState(() {
      _selectedColor = Color.fromARGB(
        _alpha.toInt(),
        _red.toInt(),
        _green.toInt(),
        _blue.toInt(),
      );
      final hslColor = HSLColor.fromColor(_selectedColor);
      _hue = hslColor.hue;
      _saturation = hslColor.saturation;
      _value = hslColor.lightness;
    });
    widget.onColorChanged(_selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择颜色'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 颜色预览
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  'RGB: ${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue}',
                  style: TextStyle(
                    color: _selectedColor.computeLuminance() > 0.5 
                        ? Colors.black 
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 预设颜色调色板
            _buildColorPalette(),
            const SizedBox(height: 20),

            // HSV 颜色选择器
            _buildHSVControls(),
            const SizedBox(height: 20),

            // RGB 颜色选择器
            _buildRGBControls(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onColorChanged(_selectedColor);
            Navigator.of(context).pop();
          },
          child: const Text('确定'),
        ),
      ],
    );
  }

  Widget _buildColorPalette() {
    final presetColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      Colors.white,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '预设颜色',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetColors.map((color) {
            final isSelected = _selectedColor.value == color.value;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                  _updateColorValues();
                });
                widget.onColorChanged(color);
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : Border.all(color: Colors.grey.shade400),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHSVControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HSV 颜色选择',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildSlider('色相 (H)', _hue, 0, 360, (value) {
          setState(() {
            _hue = value;
            _updateColorFromHSV();
          });
        }),
        _buildSlider('饱和度 (S)', _saturation, 0, 1, (value) {
          setState(() {
            _saturation = value;
            _updateColorFromHSV();
          });
        }),
        _buildSlider('亮度 (V)', _value, 0, 1, (value) {
          setState(() {
            _value = value;
            _updateColorFromHSV();
          });
        }),
      ],
    );
  }

  Widget _buildRGBControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RGB 颜色选择',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildSlider('红色 (R)', _red, 0, 255, (value) {
          setState(() {
            _red = value;
            _updateColorFromRGB();
          });
        }),
        _buildSlider('绿色 (G)', _green, 0, 255, (value) {
          setState(() {
            _green = value;
            _updateColorFromRGB();
          });
        }),
        _buildSlider('蓝色 (B)', _blue, 0, 255, (value) {
          setState(() {
            _blue = value;
            _updateColorFromRGB();
          });
        }),
        _buildSlider('透明度 (A)', _alpha, 0, 255, (value) {
          setState(() {
            _alpha = value;
            _updateColorFromRGB();
          });
        }),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(2)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}