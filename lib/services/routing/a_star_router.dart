import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:ecoruta/models/geo_edge.dart';
import 'package:ecoruta/models/geo_node.dart';
import 'package:ecoruta/models/route_profile.dart';
import 'package:ecoruta/services/routing/route_result.dart';

enum RoutingPreference { masCorta, masRapida, masDesafiante }

class AStarRouter {
  const AStarRouter();

  RouteResult? findRoute({
    required List<GeoNode> nodes,
    required List<GeoEdge> edges,
    required int startId,
    required int goalId,
    required RouteProfile profile,
    RoutingPreference preference = RoutingPreference.masCorta,
  }) {
    final nodeMap = {for (final n in nodes) n.id: n};
    final startNode = nodeMap[startId];
    final goalNode = nodeMap[goalId];
    if (startNode == null || goalNode == null) return null;
    if (startId == goalId) {
      return RouteResult(
        path: [startNode],
        totalDistanceMeters: 0,
        estimatedDurationSeconds: 0,
      );
    }

    final adjacency = _buildAdjacency(edges);

    final gScore = <int, double>{startId: 0.0};
    final cameFromEdge = <int, GeoEdge>{};
    final closed = <int>{};

    final openSet = PriorityQueue<_AStarEntry>((a, b) => a.f.compareTo(b.f));
    openSet.add(_AStarEntry(startId, _heuristic(startNode, goalNode)));

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();

      if (closed.contains(current.id)) continue;
      closed.add(current.id);

      if (current.id == goalId) {
        return _reconstructPath(cameFromEdge, nodeMap, startId, goalId);

    final gScore = <int, double>{startId: 0.0};
    final fScore = <int, double>{
      startId: _heuristic(startNode, goalNode, profile, preference),
    };
    final cameFrom = <int, GeoEdge>{};
    final closedSet = <int>{};
    final openQueue = PriorityQueue<_AStarEntry>(
      (a, b) => a.f.compareTo(b.f),
    )..add(_AStarEntry(startId, fScore[startId]!));

    while (openQueue.isNotEmpty) {
      final currentEntry = openQueue.removeFirst();
      final current = currentEntry.id;

      if (closedSet.contains(current)) continue;
      if (currentEntry.f > (fScore[current] ?? double.infinity)) continue;
      closedSet.add(current);

      if (current == goalId) {
        return _reconstructPath(
          cameFrom,
          nodeMap,
          profile,
          current,
        );
      }

      for (final edge in adjacency[current.id] ?? const <GeoEdge>[]) {
        if (closed.contains(edge.toNodeId)) continue;
        final neighbor = edge.toNodeId;
        if (closedSet.contains(neighbor)) continue;

        final tentativeG = gScore[current.id]! + _edgeCost(edge, preference);

        if (tentativeG < (gScore[neighbor] ?? double.infinity)) {
          cameFromEdge[neighbor] = edge;
          gScore[neighbor] = tentativeG;
          openSet.add(
            _AStarEntry(
              neighbor,
              tentativeG + _heuristic(nodeMap[neighbor]!, goalNode),
            ),
          );
        final fromNode = nodeMap[current];
        final toNode = nodeMap[neighbor];
        if (fromNode == null || toNode == null) continue;

        final tentativeG = (gScore[current] ?? double.infinity) +
            _edgeSearchCost(
              edge,
              fromNode,
              toNode,
              profile,
              preference,
            );

        if (tentativeG < (gScore[neighbor] ?? double.infinity)) {
          cameFrom[neighbor] = edge;
          gScore[neighbor] = tentativeG;
          final nextF = tentativeG +
              _heuristic(toNode, goalNode, profile, preference);
          fScore[neighbor] = nextF;
          openQueue.add(_AStarEntry(neighbor, nextF));
        }
      }
    }

    return null;
  }

  GeoNode? nearestNode(
    List<GeoNode> nodes,
    List<GeoEdge> edges,
    double latitude,
    double longitude,
  ) {
    if (nodes.isEmpty) return null;

    final candidates = _mainComponentNodes(nodes, edges);
    final pool = candidates.isEmpty ? nodes : candidates;

    GeoNode nearest = pool.first;
    double minDist =
        _haversine(nearest.latitude, nearest.longitude, latitude, longitude);

    for (final node in pool.skip(1)) {
      final dist =
          _haversine(node.latitude, node.longitude, latitude, longitude);
      if (dist < minDist) {
        minDist = dist;
        nearest = node;
      }
    }

    return nearest;
  }

  List<GeoNode> nearestNodes(
    List<GeoNode> nodes,
    double latitude,
    double longitude, {
    int limit = 8,
  }) {
    if (nodes.isEmpty || limit <= 0) return const [];

    final sorted = [...nodes];
    sorted.sort(
      (a, b) => _haversine(a.latitude, a.longitude, latitude, longitude)
          .compareTo(
            _haversine(b.latitude, b.longitude, latitude, longitude),
          ),
    );
    return sorted.take(limit).toList(growable: false);
  }

  List<GeoNode> _mainComponentNodes(
    List<GeoNode> nodes,
    List<GeoEdge> edges,
  ) {
    final adj = <int, List<int>>{};
    for (final e in edges) {
      adj.putIfAbsent(e.fromNodeId, () => []).add(e.toNodeId);
    }

    final nodeIds = {for (final n in nodes) n.id};
    final visited = <int>{};
    List<int> largest = [];

    for (final seed in nodeIds) {
      if (visited.contains(seed)) continue;
      final component = <int>[];
      final stack = [seed];
      while (stack.isNotEmpty) {
        final cur = stack.removeLast();
        if (visited.contains(cur)) continue;
        visited.add(cur);
        component.add(cur);
        for (final nb in adj[cur] ?? const <int>[]) {
          if (!visited.contains(nb)) stack.add(nb);
        }
      }
      if (component.length > largest.length) largest = component;
    }

    final largestSet = largest.toSet();
    return nodes.where((n) => largestSet.contains(n.id)).toList();
  }

  Map<int, List<GeoEdge>> _buildAdjacency(List<GeoEdge> edges) {
    final map = <int, List<GeoEdge>>{};
    for (final edge in edges) {
      map.putIfAbsent(edge.fromNodeId, () => []).add(edge);
    }
    return map;
  }

  double _edgeSearchCost(
    GeoEdge edge,
    GeoNode fromNode,
    GeoNode toNode,
    RouteProfile profile,
    RoutingPreference preference,
  ) {
    switch (preference) {
      case RoutingPreference.masCorta:
        return edge.distanceMeters;
      case RoutingPreference.masRapida:
        return _edgeTravelTimeSeconds(edge, profile);
      case RoutingPreference.masDesafiante:
        final climbMeters = _positiveElevationGain(fromNode, toNode);
        final climbRewardFactor = 1 + (climbMeters / 12);
        return (edge.distanceMeters / climbRewardFactor) +
            (edge.distanceMeters * 0.15);
    }
  }

  double _edgeTravelTimeSeconds(GeoEdge edge, RouteProfile profile) {
    final baseSpeed = _baseSpeedMps(profile);
    if (baseSpeed <= 0) return double.infinity;
    return edge.distanceMeters * _terrainTimeFactor(edge, profile) / baseSpeed;
  }

  double _terrainTimeFactor(GeoEdge edge, RouteProfile profile) {
    final highway = edge.tags['highway'] ?? '';

    switch (profile) {
      case RouteProfile.cycling:
        return switch (highway) {
          'cycleway' => 0.9,
          'residential' || 'service' || 'living_street' => 1.0,
          'path' => 1.2,
          'track' => 1.35,
          'steps' => 4.0,
          _ => 1.1,
        };
      case RouteProfile.running:
        return switch (highway) {
          'footway' || 'path' => 1.0,
          'pedestrian' || 'living_street' => 0.95,
          'track' => 1.1,
          'service' || 'residential' => 1.05,
          'steps' => 1.9,
          _ => 1.1,
        };
      case RouteProfile.hiking:
        return switch (highway) {
          'path' || 'footway' => 1.0,
          'pedestrian' => 0.95,
          'track' => 1.15,
          'service' || 'residential' || 'living_street' => 1.05,
          'steps' => 1.75,
          _ => 1.1,
        };
    }
  }

  double _baseSpeedMps(RouteProfile profile) {
    switch (profile) {
      case RouteProfile.cycling:
        return 3.89;
      case RouteProfile.running:
        return 3.0;
      case RouteProfile.hiking:
        return 1.11;
    }
  }

  // Velocidad base según perfil de actividad.
  double _baseSpeedMps(RouteProfile profile) {
    switch (profile) {
      case RouteProfile.hiking:
        return 1.11; // 4 km/h
      case RouteProfile.cycling:
        return 3.89; // 14 km/h
    }
  }

  double _heuristic(GeoNode from, GeoNode to) =>
      _haversine(from.latitude, from.longitude, to.latitude, to.longitude);
=
  double _maxHeuristicSpeed(RouteProfile profile) {
    final baseSpeed = _baseSpeedMps(profile);
    final minTerrainFactor = switch (profile) {
      RouteProfile.cycling => 0.9,
      RouteProfile.running => 0.95,
      RouteProfile.hiking => 0.95,
    };
    return baseSpeed / minTerrainFactor;
  }

  double _heuristic(
    GeoNode from,
    GeoNode to,
    RouteProfile profile,
    RoutingPreference preference,
  ) {
    final distance =
        _haversine(from.latitude, from.longitude, to.latitude, to.longitude);
    switch (preference) {
      case RoutingPreference.masCorta:
        return distance;
      case RoutingPreference.masRapida:
        return distance / _maxHeuristicSpeed(profile);
      case RoutingPreference.masDesafiante:
        return 0;
    }
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _rad(double deg) => deg * math.pi / 180;

  RouteResult _reconstructPath(
    Map<int, GeoEdge> cameFromEdge,
    Map<int, GeoNode> nodeMap,
    int startId,
    int goalId,
  ) {
    final path = <GeoNode>[];
    double totalDistance = 0;
    double totalDuration = 0;

    var node = goalId;
    while (cameFromEdge.containsKey(node)) {
      path.add(nodeMap[node]!);
      final edge = cameFromEdge[node]!;
      totalDistance += edge.distanceMeters;
      // Tiempo real por tramo: distancia × factor_terreno / velocidad_base
      totalDuration +=
          edge.distanceMeters * _speedFactor(edge) / _baseSpeedMps(edge.profile);
      node = edge.fromNodeId;
    }
    path.add(nodeMap[node]!);

    return RouteResult(
      path: path.reversed.toList(),
      totalDistanceMeters: totalDistance,
      estimatedDurationSeconds: totalDuration.round(),

    Map<int, GeoEdge> cameFrom,
    Map<int, GeoNode> nodeMap,
    RouteProfile profile,
    int current,
  ) {
    final path = <GeoNode>[];
    final pathEdges = <GeoEdge>[];
    var nodeId = current;

    while (cameFrom.containsKey(nodeId)) {
      path.add(nodeMap[nodeId]!);
      final edge = cameFrom[nodeId]!;
      pathEdges.add(edge);
      nodeId = edge.fromNodeId;
    }
    path.add(nodeMap[nodeId]!);

    final orderedPath = path.reversed.toList();
    final orderedEdges = pathEdges.reversed.toList();
    var totalDistanceMeters = 0.0;
    var estimatedDurationSeconds = 0.0;
    var elevationGainMeters = 0.0;

    for (var i = 0; i < orderedEdges.length; i++) {
      final edge = orderedEdges[i];
      final fromNode = orderedPath[i];
      final toNode = orderedPath[i + 1];

      totalDistanceMeters += edge.distanceMeters;
      estimatedDurationSeconds += _edgeTravelTimeSeconds(edge, profile);
      elevationGainMeters += _positiveElevationGain(fromNode, toNode);
    }

    return RouteResult(
      path: orderedPath,
      totalDistanceMeters: totalDistanceMeters,
      estimatedDurationSeconds: estimatedDurationSeconds.round(),
      elevationGainMeters: elevationGainMeters,
    );
  }

  double _positiveElevationGain(GeoNode fromNode, GeoNode toNode) {
    final fromElevation = fromNode.elevation;
    final toElevation = toNode.elevation;
    if (fromElevation == null || toElevation == null) return 0;
    final diff = toElevation - fromElevation;
    return diff > 0 ? diff : 0;
  }
}

class _AStarEntry {
  const _AStarEntry(this.id, this.f);

  final int id;
  final double f;
}

class _AStarEntry {
  const _AStarEntry(this.id, this.f);
  final int id;
  final double f;
}
