import 'package:equatable/equatable.dart';

import '../../domain/entities/rent_receipt.dart';

enum RentReceiptsStatus { initial, loading, loaded, failure }

class RentReceiptsState extends Equatable {
  final RentReceiptsStatus status;
  final List<RentReceipt> receipts;
  final String? downloadingReceiptId;
  final String? message;

  const RentReceiptsState({
    required this.status,
    required this.receipts,
    required this.downloadingReceiptId,
    required this.message,
  });

  const RentReceiptsState.initial()
      : status = RentReceiptsStatus.initial,
        receipts = const [],
        downloadingReceiptId = null,
        message = null;

  bool get hasReceipts => receipts.isNotEmpty;
  bool isDownloading(String id) => downloadingReceiptId == id;

  RentReceiptsState copyWith({
    RentReceiptsStatus? status,
    List<RentReceipt>? receipts,
    String? downloadingReceiptId,
    String? message,
    bool clearMessage = false,
    bool clearDownloadingReceiptId = false,
  }) {
    return RentReceiptsState(
      status: status ?? this.status,
      receipts: receipts ?? this.receipts,
      downloadingReceiptId:
          clearDownloadingReceiptId ? null : (downloadingReceiptId ?? this.downloadingReceiptId),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, receipts, downloadingReceiptId, message];
}
