import '../models/maintenance_ticket_model.dart';

abstract class MaintenanceLocalDataSource {
  Future<List<MaintenanceTicketModel>> fetchMaintenanceHistory();
}

class MaintenanceLocalDataSourceImpl implements MaintenanceLocalDataSource {
  @override
  Future<List<MaintenanceTicketModel>> fetchMaintenanceHistory() async {
    return [
      MaintenanceTicketModel(
        id: 'mt_001',
        issueType: 'plumbing',
        description: 'Leaking tap in the kitchen sink.',
        status: 'resolved',
        createdAt: DateTime(2026, 3, 10),
        updatedAt: DateTime(2026, 3, 14),
        propertyName: 'Sunrise Heights - 3BHK',
        propertyAddress: 'HSR Layout, Bengaluru',
      ),
      MaintenanceTicketModel(
        id: 'mt_002',
        issueType: 'electrical',
        description: 'Power fluctuation in the master bedroom.',
        status: 'in-progress',
        createdAt: DateTime(2026, 4, 5),
        updatedAt: DateTime(2026, 4, 8),
        propertyName: 'Sunrise Heights - 3BHK',
        propertyAddress: 'HSR Layout, Bengaluru',
      ),
    ];
  }
}
