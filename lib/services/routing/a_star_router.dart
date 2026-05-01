import 'dart:math' as math;

import 'package:ecoruta/models/geo_edge.dart';
import 'package:ecoruta/models/geo_node.dart';
import 'package:ecoruta/services/routing/route_result.dart';

enum RoutingPreference { masCorta, masRapida, masDesafiante }

class AStarRouter {
  const AStarRouter();

  // Encuentra la ruta óptima entre startId y goalId usando A*.
  // Devuelve null si no existe ningún camino conectado.
  RouteResult? findRoute({
    required List<GeoNode> nodes,
    required List<GeoEdge> edges,
    required int startId,
    required int goalId,
    RoutingPreference preference = RoutingPreference.masCorta,
  }) {
    final nodeMap = {for (final n in nodes) n.id: n};
    final startNode = nodeMap[startId];
    final goalNode = nodeMap[goalId];
    if (startNode == null || goalNode == null) return null;

    final adjacency = _buildAdjacency(edges);

    // g: costo real acumulado desde el inicio
    final gScore = <int, double>{startId: 0.0};
    // f = g + h
    final fScore = <int, double>{startId: _heuristic(startNode, goalNode)};
    final cameFrom = <int, int>{};

    final openSet = <int>{startId};
    final openList = [startId];

    while (openList.isNotEmpty) {
      openList.sort(
        (a, b) => (fScore[a] ?? double.infinity)
            .compareTo(fScore[b] ?? double.infinity),
      );
      final current = openList.removeAt(0);
      openSet.remove(current);

      if (current == goalId) {
        return _reconstructPath(cameFrom, nodeMap, current, gScore[goalId]!);
      }

      for (final edge in adjacency[current] ?? const <GeoEdge>[]) {
        final neighbor = edge.toNodeId;
        if (nodeMap[neighbor] == null) continue;

        final tentativeG =
            (gScore[current] ?? double.infinity) + _edgeCost(edge, preference);

        if (tentativeG < (gScore[neighbor] ?? double.infinity)) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeG;
          fScore[neighbor] =
              tentativeG + _heuristic(nodeMap[neighbor]!, goalNode);

          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
            openList.add(neighbor);
          }
        }
      }
    }

    return null;
  }

  // Devuelve el nodo más cercano a las coordenadas dadas dentro del
  // componente conexo más grande del grafo, evitando segmentos aislados.
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

  // Devuelve los nodos que pertenecen al componente conexo más grande.
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

  double _edgeCost(GeoEdge edge, RoutingPreference preference) {
    switch (preference) {
      case RoutingPreference.masCorta:
        // Minimiza distancia física.
        return edge.distanceMeters;

      case RoutingPreference.masRapida:
        // Penaliza terrenos lentos (escaleras, pistas sin asfaltar).
        return edge.distanceMeters * _speedFactor(edge);

      case RoutingPreference.masDesafiante:
        // Divide por dificultad: cuanto más difícil el terreno, menor el
        // costo, por lo que A* lo prefiere frente a caminos fáciles.
        return edge.distanceMeters / _difficultyFactor(edge);
    }
  }

  // Factor < 1 acelera el tramo; factor > 1 lo penaliza.
  double _speedFactor(GeoEdge edge) {
    switch (edge.tags['highway'] ?? '') {
      case 'residential':
      case 'service':
        return 0.7;
      case 'cycleway':
      case 'footway':
        return 0.9;
      case 'track':
        return 1.3;
      case 'steps':
        return 2.0;
      default:
        return 1.0;
    }
  }

  // Factor > 1 indica terreno más exigente.
  double _difficultyFactor(GeoEdge edge) {
    switch (edge.tags['highway'] ?? '') {
      case 'steps':
        return 4.0;
      case 'track':
        return 3.0;
      case 'path':
        return 2.5;
      case 'footway':
        return 1.5;
      default:
        return 1.0;
    }
  }

  double _heuristic(GeoNode from, GeoNode to) =>
      _haversine(from.latitude, from.longitude, to.latitude, to.longitude);

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
    Map<int, int> cameFrom,
    Map<int, GeoNode> nodeMap,
    int current,
    double totalDistanceMeters,
  ) {
    final path = <GeoNode>[];
    var node = current;
    while (cameFrom.containsKey(node)) {
      path.add(nodeMap[node]!);
      node = cameFrom[node]!;
    }
    path.add(nodeMap[node]!);

    // Velocidad media de senderismo: 4 km/h ≈ 1.11 m/s
    const hikingSpeedMps = 1.11;
    return RouteResult(
      path: path.reversed.toList(),
      totalDistanceMeters: totalDistanceMeters,
      estimatedDurationSeconds: (totalDistanceMeters / hikingSpeedMps).round(),
    );
  }
}
