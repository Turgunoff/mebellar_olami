import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Filter chip modeli
class FilterChipModel {
  final String id;
  final String label;
  final bool isDefault;

  const FilterChipModel({
    required this.id,
    required this.label,
    this.isDefault = false,
  });
}

/// Horizontal filter chips widget
class FilterChips extends StatelessWidget {
  final List<FilterChipModel> filters;
  final String? selectedFilterId;
  final ValueChanged<String?> onFilterSelected;

  const FilterChips({
    super.key,
    required this.filters,
    this.selectedFilterId,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 56, // 40px chip + 16px padding
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilterId == filter.id ||
              (selectedFilterId == null && filter.isDefault);

          return Padding(
            padding: const EdgeInsets.only(right: 10), // 8-10px margin
            child: _CustomFilterChip(
              label: filter.label,
              isSelected: isSelected,
              onTap: () {
                // IN-PLACE FILTERING: Only calls callback, NO navigation
                // If already selected, reset to "All"; otherwise select this filter
                // The parent widget (CatalogScreen) handles state and BLoC events
                if (isSelected) {
                  onFilterSelected('all');
                } else {
                  onFilterSelected(filter.id);
                }
                // NOTE: This widget never performs navigation - it only triggers the callback
              },
            ),
          );
        },
      ),
    );
  }
}

/// Custom Filter Chip with exact styling requirements
class _CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40, // Exactly 40px height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary // Selected: Primary (black) background
              : Colors.grey[200], // Unselected: Grey[200] background
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white // Selected: White text
                  : Colors.black, // Unselected: Black text
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
