import '../../domain/entities/onboarding_slide.dart';

class OnboardingSlideModel extends OnboardingSlide {
  const OnboardingSlideModel({
    required super.id,
    required super.title,
    required super.description,
    required super.illustration,
  });

  factory OnboardingSlideModel.fromJson(Map<String, dynamic> json) =>
      OnboardingSlideModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        illustration: json['illustration'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'illustration': illustration,
      };

  /// Fallback slides used when the API is unreachable.
  static List<OnboardingSlideModel> get defaults => const [
        OnboardingSlideModel(
          id: 'slide_1',
          title: 'Find Rental Properties',
          description:
              'Browse thousands of verified rental listings near you — filter by price, size, and amenities.',
          illustration: 'rental',
        ),
        OnboardingSlideModel(
          id: 'slide_2',
          title: 'Buy & Sell Properties',
          description:
              'List your property or discover your dream home with transparent pricing and zero hidden fees.',
          illustration: 'buy_sell',
        ),
        OnboardingSlideModel(
          id: 'slide_3',
          title: 'Direct Owner Connection',
          description:
              'Chat directly with property owners — no middlemen, faster decisions, better deals.',
          illustration: 'connect',
        ),
      ];
}
