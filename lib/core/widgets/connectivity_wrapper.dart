import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkConnection();

    // Internet aloqasini tinglash
    InternetConnection().onStatusChange.listen((status) {
      if (mounted) {
        setState(() {
          _isConnected =
              status.toString() == 'InternetConnectionStatus.connected';
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnection();
    }
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final isConnected = await InternetConnection().hasInternetAccess;
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
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
