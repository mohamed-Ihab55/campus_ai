import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum LocationCategory {
  studentAffairs,
  department,
  lab,
  doctorOffice,
}

extension LocationCategoryExtension on LocationCategory {
  String get label {
    switch (this) {
      case LocationCategory.studentAffairs:
        return 'Student Affairs';
      case LocationCategory.department:
        return 'Departments';
      case LocationCategory.lab:
        return 'Labs';
      case LocationCategory.doctorOffice:
        return 'Doctor Offices';
    }
  }
}

class CampusLocation {
  final int id;
  final String name;
  final String floor;
  final String emoji;
  final Color color;
  final LocationCategory category;
  final LatLng position;

  const CampusLocation({
    required this.id,
    required this.name,
    required this.floor,
    required this.emoji,
    required this.color,
    required this.category,
    required this.position,
  });
}
const campusCenter = LatLng(30.0260, 31.2100);

final List<CampusLocation> campusLocations = [
  CampusLocation(
    id: 1,
    name: 'Building A',
    floor: '1 - 4',
    emoji: '🏛️',
    color: AppColors.primary,
    category: LocationCategory.studentAffairs,
    position: LatLng(30.0265, 31.2098),
  ),
  CampusLocation(
    id: 2,
    name: 'Computer Science',
    floor: '2',
    emoji: '💻',
    color: AppColors.green,
    category: LocationCategory.department,
    position: LatLng(30.0258, 31.2105),
  ),
  CampusLocation(
    id: 3,
    name: 'AI Lab',
    floor: '3',
    emoji: '🤖',
    color: AppColors.amber,
    category: LocationCategory.lab,
    position: LatLng(30.0262, 31.2108),
  ),
  CampusLocation(
    id: 4,
    name: 'Doctor Office',
    floor: '1',
    emoji: '👨‍🏫',
    color: AppColors.red,
    category: LocationCategory.doctorOffice,
    position: LatLng(30.0269, 31.2102),
  ),
];
