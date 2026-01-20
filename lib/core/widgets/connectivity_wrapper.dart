import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../constants/app_colors.dart';

/// Internet aloqasini tekshirib, offline rejimda xabar ko'rsatuvchi widget
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper>
    with WidgetsBindingObserver {
  bool _isConnected = true;
  bool _isChecking = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Dastlabki tekshiruvni kechiktirish, ilova to'liq yonib chiqishini kutish uchun
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _checkConnection();
      }
    });

    // Connectivity o'zgarishlarini tinglash
    Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) {
        _debouncedConnectionCheck(results);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnection();
    }
  }

  /// Connectivity natijalariga qarab internet borligini aniqlaydi
  bool _hasConnectivity(List<ConnectivityResult> results) {
    // Agar natijalar ichida .none bo'lsa va boshqa ulanish turi bo'lmasa -> Internet yo'q
    if (results.contains(ConnectivityResult.none) && results.length == 1) {
      return false;
    }
    // Mobile, Wifi, Ethernet, VPN, Bluetooth - hammasi internet borligini bildiradi
    return true;
  }

  /// Tez-tez chaqirilmasligi uchun debounce qilingan tekshiruv
  void _debouncedConnectionCheck(
    List<ConnectivityResult>? connectivityResults,
  ) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _checkConnection(connectivityResults);
    });
  }

  Future<void> _checkConnection([
    List<ConnectivityResult>? connectivityResults,
  ]) async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      // Agar connectivityResults berilmagan bo'lsa, tekshirib olish
      final results =
          connectivityResults ?? await Connectivity().checkConnectivity();

      // Avval connectivity ni tekshiramiz
      final hasConnectivity = _hasConnectivity(results);

      if (!hasConnectivity) {
        if (mounted) {
          setState(() {
            _isConnected = false;
            _isChecking = false;
          });
        }
        return;
      }

      // Connectivity bor, endi haqiqiy internet alokasini tekshiramiz
      final hasInternetAccess = await InternetConnection().hasInternetAccess;

      if (mounted) {
        setState(() {
          _isConnected = hasInternetAccess;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Asosiy content
          widget.child,

          // Internet aloqasi yo'q banner
          if (!_isConnected)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Internet aloqasi yo\'q',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_isChecking)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _checkConnection,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ConnectivityWrapper ni qulay ishlatish uchun extension
extension ConnectivityWrapperExtension on Widget {
  /// Widgetni ConnectivityWrapper bilan o'rab olish
  Widget withConnectivityCheck() {
    return ConnectivityWrapper(child: this);
  }
}
