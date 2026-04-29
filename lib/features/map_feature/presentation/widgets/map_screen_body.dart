import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/map_feature/data/cubit/map_cubit.dart';
import 'package:campus_ai/features/map_feature/data/cubit/map_state.dart';
import 'package:campus_ai/features/map_feature/data/model/compus_data.dart';
import 'package:campus_ai/features/map_feature/presentation/widgets/map_in_text.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      // Use ResizeToAvoidBottomInset to prevent search bar from breaking the map
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<MapCubit, MapState>(
        listener: (context, state) {
          // If a location is selected from search, move the camera there
          if (state.selected != null) {
            _mapController.move(state.selected!.position, 18);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // 1. THE MAP
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: campusCenter,
                  initialZoom: 17,
                  onTap: (_, __) => context.read<MapCubit>().clearSelection(),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),

                  // User Location Marker
                  if (state.userLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: state.userLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.person_pin_circle,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),

                  // Campus Locations Markers
                  MarkerLayer(
                    markers: state.filtered.map((loc) {
                      final isSelected = state.selected?.id == loc.id;
                      return Marker(
                        point: loc.position,
                        width: isSelected ? 60 : 45,
                        height: isSelected ? 60 : 45,
                        child: GestureDetector(
                          onTap: () =>
                              context.read<MapCubit>().selectLocation(loc),
                          child: _buildMarkerWidget(loc, isSelected),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // 2. TOP SEARCH & FILTER SECTION
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: 10),
                    _buildFilterChips(context, state),
                  ],
                ),
              ),

              // 3. SELECTION DETAIL CARD (Appears when marker is tapped)
              if (state.selected != null)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: _buildLocationDetailCard(state.selected!),
                ),

              // 4. FLOATING ACTION BUTTONS
              Positioned(
                bottom: 30,
                right: 16,
                child: FloatingActionButton(
                  heroTag: "locate_btn", // ✅ unique
                  backgroundColor: AppColors.primary,
                  onPressed: () => _handleLocateUser(context),
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ),

              Positioned(
                bottom: 100,
                right: 16,
                child: FloatingActionButton(
                  heroTag: "map_btn",
                  backgroundColor: AppColors.primary,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapInText()),
                  ),
                  child: const Icon(
                    Icons.maps_home_work_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMarkerWidget(CampusLocation loc, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isSelected ? loc.color : loc.color.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Center(
        child: Text(
          loc.emoji,
          style: TextStyle(fontSize: isSelected ? 24 : 18),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: context.read<MapCubit>().search,
        decoration: InputDecoration(
          hintText: 'Search departments, labs...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, MapState state) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: LocationCategory.values.map((cat) {
          final isSelected = state.filter == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              backgroundColor: AppColors.surface,
              label: Text(cat.label),
              selected: isSelected,
              onSelected: (val) =>
                  context.read<MapCubit>().setFilter(val ? cat : null),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocationDetailCard(CampusLocation loc) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: loc.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(loc.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "Floor: ${loc.floor}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.read<MapCubit>().clearSelection(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLocateUser(BuildContext context) async {
    final cubit = context.read<MapCubit>();
    await cubit.locateUser();
    if (cubit.state.userLocation != null) {
      _mapController.move(cubit.state.userLocation!, 17);
    }
  }
}
