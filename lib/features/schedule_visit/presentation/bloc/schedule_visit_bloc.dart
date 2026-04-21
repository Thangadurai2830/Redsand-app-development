import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/site_visit_request.dart';
import '../../domain/usecases/schedule_visit.dart';
import 'schedule_visit_event.dart';
import 'schedule_visit_state.dart';

class ScheduleVisitBloc extends Bloc<ScheduleVisitEvent, ScheduleVisitState> {
  final ScheduleVisit scheduleVisit;

  ScheduleVisitBloc({required this.scheduleVisit}) : super(const ScheduleVisitInitial()) {
    on<ScheduleVisitSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ScheduleVisitSubmitted event,
    Emitter<ScheduleVisitState> emit,
  ) async {
    emit(const ScheduleVisitLoading());

    final result = await scheduleVisit(
      SiteVisitRequest(
        listingId: event.listing.id,
        visitDate: event.visitDate,
        visitTime: event.visitTime,
        message: event.message,
      ),
    );

    result.fold(
      (failure) => emit(ScheduleVisitFailure(_messageForFailure(failure))),
      (message) => emit(ScheduleVisitSuccess(message)),
    );
  }

  String _messageForFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Unable to schedule your visit right now. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
