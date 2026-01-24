import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';

/// Manzil tanlash uchun xarita ekran
class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  YandexMapController? _mapController;
  Point? _selectedLocation;
  String _locationName = '';
  bool _isLoading = true;
  final List<MapObject> _mapObjects = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Foydalanuvchining joriy joylashuvini olish
      final position = await Geolocator.getCurrentPosition();
      final userLocation = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _isLoading = false;
        _selectedLocation = userLocation;
        _locationName = 'Joriy joylashuv';
      });
    } catch (e) {
      // Geolocator ishlamasa, Toshkent markaziga o'rnatamiz
      final toshkentCenter = const Point(
        latitude: 41.311081,
        longitude: 69.240563,
      );

      setState(() {
        _isLoading = false;
        _selectedLocation = toshkentCenter;
        _locationName = 'Toshkent';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
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
        title: const Text(
          'Manzilni tanlash',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Xarita
          if (!_isLoading)
            YandexMap(
              onMapCreated: (controller) {
                _mapController = controller;
                _setupMapListeners();
                _moveToInitialLocation();
              },
              onMapTap: (point) {
                _selectLocation(point);
              },
              onMapLongTap: (point) {
                _selectLocation(point);
              },
              mapObjects: _mapObjects,
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),

          // Manzil ma'lumotlari paneli
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Manzil nomi
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanlangan manzil',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _locationName.isNotEmpty
                              ? _locationName
                              : 'Manzil tanlanmagan',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedLocation != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Koordinatalar: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tugmalar
                  Row(
                    children: [
                      // Joriy joylashuvga qaytish
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _goToCurrentLocation,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.my_location,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Joriy joylashuv',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tasdiqlash tugmasi
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _selectedLocation != null
                              ? _confirmLocation
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: _selectedLocation != null
                                ? AppColors.primary
                                : AppColors.lightGrey,
                          ),
                          child: const Text(
                            'Tasdiqlash',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Xarita boshqaruvchi tugmalar
          Positioned(
            top: 80,
            right: 16,
            child: Column(
              children: [
                // Zoom in
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () =>
                        _mapController?.moveCamera(CameraUpdate.zoomIn()),
                    icon: const Icon(Icons.add, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom out
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () =>
                        _mapController?.moveCamera(CameraUpdate.zoomOut()),
                    icon: const Icon(
                      Icons.remove,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setupMapListeners() {
    // Xarita tayinlashlarni tinglash
    // Bu yerda qo'shimcha funksiyalar qo'shish mumkin
  }

  Future<void> _moveToInitialLocation() async {
    if (_mapController == null || _selectedLocation == null) return;

    await _mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _selectedLocation!, zoom: 15.0),
      ),
    );

    _selectLocation(_selectedLocation!);
  }

  void _selectLocation(Point point) {
    setState(() {
      _selectedLocation = point;
      _locationName = 'Tanlangan manzil';
    });

    // Marker qo'shish - oddiy placemark bilan
    setState(() {
      _mapObjects.clear();
      _mapObjects.add(
        PlacemarkMapObject(
          mapId: const MapObjectId('selected_location'),
          point: point,
          opacity: 1.0,
          isDraggable: false,
        ),
      );
    });
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final currentLocation = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 15.0),
        ),
      );

      _selectLocation(currentLocation);
      setState(() {
        _locationName = 'Joriy joylashuv';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joylashuvni olishda xatolik: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _confirmLocation() {
    if (_selectedLocation == null) return;

    // Natijani qaytarish
    context.pop({
      'location': _selectedLocation,
      'name': _locationName.isNotEmpty ? _locationName : 'Tanlangan manzil',
    });
  }
}

/*
 * Yandex Map Kit Lite API Keylari uchun:
 * 
 * Android:
 * 1. android/app/build.gradle ga qo'shing:
 *    dependencies {
 *        implementation 'com.yandex.android:mapkit:4.4.0-lite'
 *    }
 * 
 * 2. android/app/src/main/AndroidManifest.xml ga qo'shing:
 *    <meta-data
 *        android:name="com.yandex.android:apikey"
 *        android:value="YOUR_ANDROID_API_KEY" />
 * 
 * 3. android/app/src/main/AndroidManifest.xml ga qo'shing (application tag ichida):
 *    <meta-data
 *        android:name="com.yandex.android:mapkit_apikey"
 *        android:value="YOUR_ANDROID_API_KEY" />
 * 
 * iOS:
 * 1. ios/Runner/Info.plist ga qo'shing:
 *    <key>YandexMapApiKey</key>
 *    <string>YOUR_IOS_API_KEY</string>
 * 
 * 2. ios/Runner/AppDelegate.swift ga qo'shing:
 *    import YandexMapsMobile
 *    YandexMapsMobile.setApiKey("YOUR_IOS_API_KEY")
 */
