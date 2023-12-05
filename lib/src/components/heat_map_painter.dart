import 'package:flutter/material.dart';

import 'heat_map_processor.dart';

class HeatMapPainter extends CustomPainter {
  final HeatMapProcessor heatMapProcessor;
  final double clusterScale;
  final double opacity;
  HeatMapPainter(this.heatMapProcessor, this.clusterScale, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    const layerCount = 5;
    double calcFraction(int i) => i / layerCount;
    double calcBlur(double val) => 8 - (val * 7.5);
    for (int i = 0; i <= layerCount; i++) {
      final fraction = calcFraction(i);
      final paint = Paint()
        ..color = _getSpectrumColor(fraction, alpha: opacity);
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, calcBlur(fraction));
      final path = heatMapProcessor.getPathLayer(fraction);
      if (path != null) {
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  static Color _getSpectrumColor(double value, {double alpha = 1}) {
    return HSVColor.fromAHSV(alpha, (1 - (value)) * 60, 1, 1).toColor();
  }
}
