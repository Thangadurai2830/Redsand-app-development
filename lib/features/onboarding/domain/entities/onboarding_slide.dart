import 'package:equatable/equatable.dart';

class OnboardingSlide extends Equatable {
  final String id;
  final String title;
  final String description;
  final String illustration; // asset path or icon name key

  const OnboardingSlide({
    required this.id,
    required this.title,
    required this.description,
    required this.illustration,
  });

  @override
  List<Object?> get props => [id, title, description, illustration];
}
