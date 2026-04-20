import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_role.dart';

abstract class RoleSelectionState extends Equatable {
  const RoleSelectionState();

  @override
  List<Object?> get props => [];
}

class RoleSelectionInitial extends RoleSelectionState {
  const RoleSelectionInitial();
}

class RoleSelectionPicked extends RoleSelectionState {
  final UserRole role;
  const RoleSelectionPicked(this.role);

  @override
  List<Object?> get props => [role];
}

class RoleSelectionSaving extends RoleSelectionState {
  final UserRole role;
  const RoleSelectionSaving(this.role);

  @override
  List<Object?> get props => [role];
}

class RoleSelectionSaved extends RoleSelectionState {
  final UserRole role;
  const RoleSelectionSaved(this.role);

  @override
  List<Object?> get props => [role];
}

class RoleSelectionFailure extends RoleSelectionState {
  final String message;
  const RoleSelectionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
