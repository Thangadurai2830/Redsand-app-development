import 'package:equatable/equatable.dart';

sealed class MaintenanceRequestsEvent extends Equatable {
  const MaintenanceRequestsEvent();

  @override
  List<Object?> get props => [];
}

class MaintenanceHistoryRequested extends MaintenanceRequestsEvent {
  const MaintenanceHistoryRequested();
}

class MaintenanceRequestSubmitted extends MaintenanceRequestsEvent {
  final String issueType;
  final String description;
  final String? photoPath;

  const MaintenanceRequestSubmitted({
    required this.issueType,
    required this.description,
    this.photoPath,
  });

  @override
  List<Object?> get props => [issueType, description, photoPath];
}

class MaintenanceMessageCleared extends MaintenanceRequestsEvent {
  const MaintenanceMessageCleared();
}
