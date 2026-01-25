import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/banner_model.dart';
import '../../data/repositories/banner_repository.dart';

// ==================== STATES ====================

/// Banner holatlari uchun asosiy class
sealed class BannerState extends Equatable {
  const BannerState();

  @override
  List<Object?> get props => [];
}

/// Boshlang'ich holat
class BannerInitial extends BannerState {
  const BannerInitial();
}

/// Yuklanayotgan holat
class BannerLoading extends BannerState {
  const BannerLoading();
}

/// Muvaffaqiyatli yuklangan holat
class BannerLoaded extends BannerState {
  final List<BannerModel> banners;

  const BannerLoaded(this.banners);

  @override
  List<Object?> get props => [banners];
}

/// Xatolik holati
class BannerError extends BannerState {
  final String message;

  const BannerError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== CUBIT ====================

/// Banner ma'lumotlarini boshqarish uchun Cubit
class BannerCubit extends Cubit<BannerState> {
  final BannerRepository _repository;

  BannerCubit({required BannerRepository repository})
    : _repository = repository,
      super(const BannerInitial());

  /// Bannerlarni yuklash
  Future<void> loadBanners() async {
    emit(const BannerLoading());

    try {
      final banners = await _repository.getBanners();
      emit(BannerLoaded(banners));
    } catch (e) {
      emit(BannerError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Bannerlarni qayta yuklash
  Future<void> refreshBanners() async {
    try {
      final banners = await _repository.getBanners();
      emit(BannerLoaded(banners));
    } catch (e) {
      emit(BannerError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
