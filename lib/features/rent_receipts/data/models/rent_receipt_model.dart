import '../../domain/entities/rent_receipt.dart';

class RentReceiptModel extends RentReceipt {
  const RentReceiptModel({
    required super.id,
    required super.title,
    required super.periodLabel,
    required super.issueDate,
    required super.amount,
    required super.status,
    required super.referenceNumber,
    required super.notes,
  });

  factory RentReceiptModel.fromJson(Map<String, dynamic> json) {
    final receipt = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    return RentReceiptModel(
      id: _stringValue(receipt, const ['id', 'receipt_id', 'rent_receipt_id'], DateTime.now().millisecondsSinceEpoch.toString()),
      title: _stringValue(
        receipt,
        const ['title', 'receipt_title', 'month_label', 'period', 'name'],
        'Rent Receipt',
      ),
      periodLabel: _stringValue(
        receipt,
        const ['period_label', 'month', 'billing_month', 'rent_month', 'receipt_month'],
        'Monthly receipt',
      ),
      issueDate: _stringValue(
        receipt,
        const ['issue_date', 'issued_at', 'created_at', 'date'],
        '',
      ),
      amount: _stringValue(
        receipt,
        const ['amount', 'rent_amount', 'paid_amount', 'total_amount'],
        '',
      ),
      status: _stringValue(
        receipt,
        const ['status', 'receipt_status'],
        'available',
      ),
      referenceNumber: _nullableStringValue(
        receipt,
        const ['reference_number', 'receipt_number', 'reference', 'no'],
      ),
      notes: _nullableStringValue(
        receipt,
        const ['notes', 'description', 'remarks', 'message'],
      ),
    );
  }

  static String _stringValue(
    Map<String, dynamic> json,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  static String? _nullableStringValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }
}
