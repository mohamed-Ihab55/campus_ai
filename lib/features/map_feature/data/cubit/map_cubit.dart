import 'dart:io';

import 'package:campus_ai/features/map_feature/data/model/compus_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapState(locations: campusLocations));

  void selectLocation(CampusLocation loc) {
    emit(state.copyWith(selected: loc));
  }

  void clearSelection() {
    emit(state.copyWith(selected: null));
  }

  void setFilter(LocationCategory? category) {
    emit(state.copyWith(filter: category));
  }

  void search(String value) {
    emit(state.copyWith(search: value));
  }

  Future<void> locateUser() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(state.copyWith(error: 'Open GPS to get your location'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          emit(state.copyWith(error: 'The premission was denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        emit(
          state.copyWith(
            error: 'Open app settings to grant location permission',
          ),
        );
        return;
      }

      final LocationSettings locationSettings;

      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        );
      } else if (Platform.isIOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      emit(
        state.copyWith(
          userLocation: LatLng(pos.latitude, pos.longitude),
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'error to detect the location'));
    }
  }
}
