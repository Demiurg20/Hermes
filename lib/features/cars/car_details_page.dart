import '../cars/select_date_time_page.dart';
import 'package:flutter/material.dart';
import 'package:hermes/core/data/car_repository.dart';
import 'package:hermes/core/app/app_di.dart';
import 'package:hermes/features/cars/car.dart';
import 'package:hermes/core/state/car_details_controller.dart';

class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({
    super.key,
    required this.carId,
    this.repo,
  });

  final String carId;
  final CarRepository? repo; // можно передать настоящий репозиторий позже

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  late final CarDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = CarDetailsController(repo: widget.repo ?? AppDI.carRepo);
    controller.addListener(_onChanged);
    controller.load(widget.carId);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0C0E),
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (controller.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0C0E),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.error!,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => controller.load(widget.carId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final car = controller.car!;
    return _CarDetailsView(car: car);
  }
}

class _CarDetailsView extends StatelessWidget {
  const _CarDetailsView({required this.car});
  final Car car;

  static const Color bg = Color(0xFF0B0C0E);
  static const Color gold = Color(0xFFD6A34A);
  static const Color card = Color(0xFF111317);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // TOP IMAGE (fixed height so layout never overflows)
              SizedBox(
                height: 360,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        car.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(color: Colors.black);
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: Colors.black);
                        },
                      ),
                    ),
                    // Dark gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.55, 1.0],
                            colors: [
                              Colors.black.withOpacity(0.55),
                              Colors.black.withOpacity(0.35),
                              bg,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Back button
                    Positioned(
                      left: 16,
                      top: 16,
                      child: _CircleIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ),

                    // Title + Rating
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.brand.toUpperCase(),
                                  style: const TextStyle(
                                    color: gold,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  car.model,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _RatingChip(rating: car.rating.toStringAsFixed(1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // BOTTOM CONTENT
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.event_seat_outlined,
                            label: 'SEATS',
                            value: car.seats.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.bolt_rounded,
                            label: 'FUEL',
                            value: car.fuel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.speed_rounded,
                            label: 'TYPE',
                            value: car.type,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.calendar_month_outlined,
                            label: 'YEAR',
                            value: car.year.toString(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      "Owner's note",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Text(
                        // 🔥 ЗАМЕНИ НА ЭТО:
                        car.description.isEmpty
                            ? "No description provided."
                            : car.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _PriceCard(
                      perHour: '\$${car.pricePerHour}',
                      perDay: '\$${car.pricePerDay}',
                    ),

                    const SizedBox(height: 16),

                    _PrimaryButton(
                      text: 'Select Date & Time',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SelectDateTimeScreen(
                              car: car,
                              days: 1,
                              totalFromBackend: 0,
                            ),
                          ),
                        );
                      },
                    ),

                    // extra space so content never touches bottom gesture bar
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _safeFeature(List<String> features, int index) {
  if (index < 0 || index >= features.length) return '';
  return features[index];
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35),
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

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF14161A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 18, color: _CarDetailsView.gold),
          const SizedBox(width: 6),
          Text(
            rating,
            style: const TextStyle(
              color: _CarDetailsView.gold,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _CarDetailsView.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.25),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _CarDetailsView.gold, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: _CarDetailsView.gold.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 16,
            color: _CarDetailsView.gold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.perHour,
    required this.perDay,
  });

  final String perHour;
  final String perDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _CarDetailsView.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Per hour',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.40),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Per day',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.40),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                perHour,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                perDay,
                style: const TextStyle(
                  color: _CarDetailsView.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _CarDetailsView.gold,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.calendar_month_outlined, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}