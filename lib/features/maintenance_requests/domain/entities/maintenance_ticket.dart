import 'package:equatable/equatable.dart';

class MaintenanceTicket extends Equatable {
  final String id;
  final String issueType;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? photoUrl;
  final String? propertyName;
  final String? propertyAddress;

  const MaintenanceTicket({
    required this.id,
    required this.issueType,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.propertyName,
    this.propertyAddress,
  });

  @override
  List<Object?> get props => [
        id,
        issueType,
        description,
        status,
        createdAt,
        updatedAt,
        photoUrl,
        propertyName,
        propertyAddress,
      ];
}
