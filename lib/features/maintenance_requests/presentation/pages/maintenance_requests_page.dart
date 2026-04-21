import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/maintenance_ticket.dart';
import '../bloc/maintenance_requests_bloc.dart';
import '../bloc/maintenance_requests_event.dart';
import '../bloc/maintenance_requests_state.dart';

class MaintenanceRequestsPage extends StatelessWidget {
  const MaintenanceRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MaintenanceRequestsBloc>()..add(const MaintenanceHistoryRequested()),
      child: const _MaintenanceRequestsView(),
    );
  }
}

class _MaintenanceRequestsView extends StatefulWidget {
  const _MaintenanceRequestsView();

  @override
  State<_MaintenanceRequestsView> createState() => _MaintenanceRequestsViewState();
}

class _MaintenanceRequestsViewState extends State<_MaintenanceRequestsView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final List<_IssueTypeOption> _issueTypes = const [
    _IssueTypeOption('plumbing', 'Plumbing', Icons.water_drop_outlined),
    _IssueTypeOption('electrical', 'Electrical', Icons.electrical_services_outlined),
    _IssueTypeOption('appliance', 'Appliance', Icons.kitchen_outlined),
    _IssueTypeOption('structural', 'Structural', Icons.domain_outlined),
    _IssueTypeOption('cleaning', 'Cleaning', Icons.cleaning_services_outlined),
    _IssueTypeOption('security', 'Security', Icons.security_outlined),
    _IssueTypeOption('other', 'Other', Icons.more_horiz_rounded),
  ];

  String _selectedIssueType = 'plumbing';
  String? _photoPath;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<MaintenanceRequestsBloc>().add(
          MaintenanceRequestSubmitted(
            issueType: _selectedIssueType,
            description: _descriptionController.text.trim(),
            photoPath: _photoPath,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MaintenanceRequestsBloc, MaintenanceRequestsState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.status == MaintenanceRequestsStatus.failure ? Colors.red : Colors.green,
            ),
          );
          context.read<MaintenanceRequestsBloc>().add(const MaintenanceMessageCleared());
        }
      },
      builder: (context, state) {
        final isLoading = state.status == MaintenanceRequestsStatus.loading && !state.hasTickets;

        return Scaffold(
          backgroundColor: AppColors.lightGrayBg,
          appBar: AppBar(
            backgroundColor: AppColors.deepRoyalPurple,
            foregroundColor: Colors.white,
            title: const Text('Maintenance Requests'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: state.isSubmitting
                    ? null
                    : () => context.read<MaintenanceRequestsBloc>().add(const MaintenanceHistoryRequested()),
              ),
            ],
          ),
          body: AbsorbPointer(
            absorbing: state.isSubmitting,
            child: RefreshIndicator(
              onRefresh: () {
                context.read<MaintenanceRequestsBloc>().add(const MaintenanceHistoryRequested());
                return Future.value();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const _HeroCard(),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Raise a Ticket',
                    subtitle: 'Tell us what is broken and attach a photo if you can.',
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedIssueType,
                            decoration: const InputDecoration(
                              labelText: 'Issue type',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: _issueTypes
                                .map(
                                  (option) => DropdownMenuItem(
                                    value: option.value,
                                    child: Row(
                                      children: [
                                        Icon(option.icon, size: 18, color: AppColors.mainPurple),
                                        const SizedBox(width: 8),
                                        Text(option.label),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedIssueType = value);
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Describe the issue, where it is happening, and when it started.',
                              alignLabelWithHint: true,
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 72),
                                child: Icon(Icons.notes_outlined),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description is required';
                              }
                              if (value.trim().length < 15) {
                                return 'Please add a little more detail';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _PhotoAttachmentTile(
                            photoPath: _photoPath,
                            onAttach: _choosePhotoPath,
                            onClear: _photoPath == null ? null : () => setState(() => _photoPath = null),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: state.isSubmitting ? null : _submit,
                              icon: state.isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(state.isSubmitting ? 'Submitting' : 'Raise Ticket'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mainPurple,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Ticket History',
                    subtitle: 'Track the current status of previous maintenance issues.',
                    trailing: state.status == MaintenanceRequestsStatus.loading && state.hasTickets
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.mainPurple),
                            ),
                          )
                        : state.status == MaintenanceRequestsStatus.failure && !state.hasTickets
                            ? _HistoryErrorState(
                                message: state.message ?? 'We could not load your maintenance history.',
                                onRetry: () => context
                                    .read<MaintenanceRequestsBloc>()
                                    .add(const MaintenanceHistoryRequested()),
                              )
                        : state.hasTickets
                            ? Column(
                                children: [
                                  for (final ticket in state.tickets) ...[
                                    _TicketCard(ticket: ticket),
                                    if (ticket != state.tickets.last) const SizedBox(height: 12),
                                  ],
                                ],
                              )
                            : const _EmptyHistory(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _choosePhotoPath() async {
    final controller = TextEditingController(text: _photoPath ?? '');
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attach Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Paste a local image path or a photo reference URL.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Photo path or URL',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final value = controller.text.trim();
                          Navigator.of(sheetContext).pop(value.isEmpty ? null : value);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Attach'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();
    if (result != null) {
      setState(() => _photoPath = result);
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need something fixed?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Raise a maintenance ticket and track open, in-progress, and resolved requests in one place.',
                  style: TextStyle(color: Colors.white.withOpacity(0.82)),
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
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
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
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PhotoAttachmentTile extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onAttach;
  final VoidCallback? onClear;

  const _PhotoAttachmentTile({
    required this.photoPath,
    required this.onAttach,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilePreview = photoPath != null &&
        photoPath!.trim().isNotEmpty &&
        File(photoPath!).existsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.mainPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.upload_file_rounded, color: AppColors.mainPurple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Photo upload',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDarkText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      photoPath == null || photoPath!.trim().isEmpty
                          ? 'Add a photo to help the maintenance team inspect the issue faster.'
                          : photoPath!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.secondaryGrayText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasFilePreview) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(photoPath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAttach,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(photoPath == null ? 'Attach Photo' : 'Change Photo'),
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Remove photo',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final MaintenanceTicket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final status = _TicketStatusVisual.fromStatus(ticket.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGray),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatIssueType(ticket.issueType),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkText,
                  ),
                ),
              ),
              _StatusChip(label: status.label, backgroundColor: status.backgroundColor, textColor: status.textColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.description,
            style: const TextStyle(color: AppColors.secondaryGrayText, height: 1.4),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.schedule_outlined,
                label: _formatDateTime(ticket.createdAt),
              ),
              if ((ticket.propertyName ?? '').trim().isNotEmpty)
                _MetaChip(
                  icon: Icons.home_work_outlined,
                  label: ticket.propertyName!.trim(),
                ),
            ],
          ),
          if ((ticket.photoUrl ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGrayBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo_outlined, color: AppColors.mainPurple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Photo attached',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryDarkText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatIssueType(String value) {
    final normalized = value.trim().replaceAll('-', ' ');
    return normalized.isEmpty
        ? 'Maintenance Issue'
        : normalized.split(' ').map((part) {
            if (part.isEmpty) return part;
            return part[0].toUpperCase() + part.substring(1);
          }).join(' ');
  }

  String _formatDateTime(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = value.day.toString().padLeft(2, '0');
    final month = months[value.month - 1];
    final year = value.year;
    var hour = value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$day $month $year, ${hour.toString().padLeft(2, '0')}:$minute $suffix';
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.secondaryGrayText),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryGrayText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TicketStatusVisual {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _TicketStatusVisual({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  static _TicketStatusVisual fromStatus(String rawStatus) {
    final status = rawStatus.trim().toLowerCase();
    switch (status) {
      case 'in-progress':
      case 'in progress':
      case 'working':
        return const _TicketStatusVisual(
          label: 'In Progress',
          backgroundColor: AppColors.softSkyBlue,
          textColor: AppColors.cyanBlue,
        );
      case 'resolved':
      case 'closed':
      case 'done':
        return const _TicketStatusVisual(
          label: 'Resolved',
          backgroundColor: AppColors.lightMint,
          textColor: AppColors.mintGreen,
        );
      case 'open':
      default:
        return const _TicketStatusVisual(
          label: 'Open',
          backgroundColor: AppColors.warmCream,
          textColor: Color(0xFFE08A00),
        );
    }
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: const [
          Icon(Icons.inbox_outlined, size: 44, color: AppColors.secondaryGrayText),
          SizedBox(height: 12),
          Text(
            'No maintenance tickets yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDarkText,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your raised issues will appear here once you submit the first request.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryGrayText),
          ),
        ],
      ),
    );
  }
}

class _HistoryErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HistoryErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 44, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text(
            'Unable to load history',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDarkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondaryGrayText),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _IssueTypeOption {
  final String value;
  final String label;
  final IconData icon;

  const _IssueTypeOption(this.value, this.label, this.icon);
}
