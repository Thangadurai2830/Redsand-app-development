import 'package:equatable/equatable.dart';

import '../../domain/entities/maintenance_ticket.dart';

enum MaintenanceRequestsStatus { initial, loading, loaded, failure }

class MaintenanceRequestsState extends Equatable {
  final MaintenanceRequestsStatus status;
  final List<MaintenanceTicket> tickets;
  final bool isSubmitting;
  final String? message;

  const MaintenanceRequestsState({
    required this.status,
    required this.tickets,
    required this.isSubmitting,
    required this.message,
  });

  const MaintenanceRequestsState.initial()
      : status = MaintenanceRequestsStatus.initial,
        tickets = const [],
        isSubmitting = false,
        message = null;

  bool get hasTickets => tickets.isNotEmpty;

  MaintenanceRequestsState copyWith({
    MaintenanceRequestsStatus? status,
    List<MaintenanceTicket>? tickets,
    bool? isSubmitting,
    String? message,
    bool clearMessage = false,
  }) {
    return MaintenanceRequestsState(
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, tickets, isSubmitting, message];
}
