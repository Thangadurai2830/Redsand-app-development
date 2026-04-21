import 'package:equatable/equatable.dart';

class PriceHistoryPointEntity extends Equatable {
  final String label;
  final double price;

  const PriceHistoryPointEntity({
    required this.label,
    required this.price,
  });

  @override
  List<Object?> get props => [label, price];
}
