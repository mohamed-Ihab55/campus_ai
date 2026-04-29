import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum LocationCategory { studentAffairs, dept, lab, doctorOffice }

extension LocationCategoryExt on LocationCategory {
  String get label => switch (this) {
    LocationCategory.doctorOffice => 'Doctor\'s Office',
    LocationCategory.studentAffairs => 'Student Affairs',
    LocationCategory.dept => 'Departments',
    LocationCategory.lab => 'Labs',
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
    color: AppColors.primary,
    category: LocationCategory.studentAffairs,
    position: LatLng(30.0265, 31.2098),
    rooms: ['Dean Office', 'Registration'],
  ),
];
