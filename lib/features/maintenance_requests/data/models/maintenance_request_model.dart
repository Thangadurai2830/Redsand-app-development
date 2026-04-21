import '../../domain/entities/maintenance_request.dart';

class MaintenanceRequestModel extends MaintenanceRequest {
  const MaintenanceRequestModel({
    required super.issueType,
    required super.description,
    super.photoPath,
  });

  factory MaintenanceRequestModel.fromEntity(MaintenanceRequest request) {
    return MaintenanceRequestModel(
      issueType: request.issueType,
      description: request.description,
      photoPath: request.photoPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue_type': issueType,
      'description': description,
      if (photoPath != null && photoPath!.trim().isNotEmpty) 'photo_reference': photoPath!.trim(),
    };
  }
}
