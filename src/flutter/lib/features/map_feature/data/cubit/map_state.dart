import 'package:campus_ai/features/map_feature/data/model/campus_data.dart';
import 'package:latlong2/latlong.dart';

class MapState {
  final List<CampusLocation> locations;
  final CampusLocation? selected;
  final LocationCategory? filter;
  final String search;
  final LatLng? userLocation;
  final String? error;

  const MapState({
    required this.locations,
    this.selected,
    this.filter,
    this.search = '',
    this.userLocation,
    this.error,
  });

  List<CampusLocation> get filtered {
    return locations.where((loc) {
      final matchSearch = loc.name.toLowerCase().contains(search.toLowerCase());
      final matchFilter = filter == null || loc.category == filter;
      return matchSearch && matchFilter;
    }).toList();
  }

  MapState copyWith({
    List<CampusLocation>? locations,
    CampusLocation? selected,
    bool clearSelected = false,
    LocationCategory? filter,
    bool clearFilter = false,
    String? search,
    LatLng? userLocation,
    String? error,
    bool clearError = false,
  }) {
    return MapState(
      locations: locations ?? this.locations,
      selected: clearSelected ? null : selected ?? this.selected,
      filter: clearFilter ? null : filter ?? this.filter,
      search: search ?? this.search,
      userLocation: userLocation ?? this.userLocation,
      error: clearError ? null : error ?? this.error,
    );
  }
}
