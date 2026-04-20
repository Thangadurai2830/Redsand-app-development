import 'package:equatable/equatable.dart';

class HomeEntity extends Equatable {
  final String title;
  final String message;

  const HomeEntity({required this.title, required this.message});

  @override
  List<Object?> get props => [title, message];
}
