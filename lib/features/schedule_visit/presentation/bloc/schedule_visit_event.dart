import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/listing_entity.dart';

sealed class ScheduleVisitEvent extends Equatable {
  const ScheduleVisitEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleVisitSubmitted extends ScheduleVisitEvent {
  final ListingEntity listing;
  final DateTime visitDate;
  final String visitTime;
  final String message;

  const ScheduleVisitSubmitted({
    required this.listing,
    required this.visitDate,
    required this.visitTime,
    required this.message,
  });

  @override
  List<Object?> get props => [listing, visitDate, visitTime, message];
}
