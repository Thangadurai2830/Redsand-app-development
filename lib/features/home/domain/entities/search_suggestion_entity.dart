import 'package:equatable/equatable.dart';

class SearchSuggestionEntity extends Equatable {
  final String id;
  final String text;
  final String type; // city, locality, apartment

  const SearchSuggestionEntity({
    required this.id,
    required this.text,
    required this.type,
  });

  @override
  List<Object?> get props => [id, text, type];
}
