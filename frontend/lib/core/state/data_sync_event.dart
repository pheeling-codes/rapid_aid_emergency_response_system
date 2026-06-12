import 'package:equatable/equatable.dart';

abstract class DataSyncEvent extends Equatable {
  const DataSyncEvent();

  @override
  List<Object?> get props => [];
}

class DataSyncTriggered extends DataSyncEvent {
  final bool isSilent;
  const DataSyncTriggered({this.isSilent = false});
  
  @override
  List<Object?> get props => [isSilent];
}

class DataSyncStopPolling extends DataSyncEvent {}
