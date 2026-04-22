enum OwnerListingStatus {
  draft,
  pending,
  approved,
  flagged,
  rented,
}

extension OwnerListingStatusX on OwnerListingStatus {
  String get apiValue => name;

  String get label {
    switch (this) {
      case OwnerListingStatus.draft:
        return 'Draft';
      case OwnerListingStatus.pending:
        return 'Pending';
      case OwnerListingStatus.approved:
        return 'Approved';
      case OwnerListingStatus.flagged:
        return 'Flagged';
      case OwnerListingStatus.rented:
        return 'Rented';
    }
  }

  bool get isActive =>
      this == OwnerListingStatus.pending ||
      this == OwnerListingStatus.approved ||
      this == OwnerListingStatus.rented;
}

OwnerListingStatus ownerListingStatusFromApiValue(String? value) {
  final normalized = value?.trim().toLowerCase();
  switch (normalized) {
    case 'draft':
      return OwnerListingStatus.draft;
    case 'pending':
      return OwnerListingStatus.pending;
    case 'approved':
    case 'active':
      return OwnerListingStatus.approved;
    case 'flagged':
    case 'rejected':
      return OwnerListingStatus.flagged;
    case 'rented':
    case 'sold':
      return OwnerListingStatus.rented;
    default:
      return OwnerListingStatus.pending;
  }
}
