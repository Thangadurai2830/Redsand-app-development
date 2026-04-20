part of 'feature_selection_bloc.dart';

abstract class FeatureSelectionEvent extends Equatable {
  const FeatureSelectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeatures extends FeatureSelectionEvent {
  const LoadFeatures();
}

class ToggleFeatureEvent extends FeatureSelectionEvent {
  final String featureId;
  final bool isEnabled;

  const ToggleFeatureEvent({required this.featureId, required this.isEnabled});

  @override
  List<Object?> get props => [featureId, isEnabled];
}

class SaveFeaturesEvent extends FeatureSelectionEvent {
  const SaveFeaturesEvent();
}
