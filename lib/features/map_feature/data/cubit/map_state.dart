import 'package:campus_ai/features/map_feature/data/model/compus_data.dart';
import 'package:latlong2/latlong.dart';

const _absent = Object();

class MapState {
  final List<CampusLocation> locations;
  final CampusLocation? selected;
  final LocationCategory? filter;
  final LatLng? userLocation;
  final String search;
  final String? error;

  const MapState({
    required this.locations,
    this.selected,
    this.filter,
    this.userLocation,
    this.search = '',
    this.error,
  });

  List<CampusLocation> get filtered {
    return locations.where((l) {
      final matchFilter = filter == null || l.category == filter;
      final matchSearch = l.name.toLowerCase().contains(search.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  MapState copyWith({
    List<CampusLocation>? locations,
    Object? selected = _absent, // sentinel so null can clear
    Object? filter = _absent, // sentinel so null can clear
    Object? userLocation = _absent, // sentinel so null can clear
    String? search,
    Object? error = _absent, // was ALWAYS ignored — now fixed
  }) {
    return MapState(
      locations: locations ?? this.locations,
      selected: identical(selected, _absent)
          ? this.selected
          : selected as CampusLocation?,
      filter: identical(filter, _absent)
          ? this.filter
          : filter as LocationCategory?,
      userLocation: identical(userLocation, _absent)
          ? this.userLocation
          : userLocation as LatLng?,
      search: search ?? this.search,
      error: identical(error, _absent) ? this.error : error as String?,
    );
  }
}
