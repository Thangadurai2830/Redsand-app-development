import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/rent_receipts_bloc.dart';
import '../bloc/rent_receipts_event.dart';
import '../bloc/rent_receipts_state.dart';

class RentReceiptsPage extends StatelessWidget {
  const RentReceiptsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RentReceiptsBloc>()..add(const RentReceiptsLoadRequested()),
      child: const _RentReceiptsView(),
    );
  }
}

class _RentReceiptsView extends StatelessWidget {
  const _RentReceiptsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RentReceiptsBloc, RentReceiptsState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.status == RentReceiptsStatus.failure ? Colors.red : Colors.green,
            ),
          );
          context.read<RentReceiptsBloc>().add(const RentReceiptsMessageCleared());
        }
      },
      builder: (context, state) {
        final loadingInitial = state.status == RentReceiptsStatus.loading && !state.hasReceipts;

        return Scaffold(
          backgroundColor: AppColors.lightGrayBg,
          appBar: AppBar(
            backgroundColor: AppColors.deepRoyalPurple,
            foregroundColor: Colors.white,
            title: const Text('Rent Receipts'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: state.downloadingReceiptId == null
                    ? () => context.read<RentReceiptsBloc>().add(const RentReceiptsRefreshRequested())
                    : null,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => context.read<RentReceiptsBloc>().add(const RentReceiptsRefreshRequested()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const _HeroCard(),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Monthly Receipts',
                  subtitle: 'Download receipts for tax filing and personal records.',
                  child: loadingInitial
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.mainPurple),
                          ),
                        )
                      : state.status == RentReceiptsStatus.failure && !state.hasReceipts
                          ? _ErrorState(
                              message: state.message ?? 'Unable to load your rent receipts.',
                              onRetry: () => context.read<RentReceiptsBloc>().add(const RentReceiptsLoadRequested()),
                            )
                          : state.hasReceipts
                              ? Column(
                                  children: [
                                    for (final receipt in state.receipts) ...[
                                      _ReceiptCard(
                                        title: receipt.title,
                                        periodLabel: receipt.periodLabel,
                                        issueDate: receipt.issueDate,
                                        amount: receipt.amount,
                                        status: receipt.status,
                                        referenceNumber: receipt.referenceNumber,
                                        notes: receipt.notes,
                                        isDownloading: state.isDownloading(receipt.id),
                                        onDownload: () => context
                                            .read<RentReceiptsBloc>()
                                            .add(RentReceiptDownloadRequested(receipt.id)),
                                      ),
                                      if (receipt != state.receipts.last) const SizedBox(height: 12),
                                    ],
                                  ],
                                )
                              : const _EmptyState(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepRoyalPurple, AppColors.mainPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rent receipts in one place',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep monthly rent proof ready for tax and records.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDarkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.secondaryGrayText),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final String title;
  final String periodLabel;
  final String issueDate;
  final String amount;
  final String status;
  final String? referenceNumber;
  final String? notes;
  final bool isDownloading;
  final VoidCallback onDownload;

  const _ReceiptCard({
    required this.title,
    required this.periodLabel,
    required this.issueDate,
    required this.amount,
    required this.status,
    required this.referenceNumber,
    required this.notes,
    required this.isDownloading,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.veryLightPurpleBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.receipt_outlined, color: AppColors.mainPurple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDarkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          periodLabel,
                          style: const TextStyle(color: AppColors.secondaryGrayText),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(label: status),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoChip(
                    icon: Icons.calendar_month_outlined,
                    label: issueDate.isEmpty ? 'Date unavailable' : issueDate,
                  ),
                  if (amount.isNotEmpty) _InfoChip(icon: Icons.payments_outlined, label: amount),
                  if (referenceNumber != null && referenceNumber!.isNotEmpty)
                    _InfoChip(icon: Icons.confirmation_number_outlined, label: referenceNumber!),
                ],
              ),
              if (notes != null && notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  notes!,
                  style: const TextStyle(color: AppColors.secondaryGrayText),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isDownloading ? null : onDownload,
                  icon: isDownloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(isDownloading ? 'Downloading' : 'Download PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.deepRoyalPurple),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDarkText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.veryLightPurpleBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.deepRoyalPurple,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(Icons.description_outlined, size: 54, color: AppColors.secondaryGrayText),
          SizedBox(height: 12),
          Text(
            'No rent receipts found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryDarkText),
          ),
          SizedBox(height: 6),
          Text(
            'Once receipts are generated, they will appear here for download.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryGrayText),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 54, color: AppColors.secondaryGrayText),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondaryGrayText),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
