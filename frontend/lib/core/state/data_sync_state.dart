import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

enum DataSyncStatus { initial, loading, success, failure }

class DataSyncState extends Equatable {
  final DataSyncStatus status;
  final Map<String, dynamic>? profile;
  final List<dynamic> activeEmergencies;
  final List<dynamic> allReports;
  final List<dynamic> units;
  final Position? currentLocation;

  const DataSyncState({
    this.status = DataSyncStatus.initial,
    this.profile,
    this.activeEmergencies = const [],
    this.allReports = const [],
    this.units = const [],
    this.currentLocation,
  });

  DataSyncState copyWith({
    DataSyncStatus? status,
    Map<String, dynamic>? profile,
    List<dynamic>? activeEmergencies,
    List<dynamic>? allReports,
    List<dynamic>? units,
    Position? currentLocation,
  }) {
    return DataSyncState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      activeEmergencies: activeEmergencies ?? this.activeEmergencies,
      allReports: allReports ?? this.allReports,
      units: units ?? this.units,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  List<Object?> get props => [status, profile, activeEmergencies, allReports, units, currentLocation];
}
