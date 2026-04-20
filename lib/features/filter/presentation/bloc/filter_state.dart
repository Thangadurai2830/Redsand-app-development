import 'package:equatable/equatable.dart';
import '../../domain/entities/filter_entity.dart';

abstract class FilterState extends Equatable {
  const FilterState();
  @override
  List<Object?> get props => [];
}

class FilterInitial extends FilterState {
  final FilterEntity filter;
  const FilterInitial({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class FilterChanged extends FilterState {
  final FilterEntity filter;
  const FilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class FilterAppliedState extends FilterState {
  final FilterEntity filter;
  const FilterAppliedState({required this.filter});

  @override
  List<Object?> get props => [filter];
}
