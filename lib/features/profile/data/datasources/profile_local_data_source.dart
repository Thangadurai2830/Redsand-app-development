import '../models/site_visit_record_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> fetchProfile();
  Future<List<SiteVisitRecordModel>> fetchSiteVisits();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  @override
  Future<UserProfileModel> fetchProfile() async {
    return const UserProfileModel(
      fullName: 'Alex Johnson',
      email: 'alex.johnson@example.com',
      phone: '+91 98765 43210',
      address: '12, Green Valley Apartments, Koramangala, Bengaluru - 560034',
      avatarUrl: '',
      kycStatus: 'pending',
      aadhaarVerified: false,
      panVerified: false,
      verificationMessage: 'Complete your KYC to unlock all features.',
    );
  }

  @override
  Future<List<SiteVisitRecordModel>> fetchSiteVisits() async {
    return const [
      SiteVisitRecordModel(
        id: 'sv_001',
        propertyName: 'Sunrise Heights - 3BHK',
        propertyAddress: 'HSR Layout, Bengaluru',
        visitDate: '2026-04-15',
        visitTime: '11:00 AM',
        status: 'completed',
        receiptUrl: null,
        notes: 'Visited with family, liked the view from 5th floor.',
      ),
      SiteVisitRecordModel(
        id: 'sv_002',
        propertyName: 'Palm Grove Residency - 2BHK',
        propertyAddress: 'Whitefield, Bengaluru',
        visitDate: '2026-04-10',
        visitTime: '3:30 PM',
        status: 'completed',
        receiptUrl: null,
        notes: '',
      ),
    ];
  }
}
