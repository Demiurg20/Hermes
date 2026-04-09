import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../cars/car.dart';
import '../cars/booking_confirmed_page.dart';
import '../auth/presentation/agreement_page.dart';
import 'payment_page.dart';
import 'package:hermes/core/app/app_di.dart';
import 'package:hermes/core/api/token_storage.dart';
import 'package:hermes/core/models/booking_request.dart';
import 'package:hermes/features/auth/presentation/login_page.dart';

class PriceSummaryScreen extends StatefulWidget {
  const PriceSummaryScreen({
    super.key,
    required this.car,
    required this.pickUpLocationId,
    required this.dropOffLocationId,
    required this.pickupLocationLabel,
    required this.dropoffLocationLabel,
    required this.pickupDateTime,
    required this.dropoffDateTime,
    required this.days,
    required this.totalFromBackend,
  });

  final Car car;
  final int pickUpLocationId;
  final int dropOffLocationId;
  final String pickupLocationLabel;
  final String dropoffLocationLabel;
  final DateTime pickupDateTime;

  final DateTime dropoffDateTime;

  final int days;
  final double totalFromBackend;


  @override
  State<PriceSummaryScreen> createState() => _PriceSummaryScreenState();
}

class _PriceSummaryScreenState extends State<PriceSummaryScreen> {
  static const Color bg = Color(0xFF0B0C0E);
  static const Color gold = Color(0xFFD6A34A);
  static const Color green = Color(0xFF3DDC84);


  Future<void> loadBalance() async {
    try {
      final user = await AppDI.userRepo.getUserInfo();

      setState(() {
        balance = user.balance;
        isBalanceLoading = false;
      });
    } catch (e) {
      debugPrint("Balance load error: $e");

      setState(() {
        balance = 0;
        isBalanceLoading = false;
      });
    }
  }

  double? balance;
  bool isBalanceLoading = true;

  @override
  void initState() {
    super.initState();
    loadBalance(); // 👈 твой метод
  }

  bool agreed = false;
  bool _creatingBooking = false;

