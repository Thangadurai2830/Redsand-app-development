import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../bloc/role_selection_bloc.dart';
import '../bloc/role_selection_event.dart';
import '../bloc/role_selection_state.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RoleSelectionBloc>(),
      child: const _RoleSelectionView(),
    );
  }
}

class _RoleSelectionView extends StatelessWidget {
  const _RoleSelectionView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoleSelectionBloc, RoleSelectionState>(
      listener: (context, state) {
        if (state is RoleSelectionSaved) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LoginPage(selectedRole: state.role),
            ),
          );
        }
        if (state is RoleSelectionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),
                  const Text(
                    'Select your role',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Choose how you want to use the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  BlocBuilder<RoleSelectionBloc, RoleSelectionState>(
                    builder: (context, state) {
                      final selected = state is RoleSelectionPicked
                          ? state.role
                          : state is RoleSelectionSaving
                              ? state.role
                              : null;

                      return Column(
                        children: _roleOptions.map((opt) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _RoleCard(
                              option: opt,
                              isSelected: selected == opt.role,
                              onTap: () => context
                                  .read<RoleSelectionBloc>()
                                  .add(RoleSelected(opt.role)),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                      const SizedBox(height: 24),
                  BlocBuilder<RoleSelectionBloc, RoleSelectionState>(
                    builder: (context, state) {
                      final hasSelection = state is RoleSelectionPicked;
                      final isSaving = state is RoleSelectionSaving;

                      return SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: hasSelection
                              ? () => context
                                  .read<RoleSelectionBloc>()
                                  .add(const RoleConfirmed())
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.deepRoyalPurple,
                            disabledBackgroundColor: Colors.white38,
                            disabledForegroundColor: Colors.white60,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.deepRoyalPurple,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOptionData {
  final UserRole role;
  final String label;
  final String subtitle;
  final IconData icon;

  const _RoleOptionData({
    required this.role,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

const _roleOptions = [
  _RoleOptionData(
    role: UserRole.user,
    label: 'User',
    subtitle: 'Browse and explore listings',
    icon: Icons.person_rounded,
  ),
  _RoleOptionData(
    role: UserRole.owner,
    label: 'Owner',
    subtitle: 'Manage your properties',
    icon: Icons.home_rounded,
  ),
  _RoleOptionData(
    role: UserRole.seller,
    label: 'Seller',
    subtitle: 'List properties for sale',
    icon: Icons.sell_rounded,
  ),
  _RoleOptionData(
    role: UserRole.company,
    label: 'Company',
    subtitle: 'Manage multiple assets as a business',
    icon: Icons.business_rounded,
  ),
];

class _RoleCard extends StatelessWidget {
  final _RoleOptionData option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white30,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.deepRoyalPurple.withOpacity(0.12)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                color: isSelected ? AppColors.deepRoyalPurple : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primaryDarkText
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.subtitle,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.secondaryGrayText
                          : Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.deepRoyalPurple,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
