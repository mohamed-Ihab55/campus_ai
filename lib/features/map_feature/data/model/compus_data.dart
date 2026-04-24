import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum LocationCategory { admin, dept, lab, service }

extension LocationCategoryExt on LocationCategory {
  String get label => switch (this) {
        LocationCategory.admin => 'Administration',
        LocationCategory.dept => 'Departments',
        LocationCategory.lab => 'Labs',
        LocationCategory.service => 'Services',
      };
}

class CampusLocation {
  final int id;
  final String name;
  final String floor;
  final String emoji;
  final Color color;
  final LocationCategory category;
  final LatLng position;
  final List<String> rooms;

  const CampusLocation({
    required this.id,
    required this.name,
    required this.floor,
    required this.emoji,
    required this.color,
    required this.category,
    required this.position,
    required this.rooms,
  });
}

const campusCenter = LatLng(30.0260, 31.2100);

final campusLocations = [
  CampusLocation(
    id: 1,
    name: 'مبنى A',
    floor: '1–4',
    emoji: '🏛️',
    color: Colors.blue,
    category: LocationCategory.admin,
    position: LatLng(30.0265, 31.2098),
    rooms: ['Dean Office', 'Registration'],
  ),
];