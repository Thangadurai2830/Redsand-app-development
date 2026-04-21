import 'package:equatable/equatable.dart';

class PropertyOwnerEntity extends Equatable {
  final String name;
  final String company;
  final String phoneNumber;
  final String whatsappNumber;
  final bool isVerified;
  final double rating;
  final String responseTime;

  const PropertyOwnerEntity({
    required this.name,
    required this.company,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.isVerified,
    required this.rating,
    required this.responseTime,
  });

  @override
  List<Object?> get props => [
        name,
        company,
        phoneNumber,
        whatsappNumber,
        isVerified,
        rating,
        responseTime,
      ];
}
