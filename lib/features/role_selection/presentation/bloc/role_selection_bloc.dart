import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/save_selected_role.dart';
import 'role_selection_event.dart';
import 'role_selection_state.dart';

class RoleSelectionBloc extends Bloc<RoleSelectionEvent, RoleSelectionState> {
  final SaveSelectedRole saveSelectedRole;

  RoleSelectionBloc({required this.saveSelectedRole})
      : super(const RoleSelectionInitial()) {
    on<RoleSelected>(_onRoleSelected);
    on<RoleConfirmed>(_onRoleConfirmed);
  }

  void _onRoleSelected(RoleSelected event, Emitter<RoleSelectionState> emit) {
    emit(RoleSelectionPicked(event.role));
  }

  Future<void> _onRoleConfirmed(
    RoleConfirmed event,
    Emitter<RoleSelectionState> emit,
  ) async {
    final current = state;
    if (current is! RoleSelectionPicked) return;

    emit(RoleSelectionSaving(current.role));

    final result = await saveSelectedRole(SaveSelectedRoleParams(current.role));

    result.fold(
      (_) => emit(const RoleSelectionFailure('Failed to save role')),
      (_) => emit(RoleSelectionSaved(current.role)),
    );
  }
}
