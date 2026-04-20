import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/domain/entities/onboarding_slide.dart';
import '../../../role_selection/presentation/pages/role_selection_page.dart';
import '../bloc/onboarding_bloc.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OnboardingBloc>()..add(const OnboardingStarted()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingFinished) _goToLogin();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: SafeArea(
            child: BlocBuilder<OnboardingBloc, OnboardingState>(
              builder: (context, state) {
                if (state is OnboardingLoading || state is OnboardingInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (state is OnboardingError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (state is OnboardingLoaded) {
                  return _SlidesLayout(
                    state: state,
                    pageController: _pageController,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SlidesLayout extends StatelessWidget {
  final OnboardingLoaded state;
  final PageController pageController;

  const _SlidesLayout({
    required this.state,
    required this.pageController,
  });

  void _next(BuildContext context) {
    if (state.isLastPage) {
      context.read<OnboardingBloc>().add(const OnboardingCompleted());
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip(BuildContext context) {
    context.read<OnboardingBloc>().add(const OnboardingSkipped());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Skip button
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: state.isLastPage
                ? const SizedBox(height: 40)
                : TextButton(
                    onPressed: () => _skip(context),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
        ),

        // Slides
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemCount: state.slides.length,
            onPageChanged: (i) => context
                .read<OnboardingBloc>()
                .add(OnboardingPageChanged(i)),
            itemBuilder: (_, i) => _SlideCard(slide: state.slides[i]),
          ),
        ),

        // Indicator
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SmoothPageIndicator(
            controller: pageController,
            count: state.slides.length,
            effect: const ExpandingDotsEffect(
              activeDotColor: Colors.white,
              dotColor: Colors.white38,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
            ),
          ),
        ),

        // Action button
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _next(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.deepRoyalPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                state.isLastPage ? 'Get Started' : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideCard extends StatelessWidget {
  final OnboardingSlide slide;

  const _SlideCard({required this.slide});

  IconData _iconFor(String key) {
    switch (key) {
      case 'rental':
        return Icons.home_work_rounded;
      case 'buy_sell':
        return Icons.sell_rounded;
      case 'connect':
        return Icons.connect_without_contact_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration container
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Icon(
              _iconFor(slide.illustration),
              size: 88,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 48),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
