import 'package:equatable/equatable.dart';

sealed class ScheduleVisitState extends Equatable {
  const ScheduleVisitState();

  @override
  List<Object?> get props => [];
}

class ScheduleVisitInitial extends ScheduleVisitState {
  const ScheduleVisitInitial();
}

class ScheduleVisitLoading extends ScheduleVisitState {
  const ScheduleVisitLoading();
}

class ScheduleVisitSuccess extends ScheduleVisitState {
  final String message;

  const ScheduleVisitSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ScheduleVisitFailure extends ScheduleVisitState {
  final String message;

  const ScheduleVisitFailure(this.message);

  @override
  List<Object?> get props => [message];
}
