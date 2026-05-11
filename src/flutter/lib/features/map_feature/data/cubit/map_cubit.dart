import 'dart:async';
import 'dart:io';

import 'package:campus_ai/features/map_feature/data/model/campus_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:campus_ai/features/map_feature/data/cubit/map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapState(locations: campusLocations));

  Timer? _debounce;

  // ── Selection ──────────────────────────────────────────────────────────────

  void selectLocation(CampusLocation location) {
    if (state.selected?.id == location.id) return;
    emit(state.copyWith(selected: location, clearError: true));
  }

  void clearSelection() {
    if (state.selected == null) return;
    emit(state.copyWith(clearSelected: true));
  }

  // ── Filter & Search ────────────────────────────────────────────────────────

  void setFilter(LocationCategory? category) {
    if (state.filter == category) return;
    emit(state.copyWith(filter: category, clearFilter: category == null));
  }

  void search(String text) {
    if (state.search == text) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      emit(state.copyWith(search: text));
    });
  }

  // ── GPS ────────────────────────────────────────────────────────────────────

  Future<void> locateUser() async {
    try {
      final hasService = await Geolocator.isLocationServiceEnabled();
      if (!hasService) {
        _emitError('الرجاء تفعيل GPS.');
        return;
      }

      final permission = await _handlePermission();
      if (!permission) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );

      emit(
        state.copyWith(
          userLocation: LatLng(position.latitude, position.longitude),
          clearError: true,
        ),
      );
    } catch (_) {
      _emitError('تعذّر تحديد الموقع.');
    }
  }

  Future<bool> _handlePermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _emitError('تم رفض إذن الموقع.');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      _emitError('الإذن مرفوض دائماً. افتح الإعدادات.');
      return false;
    }

    return true;
  }

  LocationSettings get _settings {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(accuracy: LocationAccuracy.best, distanceFilter: 5);
    }
    return const LocationSettings(accuracy: LocationAccuracy.high);
  }

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
