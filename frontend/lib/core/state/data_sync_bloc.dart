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
      
      // Helper function to swallow 403s and non-critical errors so parallel sync doesn't crash
      Future<Response> safeGet(String path, {Map<String, dynamic>? queryParameters}) async {
        try {
          return await dio.get(path, queryParameters: queryParameters);
        } on DioException catch (e) {
          if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
            // If forbidden/unauthorized, just return an empty response so the app still loads
            return Response(requestOptions: e.requestOptions, statusCode: e.response?.statusCode, data: []);
          }
          rethrow; // Rethrow other critical errors (like 500s or network drops)
        }
      }

      // Parallel fetches for speed
      final results = await Future.wait([
        safeGet('/auth/me/'), // User profile
        safeGet('/incidents/', queryParameters: {'feed': 'global'}), // Active emergency feed
        safeGet('/incidents/'), // All reports
        safeGet('/dispatcher/users/'), // Units
        _getCurrentLocation(), // GPS
      ]);

      final profileRes = results[0] as Response;
      final incidentRes = results[1] as Response;
      final allReportsRes = results[2] as Response;
      final unitsRes = results[3] as Response;
      final position = results[4] as Position?;

      final emergencies = (incidentRes.data is List) 
          ? incidentRes.data as List 
          : incidentRes.data['results'] ?? [];
          
      final allReports = (allReportsRes.data is List)
          ? allReportsRes.data as List
          : allReportsRes.data['results'] ?? [];
          
      final units = (unitsRes.data is List)
          ? unitsRes.data as List
          : unitsRes.data['results'] ?? [];
          
      // Check if profile actually loaded, if it's empty due to 401/403, we should fail
      if (profileRes.data == null || (profileRes.data is List && (profileRes.data as List).isEmpty)) {
         throw Exception("Failed to load user profile");
      }

      emit(state.copyWith(
        status: DataSyncStatus.success,
        profile: profileRes.data as Map<String, dynamic>,
        activeEmergencies: emergencies,
        allReports: allReports,
        units: units,
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