  @override
  Widget build(BuildContext context) {
    const double serviceFee = 5;
    const double insuranceFee = 5;

    final pickup = widget.pickupDateTime;
    final dropoff = widget.dropoffDateTime;

    final dateText = _formatDateLong(pickup); // Sunday, March 15
    final timeText = _formatTime(pickup); // 10:00
    final durationText = widget.days == 1
        ? '1 day'
        : '${widget.days} days';

    final rent = widget.totalFromBackend > 0
        ? widget.totalFromBackend
        : (widget.car.pricePerDay * widget.days).toDouble();
    final total = rent + serviceFee + insuranceFee;

    final confirmText = 'Confirm \$${total.toStringAsFixed(0)}';



    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Price Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

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
                        errorBuilder: (_, __, ___) => Container(
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: gold.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.car.fuel.isNotEmpty
                                      ? widget.car.fuel
                                      : 'Comfort',
                                  style: const TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.car.type.isNotEmpty
                                    ? widget.car.type
                                    : 'Auto',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // BOOKING DETAILS
              _SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOOKING DETAILS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _KeyValueRow(left: 'Pickup', right: widget.pickupLocationLabel),
                    const SizedBox(height: 10),
                    _KeyValueRow(left: 'Drop-off', right: widget.dropoffLocationLabel),
                    const SizedBox(height: 10),
                    _KeyValueRow(left: 'Date', right: dateText),
                    const SizedBox(height: 10),
                    _KeyValueRow(left: 'Start time', right: timeText),
                    const SizedBox(height: 10),
                    _KeyValueRow(left: 'Duration', right: durationText),
                    const SizedBox(height: 10),
                    _KeyValueRow(
                      left: 'End',
                      right: _formatDateLong(dropoff) + ', ' + _formatTime(dropoff),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // PRICE BREAKDOWN
              _SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRICE BREAKDOWN',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _KeyValueRow(
                      left:
                          '\$${widget.car.pricePerDay} × ${widget.days} day${widget.days == 1 ? '' : 's'}',
                      right: '\$${rent.toStringAsFixed(0)}',
                      dim: true,
                    ),
                    const SizedBox(height: 10),
                    _KeyValueRow(
                      left: 'Service fee',
                      right: '\$${serviceFee.toStringAsFixed(0)}',
                      dim: true,
                    ),
                    const SizedBox(height: 10),
                    _KeyValueRow(
                      left: 'Insurance',
                      right: '\$${insuranceFee.toStringAsFixed(0)}',
                      dim: true,
                    ),
                    const SizedBox(height: 14),
                    _divider(),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: gold,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Balance
              _SurfaceCard(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: gold,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    isBalanceLoading
                        ? const Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
                    )
                        : Text(
                      '\$${balance?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Agreement
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agreed,
                    onChanged: (v) => setState(() => agreed = v ?? false),
                    activeColor: gold,
                    checkColor: Colors.black,
                    side: BorderSide(color: Colors.white.withOpacity(0.35)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'I have read and agree to the '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const AgreementScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'User Agreement',
                                  style: TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(
                              text: ' of Hermes Flow car sharing platform',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: _SecondaryButton(
                      text: 'Cancel',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: agreed ? 1 : 0.45,
                      child: IgnorePointer(
                        ignoring: !agreed,
                        child: _PrimaryButton(
                          text: confirmText,
                          onTap: () async {
                            if (_creatingBooking) return;
                            setState(() => _creatingBooking = true);
                            try {
                              final carId = widget.car.bookingCarId;
                              if (carId == null) {
                                throw StateError(
                                  'Missing numeric carId for booking. Load cars from the API '
                                  '(response must include carId or a numeric id field).',
                                );
                              }
                              if (widget.pickUpLocationId <= 0 ||
                                  widget.dropOffLocationId <= 0) {
                                throw StateError(
                                  'Invalid locations: pick pickup and drop-off again.',
                                );
                              }
                              final bookingId =
                                  await AppDI.bookingRepo.createBooking(
                                BookingRequest(
                                  carId: carId,
                                  pickUpLocationId: widget.pickUpLocationId,
                                  dropOffLocationId: widget.dropOffLocationId,
                                  startDate: widget.pickupDateTime,
                                  endDate: widget.dropoffDateTime,
                                ),
                              );

                              if (!mounted) return;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => BookingConfirmedScreen(
                                    car: widget.car,
                                    bookingId: bookingId,
                                    pickupLocation: widget.pickupLocationLabel,
                                    pickupDateTime: widget.pickupDateTime,
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              if (e is DioException) {
                                final code = e.response?.statusCode;
                                if (code == 401 || code == 403) {
                                  await TokenStorage.clearToken();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Session expired. Please sign in again.'),
                                    ),
                                  );
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const LoginPage()),
                                    (route) => false,
                                  );
                                  setState(() => _creatingBooking = false);
                                  return;
                                }

                                final data = e.response?.data;
                                String message = 'Booking failed with $code';
                                if (data is Map) {
                                  message = data['message']?.toString() ??
                                      data['error']?.toString() ??
                                      data.toString();
                                } else if (data != null) {
                                  message = data.toString();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Booking failed: $e'),
                                  ),
                                );
                              }
                              setState(() => _creatingBooking = false);
                            }
                          },
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
    );
  }
}
Widget _divider() => Container(
  height: 1,
  color: Colors.white.withOpacity(0.06),
);
String _formatDateLong(DateTime dt) {
  const weekdays = [
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
  ];
  const months = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];
  final w = weekdays[dt.weekday - 1];
  final m = months[dt.month - 1];
  return '$w, $m ${dt.day}';
}

String _formatTime(DateTime dt) {
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.left, required this.right, this.dim = false});
  final String left;
  final String right;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final leftColor =
    dim ? Colors.white.withOpacity(0.55) : Colors.white.withOpacity(0.45);
    final rightColor = dim ? Colors.white.withOpacity(0.75) : Colors.white;

    return Row(
      children: [
        Expanded(
          child: Text(left, style: TextStyle(color: leftColor, fontWeight: FontWeight.w700)),
        ),
        Text(right, style: TextStyle(color: rightColor, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.06),
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
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
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