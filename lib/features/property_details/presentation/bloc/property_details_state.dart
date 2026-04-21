import 'package:equatable/equatable.dart';

import '../../domain/entities/property_details_entity.dart';

enum PropertyDetailsStatus { initial, loading, loaded, saving, revealing, failure }

class PropertyDetailsState extends Equatable {
  final PropertyDetailsStatus status;
  final PropertyDetailsEntity? details;
  final bool isSaved;
  final bool contactUnlocked;
  final String? message;

  const PropertyDetailsState({
    required this.status,
    this.details,
    this.isSaved = false,
    this.contactUnlocked = false,
    this.message,
  });

  const PropertyDetailsState.initial()
      : status = PropertyDetailsStatus.initial,
        details = null,
        isSaved = false,
        contactUnlocked = false,
        message = null;

  PropertyDetailsState copyWith({
    PropertyDetailsStatus? status,
    PropertyDetailsEntity? details,
    bool? isSaved,
    bool? contactUnlocked,
    String? message,
  }) {
    return PropertyDetailsState(
      status: status ?? this.status,
      details: details ?? this.details,
      isSaved: isSaved ?? this.isSaved,
      contactUnlocked: contactUnlocked ?? this.contactUnlocked,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, details, isSaved, contactUnlocked, message];
}
