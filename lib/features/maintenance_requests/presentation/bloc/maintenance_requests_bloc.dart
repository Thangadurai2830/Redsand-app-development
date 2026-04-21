import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/maintenance_request.dart';
import '../../domain/usecases/get_maintenance_history.dart';
import '../../domain/usecases/raise_maintenance_request.dart';
import 'maintenance_requests_event.dart';
import 'maintenance_requests_state.dart';

class MaintenanceRequestsBloc extends Bloc<MaintenanceRequestsEvent, MaintenanceRequestsState> {
  final GetMaintenanceHistory getMaintenanceHistory;
  final RaiseMaintenanceRequest raiseMaintenanceRequest;

  MaintenanceRequestsBloc({
    required this.getMaintenanceHistory,
    required this.raiseMaintenanceRequest,
  }) : super(const MaintenanceRequestsState.initial()) {
    on<MaintenanceHistoryRequested>(_onHistoryRequested);
    on<MaintenanceRequestSubmitted>(_onSubmitted);
    on<MaintenanceMessageCleared>(_onMessageCleared);
  }

  Future<void> _onHistoryRequested(
    MaintenanceHistoryRequested event,
    Emitter<MaintenanceRequestsState> emit,
  ) async {
    emit(state.copyWith(status: MaintenanceRequestsStatus.loading, clearMessage: true));
    final result = await getMaintenanceHistory(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: MaintenanceRequestsStatus.failure,
        message: _messageForFailure(failure),
      )),
      (tickets) => emit(state.copyWith(
        status: MaintenanceRequestsStatus.loaded,
        tickets: tickets,
      )),
    );
  }

  Future<void> _onSubmitted(
    MaintenanceRequestSubmitted event,
    Emitter<MaintenanceRequestsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearMessage: true));
    final result = await raiseMaintenanceRequest(
      MaintenanceRequest(
        issueType: event.issueType,
        description: event.description,
        photoPath: event.photoPath,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        status: MaintenanceRequestsStatus.failure,
        message: _messageForFailure(failure),
      )),
      (ticket) {
        final updatedTickets = [ticket, ...state.tickets];
        emit(state.copyWith(
          status: MaintenanceRequestsStatus.loaded,
          tickets: updatedTickets,
          isSubmitting: false,
          message: 'Maintenance ticket raised successfully',
        ));
      },
    );
  }

  void _onMessageCleared(
    MaintenanceMessageCleared event,
    Emitter<MaintenanceRequestsState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }

  String _messageForFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Unable to reach maintenance service. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
