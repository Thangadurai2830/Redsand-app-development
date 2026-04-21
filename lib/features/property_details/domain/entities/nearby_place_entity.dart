import 'package:equatable/equatable.dart';

class NearbyPlaceEntity extends Equatable {
  final String name;
  final String category;
  final double distanceKm;
  final int travelTimeMins;

  const NearbyPlaceEntity({
    required this.name,
    required this.category,
    required this.distanceKm,
    required this.travelTimeMins,
  });

  @override
  List<Object?> get props => [name, category, distanceKm, travelTimeMins];
}
