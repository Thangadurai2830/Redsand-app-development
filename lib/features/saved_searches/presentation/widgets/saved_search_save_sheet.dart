import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../filter/domain/entities/filter_entity.dart';
import '../bloc/saved_searches_bloc.dart';
import '../bloc/saved_searches_event.dart';
import '../bloc/saved_searches_state.dart';

class SavedSearchSaveSheet extends StatefulWidget {
  final String query;
  final FilterEntity filter;

  const SavedSearchSaveSheet({
    super.key,
    required this.query,
    required this.filter,
  });

  @override
  State<SavedSearchSaveSheet> createState() => _SavedSearchSaveSheetState();
}

class _SavedSearchSaveSheetState extends State<SavedSearchSaveSheet> {
  late bool _notifyByPush;
  late bool _notifyInApp;
  late bool _priceDropAlert;

  @override
  void initState() {
    super.initState();
    _notifyByPush = true;
    _notifyInApp = true;
    _priceDropAlert = false;
  }

  bool get _canSave => widget.query.trim().isNotEmpty || widget.filter.hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedSearchesBloc, SavedSearchesState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderGray,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Save Search Alert',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _description,
                    style: const TextStyle(
                      color: AppColors.secondaryGrayText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SummaryCard(
                    query: widget.query,
                    filter: widget.filter,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push notification'),
                    subtitle: const Text('Notify me on new matching listings'),
                    value: _notifyByPush,
                    onChanged: (value) => setState(() => _notifyByPush = value),
                    activeColor: AppColors.mainPurple,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('In-app alert'),
                    subtitle: const Text('Show this alert inside the app'),
                    value: _notifyInApp,
                    onChanged: (value) => setState(() => _notifyInApp = value),
                    activeColor: AppColors.mainPurple,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Price drop alert'),
                    subtitle: const Text('Notify me if a saved match gets cheaper'),
                    value: _priceDropAlert,
                    onChanged: (value) => setState(() => _priceDropAlert = value),
                    activeColor: AppColors.mainPurple,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.isSaving ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDarkText,
                            side: const BorderSide(color: AppColors.borderGray),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: !_canSave || state.isSaving
                              ? null
                              : () {
                                  context.read<SavedSearchesBloc>().add(
                                        SavedSearchesSaveRequested(
                                          query: widget.query.trim(),
                                          filter: widget.filter,
                                          notifyByPush: _notifyByPush,
                                          notifyInApp: _notifyInApp,
                                          priceDropAlert: _priceDropAlert,
                                        ),
                                      );
                                  Navigator.of(context).pop();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepRoyalPurple,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: state.isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save Alert'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String get _description {
    final query = widget.query.trim();
    if (query.isNotEmpty && widget.filter.hasActiveFilters) {
      return 'We will alert you when new listings match "$query" and the selected filters.';
    }
    if (query.isNotEmpty) {
      return 'We will alert you when new listings match "$query".';
    }
    return 'We will alert you when new listings match the selected filters.';
  }
}

class _SummaryCard extends StatelessWidget {
  final String query;
  final FilterEntity filter;

  const _SummaryCard({
    required this.query,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _Chip(text: filter.listingFor == 'buy' ? 'Buy' : 'Rent'),
      if (filter.propertyType != null) _Chip(text: filter.propertyType!.toUpperCase()),
      if (filter.city != null && filter.city!.trim().isNotEmpty) _Chip(text: filter.city!.trim()),
      if (filter.locality != null && filter.locality!.trim().isNotEmpty) _Chip(text: filter.locality!.trim()),
      if (filter.minBedrooms != null) _Chip(text: '${filter.minBedrooms} BHK'),
      if (filter.minPrice != null || filter.maxPrice != null)
        _Chip(text: _priceRangeLabel(filter)),
      if (query.trim().isNotEmpty) _Chip(text: '"${query.trim()}"'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips.isEmpty ? [_Chip(text: 'No filters selected')] : chips,
      ),
    );
  }

  String _priceRangeLabel(FilterEntity filter) {
    final min = filter.minPrice;
    final max = filter.maxPrice;
    if (min != null && max != null) return '₹${_formatCompact(min)} - ₹${_formatCompact(max)}';
    if (min != null) return 'From ₹${_formatCompact(min)}';
    if (max != null) return 'Up to ₹${_formatCompact(max)}';
    return 'Budget';
  }

  String _formatCompact(double value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(0)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toInt().toString();
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryDarkText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
