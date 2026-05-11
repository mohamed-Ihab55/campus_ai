import 'dart:async';

import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/map_feature/data/cubit/map_cubit.dart';
import 'package:campus_ai/features/map_feature/data/cubit/map_state.dart';
import 'package:campus_ai/features/map_feature/data/model/campus_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
  bool inside = false;
  int j = polygon.length - 1;

  for (int i = 0; i < polygon.length; i++) {
    final xi = polygon[i].longitude;
    final yi = polygon[i].latitude;
    final xj = polygon[j].longitude;
    final yj = polygon[j].latitude;

    final intersect =
        ((yi > point.latitude) != (yj > point.latitude)) &&
        (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);

    if (intersect) inside = !inside;
    j = i;
  }
  return inside;
}

class MapScreenBody extends StatefulWidget {
  const MapScreenBody({super.key});

  @override
  State<MapScreenBody> createState() => _MapScreenBodyState();
}

class _MapScreenBodyState extends State<MapScreenBody> {
  late final MapController _mapController;
  late final TextEditingController _searchController;
  Timer? _debounce;
  double _currentZoom = 17.5;
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(campusCenter, 18);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<MapCubit>().search(value);
    });
  }


  void _onMapTap(TapPosition _, LatLng tapped) {
    final cubit = context.read<MapCubit>();
    final locations = cubit.state.filtered;
    for (final loc in locations) {
      if (loc.polygon != null && _pointInPolygon(tapped, loc.polygon!)) {
        cubit.selectLocation(loc);
        return;
      }
    }
    cubit.clearSelection();
  }



  List<Polygon> _buildPolygons(
    List<CampusLocation> locations,
    CampusLocation? selected,
  ) {
    return locations.where((loc) => loc.polygon != null).map((loc) {
      final isSelected = selected?.id == loc.id;
      return Polygon(
        points: loc.polygon!,
        color: isSelected ? loc.fillColor.withOpacity(0.55) : loc.fillColor,
        borderColor: isSelected ? loc.color : loc.color.withOpacity(0.7),
        borderStrokeWidth: isSelected ? 2.5 : 1.5,
        label: loc.name,
        labelStyle: TextStyle(
          color: loc.color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.white, blurRadius: 4),
            Shadow(color: Colors.white, blurRadius: 8),
          ],
        ),
      );
    }).toList();
  }



  List<Marker> _buildPointMarkers(
    List<CampusLocation> locations,
    CampusLocation? selected,
  ) {
    return locations.where((loc) => loc.polygon == null).map((loc) {
      final isSelected = selected?.id == loc.id;
      final size = isSelected ? 52.0 : 40.0;

      return Marker(
        point: loc.center,
        width: size,
        height: size,
        child: GestureDetector(
          onTap: () => context.read<MapCubit>().selectLocation(loc),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: loc.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: loc.color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                loc.emoji,
                style: TextStyle(fontSize: isSelected ? 22 : 17),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Marker> _buildAllAsMarkers(
    List<CampusLocation> locations,
    CampusLocation? selected,
  ) {
    return locations.map((loc) {
      final isSelected = selected?.id == loc.id;
      final size = isSelected ? 52.0 : 40.0;

      return Marker(
        point: loc.center,
        width: size,
        height: size,
        child: GestureDetector(
          onTap: () => context.read<MapCubit>().selectLocation(loc),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: loc.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: loc.color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                loc.emoji,
                style: TextStyle(fontSize: isSelected ? 22 : 17),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapCubit>();

    return Scaffold(
      body: BlocListener<MapCubit, MapState>(
        listenWhen: (prev, curr) => prev.selected != curr.selected,
        listener: (_, state) {
          if (state.selected != null) {
            _mapController.move(state.selected!.center, 19);
          }
        },
        child: Stack(
          children: [

            BlocBuilder<MapCubit, MapState>(
              builder: (context, state) {
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: campusCenter,
                    initialZoom: 17.5,
                    minZoom: 15,
                    maxZoom: 20,
                    onTap: _onMapTap,
                    onMapEvent: (event) {
                      // ← أضف ده
                      if (event is MapEventMove) {
                        setState(() {
                          _currentZoom = event.camera.zoom;
                        });
                      }
                    },
                  ),
                  children: [

                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.campus_ai',
                    ),


                    if (_currentZoom >= 17.5)
                      PolygonLayer(
                        polygons: _buildPolygons(
                          state.filtered,
                          state.selected,
                        ),
                      ),


                    if (state.userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: state.userLocation!,
                            width: 44,
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF185FA5),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF185FA5,
                                    ).withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),

                    MarkerLayer(
                      markers: _currentZoom < 17.5
                          ? _buildAllAsMarkers(state.filtered, state.selected)
                          : _buildPointMarkers(state.filtered, state.selected),
                    ),
                  ],
                );
              },
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  _SearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 8),
                  _FiltersRow(),
                ],
              ),
            ),

            // ── بطاقة التفاصيل ─────────────────────────────────────────────
            BlocBuilder<MapCubit, MapState>(
              buildWhen: (prev, curr) => prev.selected != curr.selected,
              builder: (_, state) {
                if (state.selected == null) return const SizedBox.shrink();
                return Positioned(
                  left: 12,
                  right: 12,
                  bottom: 110,
                  child: _DetailsCard(
                    location: state.selected!,
                    onClose: cubit.clearSelection,
                  ),
                );
              },
            ),


            Positioned(
              right: 16,
              bottom: 36,
              child: FloatingActionButton(
                backgroundColor:  AppColors.primary,
                elevation: 4,
                onPressed: () async {
                  await cubit.locateUser();
                  final user = cubit.state.userLocation;
                  if (user != null) _mapController.move(user, 18);
                },
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),


            BlocBuilder<MapCubit, MapState>(
              buildWhen: (prev, curr) => prev.error != curr.error,
              builder: (_, state) {
                if (state.error == null) return const SizedBox.shrink();
                return Positioned(
                  bottom: 110,
                  left: 24,
                  right: 24,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA32D2D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        state.error!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        decoration: const InputDecoration(
          hintText: 'Search places, departments, labs....',
          hintTextDirection: TextDirection.rtl,
          prefixIcon: Icon(Icons.search, color: Color(0xFF185FA5)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}




class _FiltersRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      buildWhen: (prev, curr) => prev.filter != curr.filter,
      builder: (context, state) {
        final cubit = context.read<MapCubit>();

        return SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: LocationCategory.values.map((cat) {
              final selected = state.filter == cat;

              return GestureDetector(
                onTap: () => cubit.setFilter(selected ? null : cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? cat.color : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? cat.color : cat.color.withOpacity(0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        cat.label,
                        style: TextStyle(
                          color: selected ? Colors.white : cat.color,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}




class _DetailsCard extends StatelessWidget {
  final CampusLocation location;
  final VoidCallback onClose;

  const _DetailsCard({required this.location, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: location.fillColor,
                shape: BoxShape.circle,
                border: Border.all(color: location.color, width: 1.5),
              ),
              child: Center(
                child: Text(
                  location.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    location.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: location.color,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  if (location.floor != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      location.floor!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                  if (location.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      location.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),


            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.black38),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
