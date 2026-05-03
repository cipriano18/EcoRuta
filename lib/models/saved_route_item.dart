import 'package:flutter/material.dart';

class SavedRouteItem {
  const SavedRouteItem({
    required this.id,
    required this.title,
    required this.location,
    required this.distance,
    required this.elevation,
    required this.time,
    required this.icon,
    required this.activityType,
  });

  final String id;
  final String title;
  final String location;
  final String distance;
  final String elevation;
  final String time;
  final IconData icon;
  final String activityType;
}
