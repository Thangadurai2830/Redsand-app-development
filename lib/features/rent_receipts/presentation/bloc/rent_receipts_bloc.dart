import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/download_rent_receipt.dart';
import '../../domain/usecases/get_rent_receipts.dart';
import 'rent_receipts_event.dart';
import 'rent_receipts_state.dart';

class RentReceiptsBloc extends Bloc<RentReceiptsEvent, RentReceiptsState> {
  final GetRentReceipts getRentReceipts;
  final DownloadRentReceipt downloadRentReceipt;

  RentReceiptsBloc({
    required this.getRentReceipts,
    required this.downloadRentReceipt,
  }) : super(const RentReceiptsState.initial()) {
    on<RentReceiptsLoadRequested>(_onLoadRequested);
    on<RentReceiptsRefreshRequested>(_onRefreshRequested);
    on<RentReceiptDownloadRequested>(_onDownloadRequested);
    on<RentReceiptsMessageCleared>(_onMessageCleared);
  }

  Future<void> _onLoadRequested(
    RentReceiptsLoadRequested event,
    Emitter<RentReceiptsState> emit,
  ) async {
    emit(state.copyWith(status: RentReceiptsStatus.loading, clearMessage: true));
    final result = await getRentReceipts(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: RentReceiptsStatus.failure,
        message: _messageForFailure(failure),
      )),
      (receipts) => emit(state.copyWith(
        status: RentReceiptsStatus.loaded,
        receipts: receipts,
      )),
    );
  }

  Future<void> _onRefreshRequested(
    RentReceiptsRefreshRequested event,
    Emitter<RentReceiptsState> emit,
  ) async {
    await _onLoadRequested(const RentReceiptsLoadRequested(), emit);
  }

  Future<void> _onDownloadRequested(
    RentReceiptDownloadRequested event,
    Emitter<RentReceiptsState> emit,
  ) async {
    emit(state.copyWith(downloadingReceiptId: event.receiptId, clearMessage: true));
    final result = await downloadRentReceipt(DownloadRentReceiptParams(event.receiptId));
    result.fold(
      (failure) => emit(state.copyWith(
        downloadingReceiptId: null,
        status: state.receipts.isEmpty ? RentReceiptsStatus.failure : state.status,
        message: _messageForFailure(failure),
      )),
      (path) => emit(state.copyWith(
        downloadingReceiptId: null,
        message: 'Receipt downloaded to $path',
      )),
    );
  }

  void _onMessageCleared(
    RentReceiptsMessageCleared event,
    Emitter<RentReceiptsState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }

  String _messageForFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Unable to reach rent receipt service. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
