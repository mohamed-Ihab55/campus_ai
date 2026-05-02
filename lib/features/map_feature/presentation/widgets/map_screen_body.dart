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
  late final MapController mapController;
  late final TextEditingController searchController;
  @override
  void initState() {
    super.initState();
    mapController = MapController();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: BlocConsumer<MapCubit, MapState>(
        listener: (context, state) {
          if (state.selected != null) {
            mapController.move(state.selected!.position, 18);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: campusCenter,
                  initialZoom: 17,
                  onTap: (_, __) {
                    context.read<MapCubit>().clearSelection();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
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
                  MarkerLayer(
                    markers: state.filtered.map((loc) {
                      final selected = state.selected?.id == loc.id;
                      return Marker(
                        point: loc.position,
                        width: selected ? 60 : 45,
                        height: selected ? 60 : 45,
                        child: GestureDetector(
                          onTap: () {
                            context.read<MapCubit>().selectLocation(loc);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: selected ? loc.color : loc.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: selected ? 3 : 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                loc.emoji,
                                style: TextStyle(fontSize: selected ? 24 : 18),
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
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    _searchBar(context),
                    const SizedBox(height: 10),
                    _filters(context, state),
                  ],
                ),
              ),
              if (state.selected != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 100,
                  child: _detailsCard(context, state.selected!),
                ),
              Positioned(
                right: 16,
                bottom: 30,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed: () async {
                    await context.read<MapCubit>().locateUser();
                    final user = context.read<MapCubit>().state.userLocation;
                    if (user != null) {
                      mapController.move(user, 17);
                    }
                  },
                  child: const Icon(
                    color: AppColors.bgColor,
                    Icons.gps_fixed_outlined,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged: context.read<MapCubit>().search,
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.primaryDeep),
        ),
      ),
    );
  }

  Widget _filters(BuildContext context, MapState state) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: LocationCategory.values.map((category) {
          final selected = state.filter == category;
          final backgroundColor = selected
              ? AppColors.primary
              : AppColors.bgColor;
          final textColor = selected ? Colors.white : AppColors.primary;
          final borderColor = selected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.25);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              showCheckmark: false,
              selected: selected,
              disabledColor: Colors.transparent,
              backgroundColor: backgroundColor,
              selectedColor: backgroundColor,
              side: BorderSide(color: borderColor, width: 1.2),
              elevation: selected ? 6 : 0,
              pressElevation: 0,
              shadowColor: AppColors.primary.withOpacity(0.18),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              label: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(category.label),
              ),
              onSelected: (_) {
                context.read<MapCubit>().setFilter(selected ? null : category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _detailsCard(BuildContext context, CampusLocation location) {
    return Card(
      color: AppColors.bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: location.color,
              child: Text(
                location.emoji,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'Floor: ${location.floor}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<MapCubit>().clearSelection();
              },
              icon: const Icon(color: AppColors.textSecondary, Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
