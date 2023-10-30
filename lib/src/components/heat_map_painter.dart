import 'package:flutter/material.dart';

import 'heat_map_processor.dart';

class HeatMapPainter extends CustomPainter {
  final HeatMapProcessor heatMapProcessor;
  final double clusterScale;
  final double opacity;
  HeatMapPainter(this.heatMapProcessor, this.clusterScale, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final layerCount = heatMapProcessor.largestCluster > 10
        ? heatMapProcessor.largestCluster
        : 10;
    double calcFraction(int i) => i > 1 ? (i - 1) / layerCount : 0;
    double calcBlur(double val) => (4 * val * val + 2) * clusterScale / 8;
    for (int i = 1; i < layerCount; i++) {
      final fraction = calcFraction(i);
      final paint = Paint()
        ..color = _getSpectrumColor(fraction, alpha: opacity);
      paint.maskFilter =
          MaskFilter.blur(BlurStyle.normal, calcBlur(1 - fraction));

      canvas.drawPath(heatMapProcessor.getPathLayer(fraction), paint);
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
