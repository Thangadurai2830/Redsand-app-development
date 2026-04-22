import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/domain/entities/user_role.dart';
import '../../../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../../../features/role_selection/presentation/pages/role_selection_page.dart';
import '../../../../features/dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../../../features/dashboard/presentation/pages/user_dashboard_page.dart';
import '../../../../features/owner_dashboard/presentation/pages/owner_dashboard_page.dart';
import '../bloc/splash_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    context.read<SplashBloc>().add(const SplashStarted());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate(SplashState state) {
    if (!mounted) return;

    Widget destination;

    if (state is SplashAuthenticated) {
      destination = switch (state.role) {
        UserRole.admin => const AdminDashboardPage(),
        UserRole.owner => const OwnerDashboardPage(),
        _ => const UserDashboardPage(),
      };
    } else if (state is SplashNeedsOnboarding) {
      destination = const OnboardingPage();
    } else {
      destination = const RoleSelectionPage();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => destination,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashAuthenticated ||
            state is SplashUnauthenticated ||
            state is SplashNeedsOnboarding) {
          _navigate(state);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                ScaleTransition(
                  scale: _scaleAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // App name
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Text(
                    'MyApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    'Your tagline here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 15,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),

                const SizedBox(height: 64),

                // Loading indicator
                BlocBuilder<SplashBloc, SplashState>(
                  builder: (context, state) {
                    if (state is SplashLoading) {
                      return SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      );
                    }
                    return const SizedBox(height: 28);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
