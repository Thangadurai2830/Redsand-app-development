import 'package:equatable/equatable.dart';

class KycSubmissionRequest extends Equatable {
  final String aadhaarReference;
  final String panReference;
  final String notes;

  const KycSubmissionRequest({
    required this.aadhaarReference,
    required this.panReference,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'aadhaar_reference': aadhaarReference,
        'pan_reference': panReference,
        'notes': notes,
      };

  @override
  List<Object?> get props => [aadhaarReference, panReference, notes];
}
