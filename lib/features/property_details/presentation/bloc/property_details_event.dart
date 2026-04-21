import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/listing_entity.dart';

abstract class PropertyDetailsEvent extends Equatable {
  const PropertyDetailsEvent();

  @override
  List<Object?> get props => [];
}

class PropertyDetailsLoaded extends PropertyDetailsEvent {
  final ListingEntity listing;

  const PropertyDetailsLoaded(this.listing);

  @override
  List<Object?> get props => [listing];
}

class PropertyDetailsSaveRequested extends PropertyDetailsEvent {
  const PropertyDetailsSaveRequested();
}

class PropertyDetailsContactRevealRequested extends PropertyDetailsEvent {
  const PropertyDetailsContactRevealRequested();
}
