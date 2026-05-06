import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/map_feature/data/cubit/map_cubit.dart';
import 'package:campus_ai/features/map_feature/data/cubit/map_state.dart';
import 'package:campus_ai/features/map_feature/data/model/compus_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreenBody extends StatefulWidget {
  const MapScreenBody({super.key});

  @override
  State<MapScreenBody> createState() => _MapScreenBodyState();
}

class _MapScreenBodyState extends State<MapScreenBody> {
  late final MapController mapController;
  late final TextEditingController searchController;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(
        const LatLng(30.0777111, 31.283907),
        18,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<MapCubit>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapCubit>();

    return Scaffold(
      body: BlocListener<MapCubit, MapState>(
        listener: (context, state) {
          if (state.selected != null) {
            mapController.move(state.selected!.position, 18);
          }
        },
        child: Stack(
          children: [
            /// ================= MAP =================
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: campusCenter,
                initialZoom: 17,
                onTap: (_, __) => cubit.clearSelection(),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),

                /// USER LOCATION
                BlocSelector<MapCubit, MapState, LatLng?>(
                  selector: (state) => state.userLocation,
                  builder: (_, userLocation) {
                    if (userLocation == null) return const SizedBox();

                    return MarkerLayer(
                      markers: [
                        Marker(
                          point: userLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.person_pin_circle,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                /// MARKERS
                BlocBuilder<MapCubit, MapState>(
                  buildWhen: (prev, curr) =>
                  prev.filtered != curr.filtered ||
                      prev.selected != curr.selected,
                  builder: (context, state) {
                    return MarkerLayer(
                      markers: state.filtered.map((loc) {
                        final selected = state.selected?.id == loc.id;

                        return Marker(
                          point: loc.position,
                          width: selected ? 60 : 45,
                          height: selected ? 60 : 45,
                          child: GestureDetector(
                            onTap: () => cubit.selectLocation(loc),
                            child: AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: loc.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: selected ? 3 : 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  loc.emoji,
                                  style: TextStyle(
                                    fontSize: selected ? 24 : 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),

            /// ================= TOP UI =================
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  _searchBar(),
                  const SizedBox(height: 10),
                  _filters(),
                ],
              ),
            ),

            /// ================= DETAILS =================
            BlocBuilder<MapCubit, MapState>(
              buildWhen: (prev, curr) => prev.selected != curr.selected,
              builder: (context, state) {
                if (state.selected == null) return const SizedBox();

                return Positioned(
                  left: 16,
                  right: 16,
                  bottom: 100,
                  child: _detailsCard(state.selected!),
                );
              },
            ),

            /// ================= GPS BUTTON =================
            Positioned(
              right: 16,
              bottom: 30,
              child: FloatingActionButton(
                onPressed: () async {
                  await cubit.locateUser();
                  final user = cubit.state.userLocation;

                  if (user != null) {
                    mapController.move(user, 17);
                  }
                },
                child: const Icon(Icons.gps_fixed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= SEARCH =================
  Widget _searchBar() {
    return TextField(
      controller: searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  /// ================= FILTERS =================
  Widget _filters() {
    return BlocBuilder<MapCubit, MapState>(
      buildWhen: (prev, curr) => prev.filter != curr.filter,
      builder: (context, state) {
        final cubit = context.read<MapCubit>();

        return SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: LocationCategory.values.map((category) {
              final selected = state.filter == category;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: selected,
                  label: Text(category.label),
                  onSelected: (_) {
                    cubit.setFilter(selected ? null : category);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// ================= DETAILS =================
  Widget _detailsCard(CampusLocation location) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: location.color,
              child: Text(location.emoji),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Floor: ${location.floor}'),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<MapCubit>().clearSelection();
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}