import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../model/compus_data.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapState(locations: campusLocations));

  /// ================= SELECTION =================
  void selectLocation(CampusLocation location) {
    if (state.selected?.id == location.id) return;

    emit(state.copyWith(
      selected: location,
      clearError: true,
    ));
  }

  void clearSelection() {
    if (state.selected == null) return;

    emit(state.copyWith(clearSelected: true));
  }

  /// ================= FILTER =================
  void setFilter(LocationCategory? category) {
    if (state.filter == category) return;

    emit(state.copyWith(
      filter: category,
      clearFilter: category == null,
    ));
  }

  /// ================= SEARCH (OPTIMIZED) =================
  Timer? _debounce;

  void search(String text) {
    if (state.search == text) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      emit(state.copyWith(search: text));
    });
  }

  /// ================= LOCATION =================
  Future<void> locateUser() async {
    try {
      final hasService = await Geolocator.isLocationServiceEnabled();
      if (!hasService) {
        _emitError('Please enable GPS.');
        return;
      }

      final permission = await _handlePermission();
      if (!permission) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );

      final newLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      /// تجنب emit لو نفس المكان
      if (state.userLocation == newLocation) return;

      emit(state.copyWith(
        userLocation: newLocation,
        clearError: true,
      ));
    } catch (e) {
      _emitError('Failed to get location.');
    }
  }

  /// ================= PERMISSION HANDLING =================
  Future<bool> _handlePermission() async {
    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _emitError('Location permission denied.');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();

      _emitError('Permission denied forever. Open settings.');
      return false;
    }

    return true;
  }

  /// ================= SETTINGS =================
  LocationSettings get _settings {
    if (Platform.isAndroid) {
      return  AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      );
    }

    if (Platform.isIOS) {
      return  AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
    );
  }

  /// ================= ERROR HANDLER =================
  void _emitError(String message) {
    if (state.error == message) return;

    emit(state.copyWith(error: message));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}