import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/map_feature/data/cubit/map_cubit.dart';
import 'package:campus_ai/features/map_feature/data/cubit/map_state.dart';
import 'package:campus_ai/features/map_feature/data/model/compus_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

class MapScreenBody extends StatefulWidget {
  const MapScreenBody({super.key});

  @override
  State<MapScreenBody> createState() => _MapScreenBodyState();
}

class _MapScreenBodyState extends State<MapScreenBody> {
  late final MapController _mapController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: campusCenter,
                  initialZoom: 17,
                  minZoom: 3,
                  maxZoom: 19,
                  onTap: (_, _) => context.read<MapCubit>().clearSelection(),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.ai_campus_guide',
                  ),

                  // ✅ Attribution الجديد
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        '© OpenStreetMap contributors',
                      ),
                      TextSourceAttribution(
                        '© CARTO',
                      ),
                    ],
                  ),
                  if (state.userLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: state.userLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: state.filtered.map((loc) {
                      final isSelected = state.selected?.id == loc.id;

                      return Marker(
                        point: loc.position,
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () =>
                              context.read<MapCubit>().selectLocation(loc),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: loc.color,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                loc.emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              Positioned(
                bottom: 20,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.my_location, color: Colors.white),
                  onPressed: () async {
                    final cubit = context.read<MapCubit>();
                    await cubit.locateUser();
                    final loc = cubit.state.userLocation;
                    if (loc != null) {
                      _mapController.move(loc, 17);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Unable to get location')),
                      );
                    }
                  },
                ),
              ),
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: TextField(
                  controller: _searchController,
                  onChanged: context.read<MapCubit>().search,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // ... FAB unchanged
            ],
          );
        },
      ),
    );
  }
}
