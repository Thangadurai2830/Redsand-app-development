import 'package:equatable/equatable.dart';

class MaintenanceRequest extends Equatable {
  final String issueType;
  final String description;
  final String? photoPath;

  const MaintenanceRequest({
    required this.issueType,
    required this.description,
    this.photoPath,
  });

  @override
  List<Object?> get props => [issueType, description, photoPath];
}
