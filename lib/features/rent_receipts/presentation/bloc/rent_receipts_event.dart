import 'package:equatable/equatable.dart';

sealed class RentReceiptsEvent extends Equatable {
  const RentReceiptsEvent();

  @override
  List<Object?> get props => [];
}

class RentReceiptsLoadRequested extends RentReceiptsEvent {
  const RentReceiptsLoadRequested();
}

class RentReceiptsRefreshRequested extends RentReceiptsEvent {
  const RentReceiptsRefreshRequested();
}

class RentReceiptDownloadRequested extends RentReceiptsEvent {
  final String receiptId;

  const RentReceiptDownloadRequested(this.receiptId);

  @override
  List<Object?> get props => [receiptId];
}

class RentReceiptsMessageCleared extends RentReceiptsEvent {
  const RentReceiptsMessageCleared();
}
