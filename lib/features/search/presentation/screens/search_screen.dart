import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shimmer/product_card_skeleton.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../products/presentation/screens/product_detail_screen.dart';
import '../../../products/data/models/product_model.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../bloc/search_bloc.dart';

/// Qidiruv ekran
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Qidiruv tarixini yuklash
    context.read<SearchBloc>().add(const LoadSearchHistory());

    // Qidiruv maydoniga focus qilish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        title: _buildSearchField(),
        centerTitle: false,
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                context.read<SearchBloc>().clearResults();
              },
              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
            ),
        ],
      ),
      body: BlocListener<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state.hasError && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return _buildContent(state);
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          context.read<SearchBloc>().add(SearchQueryChanged(query: value));
        },
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            context.read<SearchBloc>().add(SearchProducts(query: value));
          }
        },
        decoration: InputDecoration(
          hintText: 'Mahsulotlarni qidirish...',
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(SearchState state) {
    if (state.isShowingHistory) {
      return _buildSearchHistory(state);
    } else if (state.isShowingSuggestions) {
      return _buildSearchSuggestions(state);
    } else if (state.isShowingResults) {
      return _buildSearchResults(state);
    } else if (state.isLoading) {
      return _buildLoadingState();
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildSearchHistory(SearchState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasHistory) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Qidiruv tarixi',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<SearchBloc>().add(const ClearSearchHistory());
                  },
                  child: const Text(
                    'Tozalash',
                    style: TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...state.searchHistory.map((term) => _buildHistoryItem(term)),
          ] else ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Qidiruv tarixi bo\'sh',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mahsulotlarni qidiringiz, ular bu yerda ko\'rinadi',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String term) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(
          Icons.history,
          color: AppColors.textSecondary,
          size: 20,
        ),
        title: Text(
          term,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
        trailing: IconButton(
          onPressed: () {
            context.read<SearchBloc>().add(RemoveSearchTerm(term: term));
          },
          icon: const Icon(
            Icons.close,
            color: AppColors.textSecondary,
            size: 18,
          ),
        ),
        onTap: () {
          _searchController.text = term;
          context.read<SearchBloc>().add(SearchProducts(query: term));
        },
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildSearchSuggestions(SearchState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Takliflar',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...state.searchSuggestions.map(
            (suggestion) => _buildSuggestionItem(suggestion),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 20,
        ),
        title: Text(
          suggestion,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
        onTap: () {
          _searchController.text = suggestion;
          context.read<SearchBloc>().add(SearchProducts(query: suggestion));
        },
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildSearchResults(SearchState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${state.searchResults.length} ta mahsulot',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (state.hasResults)
                Text(
                  '"${state.currentQuery}" uchun',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final product = state.searchResults[index];
              return ProductCard(
                product: ProductModel.fromJson(product),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productId: ProductModel.fromJson(product).id,
                      ),
                    ),
                  );
                },
              ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 6, // Show 6 skeleton cards
      itemBuilder: (context, index) {
        return const ProductCardSkeleton();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mahsulotlar topilmadi',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Boshqa kalit so\'zlar bilan urinib ko\'ring',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Asosiyga qaytish',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
