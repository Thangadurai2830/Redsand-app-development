import '../../domain/entities/owner_buyer_interest_entity.dart';
import 'owner_dashboard_json.dart';

class OwnerBuyerInterestModel extends OwnerBuyerInterestEntity {
  const OwnerBuyerInterestModel({
    required super.id,
    required super.buyerName,
    required super.listingId,
    required super.listingTitle,
    required super.phone,
    required super.email,
    required super.budget,
    required super.note,
    super.requestedAt,
  });

  factory OwnerBuyerInterestModel.fromJson(Map<String, dynamic> json) {
    final interest = unwrapObject(json);
    final buyer = normalizeMap(interest['buyer'] ?? interest['lead'] ?? interest['user']);
    final listing = normalizeMap(interest['listing']);

    return OwnerBuyerInterestModel(
      id: stringValue(interest, const ['id', 'interest_id', 'lead_id'], fallback: 'unknown-interest'),
      buyerName: stringValue(
        buyer,
        const ['name', 'full_name', 'buyer_name'],
        fallback: stringValue(interest, const ['buyer_name', 'name'], fallback: 'Interested Buyer'),
      ),
      listingId: stringValue(
        listing,
        const ['id', 'listing_id'],
        fallback: stringValue(interest, const ['listing_id', 'property_id'], fallback: ''),
      ),
      listingTitle: stringValue(
        listing,
        const ['title', 'listing_title', 'name'],
        fallback: stringValue(interest, const ['listing_title', 'property_title'], fallback: 'Listing'),
      ),
      phone: stringValue(
        buyer,
        const ['phone', 'mobile', 'phone_number'],
        fallback: stringValue(interest, const ['phone', 'mobile'], fallback: ''),
      ),
      email: stringValue(
        buyer,
        const ['email'],
        fallback: stringValue(interest, const ['email'], fallback: ''),
      ),
      budget: stringValue(interest, const ['budget', 'budget_range', 'offer_amount'], fallback: 'Not shared'),
      note: stringValue(interest, const ['message', 'note', 'comment', 'remarks'], fallback: 'No message shared'),
      requestedAt: dateTimeValue(interest, const ['created_at', 'requested_at', 'updated_at']),
    );
  }
}

