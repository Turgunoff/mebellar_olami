part of 'search_bloc.dart';

enum SearchStatus {
  initial,
  loading,
  historyLoaded,
  suggestionsLoaded,
  searching,
  resultsLoaded,
  error,
}

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.searchHistory = const [],
    this.searchResults = const [],
    this.searchSuggestions = const [],
    this.currentQuery = '',
    this.errorMessage,
  });

  final SearchStatus status;
  final List<String> searchHistory;
  final List<Map<String, dynamic>> searchResults;
  final List<String> searchSuggestions;
  final String currentQuery;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    status,
    searchHistory,
    searchResults,
    searchSuggestions,
    currentQuery,
    errorMessage,
  ];

  SearchState copyWith({
    SearchStatus? status,
    List<String>? searchHistory,
    List<Map<String, dynamic>>? searchResults,
    List<String>? searchSuggestions,
    String? currentQuery,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      searchHistory: searchHistory ?? this.searchHistory,
      searchResults: searchResults ?? this.searchResults,
      searchSuggestions: searchSuggestions ?? this.searchSuggestions,
      currentQuery: currentQuery ?? this.currentQuery,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading =>
      status == SearchStatus.loading || status == SearchStatus.searching;
  bool get hasHistory => searchHistory.isNotEmpty;
  bool get hasResults => searchResults.isNotEmpty;
  bool get hasSuggestions => searchSuggestions.isNotEmpty;
  bool get hasError => status == SearchStatus.error;
  bool get isShowingHistory => status == SearchStatus.historyLoaded;
  bool get isShowingSuggestions => status == SearchStatus.suggestionsLoaded;
  bool get isShowingResults => status == SearchStatus.resultsLoaded;
}
