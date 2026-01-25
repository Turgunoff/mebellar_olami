import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/route_names.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../main/presentation/cubit/navigation_cubit.dart';

/// Bo'sh savatcha widgeti
class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Savatchangiz bo\'sh',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mahsulotlarni savatchaga qo\'shing',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Katalogga o\'tish',
            onPressed: () {
              // Switch to Catalog tab (index 1) and navigate to main screen
              context.read<NavigationCubit>().changeIndex(1);
              context.goNamed(RouteNames.main);
            },
          ),
        ],
      ),
    );
  }
}
