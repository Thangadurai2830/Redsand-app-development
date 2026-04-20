import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_role.dart';

abstract class RoleSelectionEvent extends Equatable {
  const RoleSelectionEvent();

  @override
  List<Object?> get props => [];
}

class RoleSelected extends RoleSelectionEvent {
  final UserRole role;
  const RoleSelected(this.role);

  @override
  List<Object?> get props => [role];
}

class RoleConfirmed extends RoleSelectionEvent {
  const RoleConfirmed();
}
