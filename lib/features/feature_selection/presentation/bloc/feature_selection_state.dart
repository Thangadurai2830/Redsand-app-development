part of 'feature_selection_bloc.dart';

abstract class FeatureSelectionState extends Equatable {
  const FeatureSelectionState();

  @override
  List<Object?> get props => [];
}

class FeatureSelectionInitial extends FeatureSelectionState {}

class FeatureSelectionLoading extends FeatureSelectionState {}

class FeatureSelectionLoaded extends FeatureSelectionState {
  final List<AppFeature> features;
  final bool isSaving;
  final bool savedSuccess;

  const FeatureSelectionLoaded({
    required this.features,
    this.isSaving = false,
    this.savedSuccess = false,
  });

  @override
  List<Object?> get props => [features, isSaving, savedSuccess];
}

class FeatureSelectionError extends FeatureSelectionState {
  final String message;

  const FeatureSelectionError(this.message);

  @override
  List<Object?> get props => [message];
}
