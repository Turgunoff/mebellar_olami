part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class LoadSearchHistory extends SearchEvent {
  const LoadSearchHistory();
}

class AddSearchTerm extends SearchEvent {
  const AddSearchTerm({required this.term});

  final String term;

  @override
  List<Object?> get props => [term];
}

class RemoveSearchTerm extends SearchEvent {
  const RemoveSearchTerm({required this.term});

  final String term;

  @override
  List<Object?> get props => [term];
}

class ClearSearchHistory extends SearchEvent {
  const ClearSearchHistory();
}

class SearchProducts extends SearchEvent {
  const SearchProducts({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}
