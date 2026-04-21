import '../models/rent_receipt_model.dart';

abstract class RentReceiptsLocalDataSource {
  Future<List<RentReceiptModel>> fetchRentReceipts();
}

class RentReceiptsLocalDataSourceImpl implements RentReceiptsLocalDataSource {
  @override
  Future<List<RentReceiptModel>> fetchRentReceipts() async {
    return const [
      RentReceiptModel(
        id: 'rr_001',
        title: 'April 2026 Rent Receipt',
        periodLabel: 'April 2026',
        issueDate: '2026-04-01',
        amount: '₹22,000',
        status: 'available',
        referenceNumber: 'RR-2026-04-001',
        notes: null,
      ),
      RentReceiptModel(
        id: 'rr_002',
        title: 'March 2026 Rent Receipt',
        periodLabel: 'March 2026',
        issueDate: '2026-03-01',
        amount: '₹22,000',
        status: 'available',
        referenceNumber: 'RR-2026-03-001',
        notes: null,
      ),
      RentReceiptModel(
        id: 'rr_003',
        title: 'February 2026 Rent Receipt',
        periodLabel: 'February 2026',
        issueDate: '2026-02-01',
        amount: '₹22,000',
        status: 'available',
        referenceNumber: 'RR-2026-02-001',
        notes: null,
      ),
    ];
  }
}
