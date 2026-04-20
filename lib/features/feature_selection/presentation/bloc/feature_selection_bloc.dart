import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/app_feature.dart';
import '../../domain/usecases/get_features.dart';
import '../../domain/usecases/toggle_feature.dart';
import '../../domain/usecases/save_features.dart';
import '../../../../core/usecases/usecase.dart';

part 'feature_selection_event.dart';
part 'feature_selection_state.dart';

class FeatureSelectionBloc extends Bloc<FeatureSelectionEvent, FeatureSelectionState> {
  final GetFeatures getFeatures;
  final ToggleFeature toggleFeature;
  final SaveFeatures saveFeatures;

  FeatureSelectionBloc({
    required this.getFeatures,
    required this.toggleFeature,
    required this.saveFeatures,
  }) : super(FeatureSelectionInitial()) {
    on<LoadFeatures>(_onLoadFeatures);
    on<ToggleFeatureEvent>(_onToggleFeature);
    on<SaveFeaturesEvent>(_onSaveFeatures);
  }

  Future<void> _onLoadFeatures(LoadFeatures event, Emitter<FeatureSelectionState> emit) async {
    emit(FeatureSelectionLoading());
    final result = await getFeatures(NoParams());
    result.fold(
      (failure) => emit(const FeatureSelectionError('Failed to load features')),
      (features) => emit(FeatureSelectionLoaded(features: features)),
    );
  }

  Future<void> _onToggleFeature(ToggleFeatureEvent event, Emitter<FeatureSelectionState> emit) async {
    final currentState = state;
    if (currentState is! FeatureSelectionLoaded) return;

    final result = await toggleFeature(
      ToggleFeatureParams(featureId: event.featureId, isEnabled: event.isEnabled),
    );
    result.fold(
      (failure) => emit(const FeatureSelectionError('Failed to toggle feature')),
      (updatedFeature) {
        final updatedList = currentState.features.map((f) {
          return f.id == updatedFeature.id ? updatedFeature : f;
        }).toList();
        emit(FeatureSelectionLoaded(features: updatedList, savedSuccess: false));
      },
    );
  }

  Future<void> _onSaveFeatures(SaveFeaturesEvent event, Emitter<FeatureSelectionState> emit) async {
    final currentState = state;
    if (currentState is! FeatureSelectionLoaded) return;

    emit(FeatureSelectionLoaded(features: currentState.features, isSaving: true));
    final result = await saveFeatures(SaveFeaturesParams(features: currentState.features));
    result.fold(
      (failure) => emit(const FeatureSelectionError('Failed to save features')),
      (_) => emit(FeatureSelectionLoaded(features: currentState.features, savedSuccess: true)),
    );
  }
}
