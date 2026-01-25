import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../../core/constants/app_colors.dart';

class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  int _currentBannerIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  static const List<Map<String, String>> _banners = [
    {
      'image':
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
      'title': 'Yangi Kolleksiya',
      'subtitle': '30% gacha chegirma',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=800',
      'title': 'Premium Divanlar',
      'subtitle': 'Maxsus narxlarda',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=800',
      'title': 'Yotoqxona to\'plami',
      'subtitle': 'Bepul yetkazib berish',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            CarouselSlider(
              items: _banners.map((banner) {
                return _buildBannerItem(banner);
              }).toList(),
              carouselController: _carouselController,
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true, // Markaziy bannerni kattalashtirish
                viewportFraction:
                    0.92, // Yon tomonlar biroz ko'rinib turishi uchun
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildIndicator(),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  Widget _buildBannerItem(Map<String, String> banner) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ), // 8 dan 4 ga tushirildi (zichroq bo'lishi uchun)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Soya faqat pastga tushsin
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 1. Asosiy Rasm
            CachedNetworkImage(
              imageUrl: banner['image']!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),

            // 2. Gradient (Tuzatilgan qism)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    // MUHIM: stops orqali gradient qayerdan boshlanishini hal qilamiz
                    stops: const [0.4, 1.0],
                    colors: [
                      Colors.transparent, // Tepa 40% butunlay shaffof
                      Colors.black.withOpacity(0.8), // Pastki qism to'q
                    ],
                  ),
                ),
              ),
            ),

            // 3. Matnlar
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Biroz kattalashtirildi
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      banner['subtitle']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _banners.asMap().entries.map((entry) {
        final isSelected = _currentBannerIndex == entry.key;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350), // Animatsiya davomiyligi
          curve: Curves.fastOutSlowIn, // Silliq harakat effekti
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 24.0 : 8.0, // Tanlanganda 4 barobar uzunlashadi
          height: 8.0,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.lightGrey.withOpacity(
                    0.5,
                  ), // Rang ham silliq o'zgaradi
            borderRadius: BorderRadius.circular(4), // Doimiy aylana burchaklar
          ),
        );
      }).toList(),
    );
  }
}
