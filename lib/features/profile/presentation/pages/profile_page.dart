import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/kyc_submission_request.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/entities/site_visit_record.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
          context.read<ProfileBloc>().add(const ProfileMessageCleared());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.lightGrayBg,
          appBar: AppBar(
            backgroundColor: AppColors.deepRoyalPurple,
            foregroundColor: Colors.white,
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: state.status == ProfileStatus.loading
                    ? null
                    : () => context.read<ProfileBloc>().add(const ProfileRefreshRequested()),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state.status == ProfileStatus.loading || state.status == ProfileStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mainPurple),
      );
    }

    if (state.status == ProfileStatus.failure && state.profile == null) {
      return _EmptyState(
        icon: Icons.person_off_outlined,
        title: 'Unable to load profile',
        subtitle: state.message ?? 'Please try again in a moment.',
        actionLabel: 'Retry',
        onAction: () => context.read<ProfileBloc>().add(const ProfileLoadRequested()),
      );
    }

    final profile = state.profile;
    if (profile == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<ProfileBloc>().add(const ProfileRefreshRequested()),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _ProfileHeader(profile: profile),
          const SizedBox(height: 16),
          _ActionGrid(
            onEdit: () => _showEditProfileSheet(context, profile),
            onUploadAadhaar: () => _showReferenceDialog(
              context,
              title: 'Upload Aadhaar',
              hint: 'Enter Aadhaar file path or document reference',
              onSubmit: (value) => context.read<ProfileBloc>().add(AadhaarUploadRequested(value)),
            ),
            onUploadPan: () => _showReferenceDialog(
              context,
              title: 'Upload PAN',
              hint: 'Enter PAN file path or document reference',
              onSubmit: (value) => context.read<ProfileBloc>().add(PanUploadRequested(value)),
            ),
            onVerifyKyc: () => context.read<ProfileBloc>().add(const KycVerificationRequested()),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Profile Details',
            icon: Icons.person_outline_rounded,
            child: Column(
              children: [
                _DetailRow(label: 'Full name', value: profile.fullName),
                _DetailRow(label: 'Email', value: profile.email.isEmpty ? 'Not set' : profile.email),
                _DetailRow(label: 'Phone', value: profile.phone.isEmpty ? 'Not set' : profile.phone),
                _DetailRow(label: 'Address', value: profile.address.isEmpty ? 'Not set' : profile.address),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'KYC Verification',
            icon: Icons.verified_user_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusChip(
                      label: 'Status: ${profile.kycStatus}',
                      color: profile.isKycComplete ? AppColors.mintGreen : AppColors.cyanBlue,
                    ),
                    _StatusChip(
                      label: profile.aadhaarVerified ? 'Aadhaar verified' : 'Aadhaar pending',
                      color: profile.aadhaarVerified ? AppColors.mintGreen : AppColors.softSkyBlue,
                    ),
                    _StatusChip(
                      label: profile.panVerified ? 'PAN verified' : 'PAN pending',
                      color: profile.panVerified ? AppColors.mintGreen : AppColors.softPink,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  profile.verificationMessage,
                  style: const TextStyle(color: AppColors.secondaryGrayText),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isSubmittingKyc
                        ? null
                        : () => _showKycSubmissionSheet(context),
                    icon: state.isSubmittingKyc
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.upload_file_rounded),
                    label: const Text('KYC Verification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepRoyalPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _VisitsSection(
            visits: state.visits,
            isLoading: state.isLoadingVisits,
            onRefresh: () => context.read<ProfileBloc>().add(const VisitHistoryRefreshRequested()),
            onDownloadReceipt: (visit) => _showReceiptLink(context, visit),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfileSheet(BuildContext context, UserProfile profile) async {
    final nameController = TextEditingController(text: profile.fullName);
    final phoneController = TextEditingController(text: profile.phone);
    final addressController = TextEditingController(text: profile.address);
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Phone is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Address is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        context.read<ProfileBloc>().add(
                              ProfileUpdateRequested(
                                ProfileUpdateRequest(
                                  fullName: nameController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  address: addressController.text.trim(),
                                ),
                              ),
                            );
                        Navigator.of(sheetContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }

  Future<void> _showReferenceDialog(
    BuildContext context, {
    required String title,
    required String hint,
    required void Function(String value) onSubmit,
  }) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                onSubmit(value);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  Future<void> _showKycSubmissionSheet(BuildContext context) async {
    final aadhaarController = TextEditingController();
    final panController = TextEditingController();
    final notesController = TextEditingController(text: 'KYC documents submitted from profile page');
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
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
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KYC Submission',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: aadhaarController,
                      decoration: const InputDecoration(
                        labelText: 'Aadhaar file path / reference',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: panController,
                      decoration: const InputDecoration(
                        labelText: 'PAN file path / reference',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ProfileBloc>().add(
                                KycSubmissionRequested(
                                  KycSubmissionRequest(
                                    aadhaarReference: aadhaarController.text.trim(),
                                    panReference: panController.text.trim(),
                                    notes: notesController.text.trim(),
                                  ),
                                ),
                              );
                          Navigator.of(sheetContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepRoyalPurple,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Submit KYC'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    aadhaarController.dispose();
    panController.dispose();
    notesController.dispose();
  }

  Future<void> _showReceiptLink(BuildContext context, SiteVisitRecord visit) async {
    if (visit.receiptUrl == null || visit.receiptUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rent receipt is not available for this visit yet.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rent Receipt'),
          content: SelectableText(visit.receiptUrl!),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: visit.receiptUrl!));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Copy link'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainPurple.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.18),
            child: Text(
              profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email.isEmpty ? 'No email on file' : profile.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onUploadAadhaar;
  final VoidCallback onUploadPan;
  final VoidCallback onVerifyKyc;

  const _ActionGrid({
    required this.onEdit,
    required this.onUploadAadhaar,
    required this.onUploadPan,
    required this.onVerifyKyc,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ActionTile(
          icon: Icons.edit_outlined,
          label: 'Edit profile',
          color: AppColors.deepRoyalPurple,
          onTap: onEdit,
        ),
        _ActionTile(
          icon: Icons.badge_outlined,
          label: 'Upload Aadhaar',
          color: AppColors.cyanBlue,
          onTap: onUploadAadhaar,
        ),
        _ActionTile(
          icon: Icons.credit_card_outlined,
          label: 'Upload PAN',
          color: AppColors.mintGreen,
          onTap: onUploadPan,
        ),
        _ActionTile(
          icon: Icons.verified_outlined,
          label: 'KYC verification',
          color: AppColors.mainPurple,
          onTap: onVerifyKyc,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkText,
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

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.deepRoyalPurple),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDarkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryGrayText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.primaryDarkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _VisitsSection extends StatelessWidget {
  final List<SiteVisitRecord> visits;
  final bool isLoading;
  final VoidCallback onRefresh;
  final ValueChanged<SiteVisitRecord> onDownloadReceipt;

  const _VisitsSection({
    required this.visits,
    required this.isLoading,
    required this.onRefresh,
    required this.onDownloadReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Visit History',
      icon: Icons.history_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  visits.isEmpty ? 'No visits recorded yet' : '${visits.length} visits found',
                  style: const TextStyle(
                    color: AppColors.secondaryGrayText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: isLoading ? null : onRefresh,
                icon: isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (visits.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your previous site visits will appear here once they are available from the backend.',
                style: TextStyle(color: AppColors.secondaryGrayText),
              ),
            )
          else
            ...visits.map(
              (visit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _VisitCard(
                  visit: visit,
                  onDownloadReceipt: () => onDownloadReceipt(visit),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final SiteVisitRecord visit;
  final VoidCallback onDownloadReceipt;

  const _VisitCard({
    required this.visit,
    required this.onDownloadReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (visit.status.toLowerCase()) {
      'completed' => AppColors.mintGreen,
      'cancelled' => Colors.redAccent,
      _ => AppColors.cyanBlue,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  visit.propertyName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkText,
                  ),
                ),
              ),
              _StatusChip(label: visit.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            visit.propertyAddress.isEmpty ? visit.notes : visit.propertyAddress,
            style: const TextStyle(color: AppColors.secondaryGrayText),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.secondaryGrayText),
              const SizedBox(width: 6),
              Text(
                visit.visitDate,
                style: const TextStyle(color: AppColors.primaryDarkText),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.schedule_outlined, size: 16, color: AppColors.secondaryGrayText),
              const SizedBox(width: 6),
              Text(
                visit.visitTime,
                style: const TextStyle(color: AppColors.primaryDarkText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onDownloadReceipt,
              icon: const Icon(Icons.receipt_long_outlined, size: 16),
              label: const Text('Rent receipt download'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: AppColors.mainPurple),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondaryGrayText),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepRoyalPurple,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
