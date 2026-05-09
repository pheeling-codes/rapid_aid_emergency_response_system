import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Location Service for Citizen Feature
/// 
/// Provides GPS stream functionality to reflect real-time location status.
/// Used by the Dashboard GPS chip and incident reporting.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionSubscription;
  
  final _locationStatusController = StreamController<LocationStatus>.broadcast();
  Stream<LocationStatus> get locationStatusStream => _locationStatusController.stream;

  bool _isTracking = false;
  LocationAccuracyStatus _currentAccuracy = LocationAccuracyStatus.precise;

  /// Check and request location permissions
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationStatusController.add(LocationStatus.serviceDisabled);
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _locationStatusController.add(LocationStatus.permissionDenied);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _locationStatusController.add(LocationStatus.permissionDeniedForever);
      return false;
    }

    _locationStatusController.add(LocationStatus.granted);
    return true;
  }

  /// Start GPS stream with high accuracy
  Future<void> startTracking() async {
    if (_isTracking) return;

    final hasPermission = await checkPermissions();
    if (!hasPermission) return;

    _isTracking = true;

    // Configure location settings for high accuracy
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings);
    _positionSubscription = _positionStream?.listen(
      (Position position) {
        // Determine accuracy status
        if (position.accuracy <= 10) {
          _currentAccuracy = LocationAccuracyStatus.precise;
        } else if (position.accuracy <= 50) {
          _currentAccuracy = LocationAccuracyStatus.approximate;
        } else {
          _currentAccuracy = LocationAccuracyStatus.low;
        }

        _locationStatusController.add(LocationStatus.active);
      },
      onError: (error) {
        _locationStatusController.add(LocationStatus.error);
      },
    );
  }

  /// Stop GPS stream
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
  }

  /// Get current position once
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get current accuracy status
  LocationAccuracyStatus get currentAccuracy => _currentAccuracy;

  /// Check if currently tracking
  bool get isTracking => _isTracking;

  /// Dispose resources
  void dispose() {
    stopTracking();
    _locationStatusController.close();
  }
}

/// Location status enum
enum LocationStatus {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  granted,
  active,
  error,
}

/// Location accuracy status for UI display
enum LocationAccuracyStatus {
  precise,    // <= 10 meters
  approximate, // <= 50 meters
  low,        // > 50 meters
}

/// Extension for display strings
extension LocationAccuracyStatusExtension on LocationAccuracyStatus {
  String get displayLabel {
    switch (this) {
      case LocationAccuracyStatus.precise:
        return 'GPS FIX: HIGH ACCURACY';
      case LocationAccuracyStatus.approximate:
        return 'GPS FIX: MEDIUM ACCURACY';
      case LocationAccuracyStatus.low:
        return 'GPS FIX: LOW ACCURACY';
    }
  }

  String get colorHex {
    switch (this) {
      case LocationAccuracyStatus.precise:
        return '#005EB8'; // Primary Blue
      case LocationAccuracyStatus.approximate:
        return '#445E91'; // Secondary
      case LocationAccuracyStatus.low:
        return '#D32F2F'; // Emergency Red
    }
  }
}
