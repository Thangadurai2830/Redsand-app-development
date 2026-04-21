import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/listing_entity.dart';
import '../bloc/schedule_visit_bloc.dart';
import '../bloc/schedule_visit_event.dart';
import '../bloc/schedule_visit_state.dart';

class ScheduleVisitPage extends StatelessWidget {
  final ListingEntity listing;

  const ScheduleVisitPage({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ScheduleVisitBloc>(),
      child: _ScheduleVisitForm(listing: listing),
    );
  }
}

class _ScheduleVisitForm extends StatefulWidget {
  final ListingEntity listing;

  const _ScheduleVisitForm({required this.listing});

  @override
  State<_ScheduleVisitForm> createState() => _ScheduleVisitFormState();
}

class _ScheduleVisitFormState extends State<_ScheduleVisitForm> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose both date and time')),
      );
      return;
    }

    context.read<ScheduleVisitBloc>().add(
          ScheduleVisitSubmitted(
            listing: widget.listing,
            visitDate: _selectedDate!,
            visitTime: _formatTime(_selectedTime!),
            message: _messageController.text.trim(),
          ),
        );
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleVisitBloc, ScheduleVisitState>(
      listener: (context, state) {
        if (state is ScheduleVisitFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is ScheduleVisitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Future.delayed(const Duration(milliseconds: 250), () {
            if (!mounted) return;
            Navigator.of(context).pop(true);
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is ScheduleVisitLoading;

        return Scaffold(
          backgroundColor: AppColors.lightGrayBg,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkText),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Schedule Visit',
              style: TextStyle(
                color: AppColors.primaryDarkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: AbsorbPointer(
            absorbing: isLoading,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ListingCard(listing: widget.listing),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _InputSection(
                        title: 'Preferred Date',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _selectedDate == null ? 'Select date' : _formatDate(_selectedDate!),
                          ),
                          trailing: const Icon(Icons.calendar_month_outlined),
                          onTap: () => _pickDate(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InputSection(
                        title: 'Preferred Time',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _selectedTime == null ? 'Select time' : _selectedTime!.format(context),
                          ),
                          trailing: const Icon(Icons.schedule_outlined),
                          onTap: () => _pickTime(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InputSection(
                        title: 'Message',
                        child: TextFormField(
                          controller: _messageController,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: 'Share any notes for the owner',
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Message is required';
                            }
                            if (value.trim().length < 10) {
                              return 'Please add a little more detail';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainPurple,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Confirm Visit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }
}

class _ListingCard extends StatelessWidget {
  final ListingEntity listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.title,
            style: const TextStyle(
              color: AppColors.primaryDarkText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${listing.locality}, ${listing.city}',
            style: const TextStyle(color: AppColors.secondaryGrayText),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event_available_outlined, size: 18, color: AppColors.mainPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Owner will be notified after you confirm a preferred slot.',
                  style: TextStyle(
                    color: AppColors.secondaryGrayText.withOpacity(0.95),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InputSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryDarkText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: child,
        ),
      ],
    );
  }
}
