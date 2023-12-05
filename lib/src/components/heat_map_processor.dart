import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../models/cluster_path.dart';
import '../utils/cluster_utils.dart';

class HeatMapProcessor {
  final double pointDistance;
  final double clusterScale;
  final List<Offset> offsets;
  DBSCAN _dbScan;
  int largestCluster = 1;

  final _paths = <ClusterPath>[];
  List<ClusterPath> get path => _paths;

  HeatMapProcessor({
    required this.pointDistance,
    this.clusterScale = 0.5,
    required this.offsets,
  }) : _dbScan = DBSCAN(epsilon: pointDistance * 0.7);

  Future<void> processPoints() async {
    final dbPoints = offsets.map((e) => [e.dx, e.dy]).toList();
    _dbScan = await compute<List<List<double>>, DBSCAN>(
      (List<List<double>> args) async {
        _dbScan.run(args);
        return _dbScan;
      },
      dbPoints,
    );
    _createClusterPaths();
    for (final e in _dbScan.cluster) {
      largestCluster = math.max(largestCluster, e.length);
    }

    if (largestCluster < 3) {
      largestCluster = 3;
    }
  }

  /// Creates a path for the given [layer] using a [scaleFunc]
  Path? getPathLayer(double layer) {
    var joinedPath = Path();
    final paths = _paths.where((p) => p.clusterSize / largestCluster >= layer);
    if (paths.isEmpty) {
      return null;
    }
    for (var cluster in paths) {
      var scaleInput = cluster.clusterSize - (layer * largestCluster);
      var transform = Matrix4.identity()
        ..translate(cluster.center.dx, cluster.center.dy)
        ..scale(_logBasedLevelScale(scaleInput, 1 / clusterScale))
        ..translate(-cluster.center.dx, -cluster.center.dy);
      var path = cluster.path.transform(transform.storage);
      joinedPath = Path.combine(PathOperation.union, joinedPath, path);
    }
    return joinedPath;
  }

  void _createClusterPaths() {
    final pointRadius = pointDistance;
    for (final cluster in _dbScan.cluster) {
      var clusterPath = Path();
      for (int i = 0; i < cluster.length; i++) {
        var pointPath = _eventPath(
            offsets[cluster[i]], pointRadius * (1 - (i / cluster.length)));
        clusterPath = Path.combine(PathOperation.union, clusterPath, pointPath);
      }
      _paths.add(ClusterPath(
        path: clusterPath,
        points: cluster.map((e) => offsets[e]).toList(),
      ));
    }
    ClusterPath simpleCluster(index) => ClusterPath(
          path: _eventPath(offsets[index], pointRadius),
          points: [offsets[index]],
        );
    _paths.addAll(_dbScan.noise.map(simpleCluster));
  }

  static double _logBasedLevelScale(double level, double scaleFactor) =>
      1 + math.log(level + (0.5 / scaleFactor)) / scaleFactor;

  /// Creates a [Path] from this [Event]
  Path _eventPath(Offset location, double radius) =>
      Path()..addOval(Rect.fromCircle(center: location, radius: radius));
}
