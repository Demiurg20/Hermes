import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hermes/core/app/app_di.dart';
import '../cars/car.dart';

class BookingConfirmedScreen extends StatefulWidget {
  const BookingConfirmedScreen({
    super.key,
    required this.car,
    required this.bookingId,
    required this.pickupLocation,
    required this.pickupDateTime,
  });

  final Car car;
  final String bookingId;
  final String pickupLocation;
  final DateTime pickupDateTime;

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> with SingleTickerProviderStateMixin {
  static const Color bg = Color(0xFF0B0C0E);
  static const Color gold = Color(0xFFD6A34A);
  static const Color card = Color(0xFF111317);
  static const Color green = Color(0xFF3DDC84);

  bool _processing = true;
  String? _serverStatus;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutCubic,
    );

    _loadServerStatus();
  }

  Future<void> _loadServerStatus() async {
    try {
      final bookings = await AppDI.bookingRepo.getMyBookings().timeout(
        const Duration(seconds: 10),
      );

      final String targetId = widget.bookingId;
      Map<String, dynamic>? foundBooking;

      for (final item in bookings) {
        if (item is! Map) continue;
        final id = item["id"] ?? item["bookingId"] ?? item["_id"] ?? item["booking_id"];
        if (id?.toString() == targetId) {
          foundBooking = Map<String, dynamic>.from(item);
          break;
        }
      }

      if (foundBooking != null && mounted) {
        setState(() {
          _serverStatus = (foundBooking?["status"] ??
              foundBooking?["state"] ??
              foundBooking?["bookingStatus"] ??
              foundBooking?["clientStatus"])
              ?.toString();
        });
      }
    } catch (e) {
      debugPrint("Error loading server status: $e");
    } finally {
      if (mounted) {
        setState(() => _processing = false);
        _pulseController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _statusText() {
    if (_serverStatus != null && _serverStatus!.trim().isNotEmpty) {
      return _serverStatus!;
    }
    final now = DateTime.now();
    final diff = widget.pickupDateTime.difference(now);

    if (diff.inSeconds <= 2 * 3600) {
      return 'Ready for pickup';
    }

    final totalSeconds = diff.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final hh = hours.toString().padLeft(2, '0');
    final mm = minutes.toString().padLeft(2, '0');
    return 'Pickup in $hh:$mm';
  }

  bool _isReady() {
    if (_serverStatus != null && _serverStatus!.trim().isNotEmpty) {
      final s = _serverStatus!.toLowerCase();
      return s.contains('ready') || s.contains('confirmed') || s.contains('active');
    }
    final diff = widget.pickupDateTime.difference(DateTime.now());
    return diff.inSeconds <= 2 * 3600;
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusText();
    final ready = _isReady();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Анимация пульса (Исправленная версия)
            if (!_processing)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, _) {
                  double radius = 60 + (size.longestSide * _pulseAnimation.value);
                  double opacity = (1.0 - _pulseAnimation.value).clamp(0.0, 1.0);

                  return Positioned(
                    top: 34 + 30 - (radius / 2), // Центрируем по иконке
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: radius,
                        height: radius,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(color: green.withOpacity(0.5), width: 4),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Основной контент
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 34),

                          // Иконка статуса
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (_processing ? gold : green).withOpacity(0.18),
                              border: Border.all(color: _processing ? gold : green, width: 2),
                            ),
                            child: _processing
                                ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(strokeWidth: 2, color: gold),
                            )
                                : const Icon(Icons.check_rounded, color: green, size: 32),
                          ),

                          const SizedBox(height: 22),

                          Text(
                            _processing ? 'Processing Payment…' : 'Booking Confirmed!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _processing ? 'Please wait...' : 'Your car has been successfully booked',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                          ),

                          const SizedBox(height: 30),

                          if (!_processing) ...[
                            // Карточка машины
                            _SurfaceCard(
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      widget.car.imageUrl,
                                      width: 80,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(width: 80, height: 60, color: Colors.black26, child: const Icon(Icons.image_not_supported)),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${widget.car.brand} ${widget.car.model}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text('${widget.car.year} • ${widget.car.fuel}', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Детали бронирования
                            _SurfaceCard(
                              child: Column(
                                children: [
                                  _ConfirmRow(icon: Icons.confirmation_number_outlined, title: 'Booking ID', value: widget.bookingId),
                                  const Divider(color: Colors.white10, height: 24),
                                  _ConfirmRow(icon: Icons.location_on_outlined, title: 'Pickup Location', value: widget.pickupLocation),
                                  const Divider(color: Colors.white10, height: 24),
                                  _ConfirmRow(icon: Icons.timer_outlined, title: 'Status', value: status, valueColor: ready ? green : gold),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  if (!_processing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 10),
                      child: _PrimaryButton(
                        text: 'Back to Home',
                        onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _ConfirmRow({required this.icon, required this.title, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFD6A34A).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFFD6A34A), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  const _SurfaceCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111317), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PrimaryButton({required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD6A34A),
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}