import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

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

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _finishProcessing();
  }

  Future<void> _finishProcessing() async {
    // Simulate processing for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _processing = false);
    _pulseController.forward(from: 0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _statusText() {
    final now = DateTime.now();
    final diff = widget.pickupDateTime.difference(now);

    // If pickup is within 2 hours (or already started), show Ready for pickup
    if (diff.inSeconds <= 2 * 3600) {
      return 'Ready for pickup';
    }

    // Otherwise show countdown
    final totalSeconds = diff.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final hh = hours.toString().padLeft(2, '0');
    final mm = minutes.toString().padLeft(2, '0');
    return 'Pickup in $hh:$mm';
  }

  bool _isReady() {
    final diff = widget.pickupDateTime.difference(DateTime.now());
    return diff.inSeconds <= 2 * 3600;
  }

  static Widget _divider() => Container(
    height: 1,
    color: Colors.white.withOpacity(0.06),
  );

  @override
  Widget build(BuildContext context) {
    final status = _statusText();
    final ready = _isReady();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // One-shot pulse from the top check icon (does not affect layout)
            IgnorePointer(
              ignoring: true,
              child: Positioned.fill(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    // Only show pulse after processing is done
                    if (_processing || _pulseController.value == 0) {
                      return const SizedBox.shrink();
                    }

                    final size = MediaQuery.of(context).size;
                    final maxDiameter = math.sqrt(
                      size.width * size.width + size.height * size.height,
                    ) +
                        200;

                    final t = _pulseController.value; // 0..1
                    final eased = Curves.easeOutCubic.transform(t);
                    final diameter = 60 + (maxDiameter - 60) * eased;
                    final opacity = (1.0 - t).clamp(0.0, 1.0);

                    // Anchor pulse to the check icon center
                    const topPadding = 34.0;
                    const iconSize = 60.0;
                    final originY = topPadding + (iconSize / 2);

                    return Stack(
                      children: [
                        Positioned(
                          left: (MediaQuery.of(context).size.width - diameter) / 2,
                          top: originY - (diameter / 2),
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: diameter,
                              height: diameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: green.withOpacity(0.10 * opacity),
                                border: Border.all(
                                  color: green.withOpacity(0.95),
                                  width: 10,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: green.withOpacity(0.45 * opacity),
                                    blurRadius: 90,
                                    spreadRadius: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Existing content + bottom button
            Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 34),

                      // Top icon: processing loader for 3s, then green check
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (_processing ? gold : green).withOpacity(0.18),
                            border: Border.all(
                              color: _processing ? gold : green,
                              width: 2,
                            ),
                          ),
                          child: _processing
                              ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(gold),
                            ),
                          )
                              : const Icon(Icons.check_rounded, color: green, size: 32),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Center(
                        child: Text(
                          _processing ? 'Processing Payment…' : 'Booking Confirmed!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _processing
                              ? 'Please wait while we confirm your payment'
                              : 'Your car has been successfully booked',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      if (!_processing) ...[
                        // Car card
                        _SurfaceCard(
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  widget.car.imageUrl,
                                  width: 76,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    width: 76,
                                    height: 56,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.car.brand} ${widget.car.model}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${widget.car.year} / ${widget.car.fuel}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.55),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Details card
                        _SurfaceCard(
                          child: Column(
                            children: [
                              _ConfirmRow(
                                icon: Icons.directions_car_filled_outlined,
                                title: 'Booking ID',
                                value: widget.bookingId,
                              ),
                              _divider(),
                              _ConfirmRow(
                                icon: Icons.location_on_outlined,
                                title: 'Pickup',
                                value: widget.pickupLocation,
                              ),
                              _divider(),
                              _ConfirmRow(
                                icon: Icons.access_time_rounded,
                                title: 'Status',
                                value: status,
                                valueColor: ready ? green : gold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (!_processing)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _PrimaryButton(
                      text: 'Back to Home',
                      onTap: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  static const Color gold = Color(0xFFD6A34A);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: gold.withOpacity(0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: gold, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});
  final Widget child;

  static const Color card = Color(0xFF111317);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.25),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  static const Color gold = Color(0xFFD6A34A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: gold,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}