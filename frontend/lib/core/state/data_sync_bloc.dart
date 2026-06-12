import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'data_sync_event.dart';
import 'data_sync_state.dart';
import '../network/network_client.dart';
import '../../../main.dart'; // To get getIt<NetworkClient>()

class DataSyncBloc extends Bloc<DataSyncEvent, DataSyncState> {
  Timer? _pollingTimer;

  DataSyncBloc() : super(const DataSyncState()) {
    on<DataSyncTriggered>(_onSyncTriggered);
    on<DataSyncStopPolling>(_onStopPolling);
  }

  Future<void> _onSyncTriggered(
    DataSyncTriggered event,
    Emitter<DataSyncState> emit,
  ) async {
    // If not silent and initial load, show loading
    if (!event.isSilent && state.status == DataSyncStatus.initial) {
      emit(state.copyWith(status: DataSyncStatus.loading));
    }

    try {
      final dio = getIt<NetworkClient>().dio;
      
      // Parallel fetches for speed
      final results = await Future.wait([
        dio.get('/auth/me/'), // User profile
        dio.get('/incidents/', queryParameters: {'feed': 'global'}), // Active emergency feed
        _getCurrentLocation(), // GPS
      ]);

      final profileRes = results[0] as Response;
      final incidentRes = results[1] as Response;
      final position = results[2] as Position?;

      final emergencies = (incidentRes.data is List) 
          ? incidentRes.data as List 
          : incidentRes.data['results'] ?? [];

      emit(state.copyWith(
        status: DataSyncStatus.success,
        profile: profileRes.data as Map<String, dynamic>,
        activeEmergencies: emergencies,
        currentLocation: position,
      ));

      // Start background polling if not already running
      _startPolling();

    } catch (e) {
      debugPrint('DataSyncBloc Error: $e');
      if (state.status == DataSyncStatus.initial) {
        emit(state.copyWith(status: DataSyncStatus.failure));
      }
      // If we already have data, keep it instead of failing out completely.
    }
  }

  void _onStopPolling(
    DataSyncStopPolling event,
    Emitter<DataSyncState> emit,
  ) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      add(const DataSyncTriggered(isSilent: true));
    });
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Location Error in Sync: $e');
      return null;
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
