import 'package:dartz/dartz.dart';
import 'package:flutter_app/core/error/failures.dart';
import 'package:flutter_app/features/feature_selection/domain/entities/app_feature.dart';
import 'package:flutter_app/features/feature_selection/presentation/bloc/feature_selection_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_fakes.dart';

AppFeature _feature({
  String id = 'feat-1',
  String name = 'Dark Mode',
  bool isEnabled = false,
}) =>
    AppFeature(
      id: id,
      name: name,
      description: 'Enable dark theme',
      category: FeatureCategory.settings,
      isEnabled: isEnabled,
    );

FeatureSelectionBloc _bloc({
  required FakeGetFeatures get,
  required FakeToggleFeature toggle,
  required FakeSaveFeatures save,
}) =>
    FeatureSelectionBloc(
      getFeatures: get,
      toggleFeature: toggle,
      saveFeatures: save,
    );

void main() {
  group('FeatureSelectionBloc – LoadFeatures', () {
    test('emits Loading then Loaded on success', () async {
      final feature = _feature();
      final bloc = _bloc(
        get: FakeGetFeatures(Right([feature])),
        toggle: FakeToggleFeature(Right(feature)),
        save: FakeSaveFeatures(const Right(null)),
      );

      bloc.add(const LoadFeatures());
      final states = await bloc.stream.take(2).toList();
      expect(states[0], isA<FeatureSelectionLoading>());
      expect(states[1], isA<FeatureSelectionLoaded>());
      expect((states[1] as FeatureSelectionLoaded).features, [feature]);
      await bloc.close();
    });

    test('emits Loading then Error on failure', () async {
      final bloc = _bloc(
        get: FakeGetFeatures(Left(NetworkFailure())),
        toggle: FakeToggleFeature(Left(NetworkFailure())),
        save: FakeSaveFeatures(const Right(null)),
      );

      bloc.add(const LoadFeatures());
      final states = await bloc.stream.take(2).toList();
      expect(states[0], isA<FeatureSelectionLoading>());
      expect(states[1], isA<FeatureSelectionError>());
      expect((states[1] as FeatureSelectionError).message, 'Failed to load features');
      await bloc.close();
    });

    test('initial state is FeatureSelectionInitial', () {
      final bloc = _bloc(
        get: FakeGetFeatures(const Right([])),
        toggle: FakeToggleFeature(Left(NetworkFailure())),
        save: FakeSaveFeatures(const Right(null)),
      );
      expect(bloc.state, isA<FeatureSelectionInitial>());
      bloc.close();
    });
  });

  group('FeatureSelectionBloc – ToggleFeatureEvent', () {
    test('updates the toggled feature in the list', () async {
      final feature = _feature(id: 'f-1', isEnabled: false);
      final toggled = _feature(id: 'f-1', isEnabled: true);

      final bloc = _bloc(
        get: FakeGetFeatures(Right([feature])),
        toggle: FakeToggleFeature(Right(toggled)),
        save: FakeSaveFeatures(const Right(null)),
      );

      // Load first
      bloc.add(const LoadFeatures());
      await bloc.stream.firstWhere((s) => s is FeatureSelectionLoaded);

      bloc.add(const ToggleFeatureEvent(featureId: 'f-1', isEnabled: true));
      final state = await bloc.stream.firstWhere((s) => s is FeatureSelectionLoaded);

      final loaded = state as FeatureSelectionLoaded;
      expect(loaded.features.first.isEnabled, isTrue);
      await bloc.close();
    });

    test('emits Error when toggle fails', () async {
      final feature = _feature();

      final bloc = _bloc(
        get: FakeGetFeatures(Right([feature])),
        toggle: FakeToggleFeature(Left(NetworkFailure())),
        save: FakeSaveFeatures(const Right(null)),
      );

      bloc.add(const LoadFeatures());
      await bloc.stream.firstWhere((s) => s is FeatureSelectionLoaded);

      bloc.add(const ToggleFeatureEvent(featureId: 'feat-1', isEnabled: true));
      final state = await bloc.stream.firstWhere((s) => s is FeatureSelectionError);

      expect((state as FeatureSelectionError).message, 'Failed to toggle feature');
      await bloc.close();
    });

    test('does nothing when state is not Loaded', () async {
      final bloc = _bloc(
        get: FakeGetFeatures(const Right([])),
        toggle: FakeToggleFeature(Left(NetworkFailure())),
        save: FakeSaveFeatures(const Right(null)),
      );

      // Do NOT load — state stays FeatureSelectionInitial
      bloc.add(const ToggleFeatureEvent(featureId: 'any', isEnabled: true));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<FeatureSelectionInitial>());
      await bloc.close();
    });

    test('keeps other features unchanged when toggling one', () async {
      final f1 = _feature(id: 'f-1', name: 'Dark Mode', isEnabled: false);
      final f2 = _feature(id: 'f-2', name: 'Push Notifications', isEnabled: true);
      final f1Toggled = _feature(id: 'f-1', name: 'Dark Mode', isEnabled: true);

      final bloc = _bloc(
        get: FakeGetFeatures(Right([f1, f2])),
        toggle: FakeToggleFeature(Right(f1Toggled)),
        save: FakeSaveFeatures(const Right(null)),
      );

      bloc.add(const LoadFeatures());
      await bloc.stream.firstWhere((s) => s is FeatureSelectionLoaded);

      bloc.add(const ToggleFeatureEvent(featureId: 'f-1', isEnabled: true));
      final state = await bloc.stream.firstWhere((s) => s is FeatureSelectionLoaded);

      final loaded = state as FeatureSelectionLoaded;
      expect(loaded.features.length, 2);
      expect(loaded.features.firstWhere((f) => f.id == 'f-2').isEnabled, isTrue);
      await bloc.close();
    });
  });

  group('FeatureSelectionBloc – SaveFeaturesEvent', () {
    test('emits isSaving then savedSuccess on success', () async {
      final feature = _feature();

      final bloc = _bloc(
        get: FakeGetFeatures(Right([feature])),
        toggle: FakeToggleFeature(Right(feature)),
        save: FakeSaveFeatures(const Right(null)),
      );

      bloc.add(const LoadFeatures());
      await bloc.stream.firstWhere((s) => s is FeatureSelectionLoaded);

      bloc.add(const SaveFeaturesEvent());
      final states = await bloc.stream.take(2).toList();
      expect((states[0] as FeatureSelectionLoaded).isSaving, isTrue);
      expect((states[1] as FeatureSelectionLoaded).isSaving, isFalse);
      expect((states[1] as FeatureSelectionLoaded).savedSuccess, isTrue);
      await bloc.close();
    });

    test('emits Error when save fails', () async {
      final feature = _feature();

      final bloc = _bloc(
        get: FakeGetFeatures(Right([feature])),
        toggle: FakeToggleFeature(Right(feature)),
        save: FakeSaveFeatures(Left(NetworkFailure())),
      );

      bloc.add(const LoadFeatures());
      await bloc.stream.firstWhere((s) => s is FeatureSelectionLoaded);

      bloc.add(const SaveFeaturesEvent());
      final state = await bloc.stream.firstWhere((s) => s is FeatureSelectionError);

      expect((state as FeatureSelectionError).message, 'Failed to save features');
      await bloc.close();
    });

    test('does nothing when state is not Loaded', () async {
      final bloc = _bloc(
        get: FakeGetFeatures(const Right([])),
        toggle: FakeToggleFeature(Left(NetworkFailure())),
        save: FakeSaveFeatures(const Right(null)),
      );

      bloc.add(const SaveFeaturesEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<FeatureSelectionInitial>());
      await bloc.close();
    });
  });
}
