import 'package:flutter/material.dart';

import 'components/heat_map_painter.dart';
import 'components/heat_map_processor.dart';

class HeatMapWidget extends StatefulWidget {
  const HeatMapWidget({
    super.key,
    this.loadingWidget,
    this.child,
    required this.offsetList,
    this.size,
    this.pointSize = 6,
    this.pointDistance = 10,
    this.opacity = 1,
  });
  final Widget? loadingWidget;
  final Widget? child;
  final List<Offset> offsetList;
  final Size? size;
  final double pointSize;
  final double pointDistance;
  final double opacity;

  @override
  State<HeatMapWidget> createState() => _HeatMapWidgetState();
}

class _HeatMapWidgetState extends State<HeatMapWidget> {
  bool isLoading = true;
  late final HeatMapProcessor heatMapProcessor;
  @override
  void initState() {
    heatMapProcessor = HeatMapProcessor(
        pointDistance: widget.pointDistance, offsets: widget.offsetList);
    _calculateHeatMap();
    super.initState();
  }

  Future<void> _calculateHeatMap() async {
    await heatMapProcessor.processPoints();
    isLoading = false;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant HeatMapWidget oldWidget) {
    if (widget != oldWidget) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? widget.loadingWidget ??
            const Center(child: CircularProgressIndicator())
        : CustomPaint(
            size: widget.size ?? Size.zero,
            foregroundPainter: HeatMapPainter(
                heatMapProcessor, widget.pointSize, widget.opacity),
            child: widget.child,
          );
  }
}
