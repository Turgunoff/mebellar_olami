import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repositories/search_repository.dart';
import '../../../products/data/repositories/product_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;
  final ProductRepository _productRepository;

  SearchBloc({
    required SearchRepository searchRepository,
    required ProductRepository productRepository,
  }) : _searchRepository = searchRepository,
       _productRepository = productRepository,
       super(const SearchState()) {
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<AddSearchTerm>(_onAddSearchTerm);
    on<RemoveSearchTerm>(_onRemoveSearchTerm);
    on<ClearSearchHistory>(_onClearSearchHistory);
    on<SearchProducts>(_onSearchProducts);
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  Future<void> _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loading));

    try {
      final history = _searchRepository.getSearchHistory();
      emit(
        state.copyWith(
          status: SearchStatus.historyLoaded,
          searchHistory: history,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onAddSearchTerm(
    AddSearchTerm event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _searchRepository.addSearchTerm(event.term);
      final updatedHistory = _searchRepository.getSearchHistory();

      emit(
        state.copyWith(
          status: SearchStatus.historyLoaded,
          searchHistory: updatedHistory,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onRemoveSearchTerm(
    RemoveSearchTerm event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _searchRepository.removeTerm(event.term);
      final updatedHistory = _searchRepository.getSearchHistory();

      emit(
        state.copyWith(
          status: SearchStatus.historyLoaded,
          searchHistory: updatedHistory,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onClearSearchHistory(
    ClearSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _searchRepository.clearHistory();

      emit(
        state.copyWith(status: SearchStatus.historyLoaded, searchHistory: []),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(
        state.copyWith(status: SearchStatus.historyLoaded, searchResults: []),
      );
      return;
    }

    emit(
      state.copyWith(status: SearchStatus.searching, currentQuery: event.query),
    );

    try {
      final result = await _productRepository.searchProducts(
        query: event.query,
      );

      if (result['success'] == true) {
        final products = List<Map<String, dynamic>>.from(
          result['products'] ?? [],
        );

        // Qidiruv muvaffaqiyatli bo'lsa, tarixga qo'shamiz
        await _searchRepository.addSearchTerm(event.query);
        final updatedHistory = _searchRepository.getSearchHistory();

        emit(
          state.copyWith(
            status: SearchStatus.resultsLoaded,
            searchResults: products,
            searchHistory: updatedHistory,
            currentQuery: event.query,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: SearchStatus.error,
            errorMessage: result['message'] ?? 'Qidiruvda xatolik yuz berdi',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      // Query bo'sh bo'lsa, tarixni ko'rsatamiz
      emit(
        state.copyWith(
          status: SearchStatus.historyLoaded,
          searchResults: [],
          currentQuery: '',
        ),
      );
    } else {
      // Query bor bo'lsa, takliflarni ko'rsatamiz
      final suggestions = _searchRepository.getSearchSuggestions(query);

      emit(
        state.copyWith(
          status: SearchStatus.suggestionsLoaded,
          searchSuggestions: suggestions,
          currentQuery: query,
        ),
      );
    }
  }

  /// Qidiruv tarixini yangilash
  Future<void> refreshHistory() async {
    add(const LoadSearchHistory());
  }

  /// Qidiruv natijalarini tozalash
  void clearResults() {
    emit(
      state.copyWith(
        status: SearchStatus.historyLoaded,
        searchResults: [],
        searchSuggestions: [],
        currentQuery: '',
      ),
    );
  }

  /// Qidiruv so'zini takliflarni olish
  List<String> getSuggestionsForQuery(String query) {
    return _searchRepository.getSearchSuggestions(query);
  }

  /// Qidiruv tarixi uzunligi
  int get historyLength => _searchRepository.historyLength;

  /// Qidiruv tarixi bo'shmi
  bool get isHistoryEmpty => _searchRepository.isHistoryEmpty;
}
