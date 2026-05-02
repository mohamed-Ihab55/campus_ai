import 'dart:io';

import 'package:campus_ai/features/map_feature/data/model/compus_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapState(locations: campusLocations));

  void selectLocation(CampusLocation location) {
    emit(state.copyWith(selected: location, clearError: true));
  }

  void clearSelection() {
    emit(state.copyWith(clearSelected: true));
  }

  void setFilter(LocationCategory? category) {
    emit(
      state.copyWith(
        filter: category,
        clearFilter: category == null,
      ),
    );
  }

  void search(String text) {
    emit(state.copyWith(search: text));
  }

  Future<void> locateUser() async {
    try {
      final enabled =
      await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        emit(state.copyWith(error: 'Please enable GPS.'));
        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        emit(
          state.copyWith(
            error: 'Location permission denied.',
          ),
        );
        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();

        emit(
          state.copyWith(
            error:
            'Permission denied forever. Open settings.',
          ),
        );
        return;
      }

      final position =
      await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );

      emit(
        state.copyWith(
          userLocation: LatLng(
            position.latitude,
            position.longitude,
          ),
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          error: 'Failed to get location.',
        ),
      );
    }
  }

  LocationSettings get _settings {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
    );
  }
}
