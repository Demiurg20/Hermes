import 'package:flutter/material.dart';
import 'package:hermes/core/app/app_di.dart';
import 'package:hermes/core/booking/rental_period.dart';
import 'package:hermes/core/models/location.dart';
import 'package:hermes/core/utils/map_launcher.dart';

import '../cars/car.dart';
import 'price_summary_page.dart';

class SelectDateTimeScreen extends StatefulWidget {
  const SelectDateTimeScreen({
    super.key,
    required this.car,
    this.days = 1,
    this.totalFromBackend = 0,
  });

  final Car car;
  final int days;
  final double totalFromBackend;

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  static const Color bg = Color(0xFF0B0C0E);
  static const Color gold = Color(0xFFD6A34A);
  static const Color card = Color(0xFF111317);

  int selectedDateIndex = 0;
  int selectedTimeIndex = 2; // default 10:00
  int durationDays = 2;

  late final List<_DateItem> dates;

  List<Location> _locations = const [];
  bool _loadingLocations = true;
  String? _locationsError;
  Location? _pickupLocation;
  Location? _dropoffLocation;

  static const List<String> pageTimes = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '14:00',
    '16:00',
    '18:00',
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    dates = List.generate(5, (i) => _DateItem.fromDate(today.add(Duration(days: i))));

    durationDays = widget.days < 1 ? 1 : widget.days;
    if (durationDays < 1) durationDays = 1;

    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final list = await AppDI.locationRepo.getLocations();
      if (!mounted) return;
      setState(() {
        _locations = list;
        _loadingLocations = false;
        _locationsError = null;
        if (_pickupLocation == null && list.isNotEmpty) {
          _pickupLocation = list.first;
        }
        if (_dropoffLocation == null && list.isNotEmpty) {
          _dropoffLocation = list.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingLocations = false;
        _locationsError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Select Date & Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      icon: Icons.location_on_outlined,
                      title: 'Pickup & drop-off',
                    ),
                    const SizedBox(height: 12),
                    if (_loadingLocations)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(color: gold),
                        ),
                      )
                    else if (_locationsError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Could not load locations: $_locationsError',
                          style: TextStyle(
                            color: Colors.redAccent.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (_locations.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'No pickup locations available.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else ...[
                      Text(
                        'Pickup location',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Location>(
                        value: _pickupLocation,
                        dropdownColor: card,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: _locations
                            .map(
                              (loc) => DropdownMenuItem<Location>(
                                value: loc,
                                child: Text(
                                  loc.titleLine,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (loc) {
                          setState(() => _pickupLocation = loc);
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.map_outlined, color: gold),
                          onPressed: _pickupLocation == null
                              ? null
                              : () => openLocationInMaps(_pickupLocation!),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Drop-off location',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Location>(
                        value: _dropoffLocation,
                        dropdownColor: card,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: _locations
                            .map(
                              (loc) => DropdownMenuItem<Location>(
                                value: loc,
                                child: Text(
                                  loc.titleLine,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (loc) {
                          setState(() => _dropoffLocation = loc);
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.map_outlined, color: gold),
                          onPressed: _dropoffLocation == null
                              ? null
                              : () => openLocationInMaps(_dropoffLocation!),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    const _SectionTitle(
                      icon: Icons.calendar_month_outlined,
                      title: 'Pick a Date',
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 108,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final isSelected = i == selectedDateIndex;
                          return _DateCard(
                            weekday: dates[i].weekday,
                            day: dates[i].dayOfMonth,
                            month: dates[i].month,
                            isSelected: isSelected,
                            onTap: () => setState(() => selectedDateIndex = i),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    const _SectionTitle(
                      icon: Icons.access_time_rounded,
                      title: 'Pickup Time',
                    ),
                    const SizedBox(height: 12),

                    GridView.builder(
                      itemCount: pageTimes.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.3,
                      ),
                      itemBuilder: (context, i) {
                        final isSelected = i == selectedTimeIndex;
                        return _TimeChip(
                          text: pageTimes[i],
                          isSelected: isSelected,
                          onTap: () => setState(() => selectedTimeIndex = i),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Duration (days)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          _RoundIconButton(
                            icon: Icons.remove,
                            background: Colors.white.withOpacity(0.06),
                            iconColor: Colors.white.withOpacity(0.85),
                            onTap: durationDays <= 1 ? null : () => setState(() => durationDays--),
                          ),
                          const Spacer(),
                          Text(
                            durationDays.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          _RoundIconButton(
                            icon: Icons.add,
                            background: gold,
                            iconColor: Colors.black,
                            onTap: () => setState(() => durationDays++),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _PrimaryButton(
                text: 'Calculate Price',
                onTap: () {
                  if (_pickupLocation == null || _dropoffLocation == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Select pickup and drop-off locations'),
                      ),
                    );
                    return;
                  }
                  if (durationDays <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rental duration must be at least 1 day'),
                      ),
                    );
                    return;
                  }

                  final timeStr = pageTimes[selectedTimeIndex];
                  final parts = timeStr.split(':');
                  final hh = int.parse(parts[0]);
                  final mm = int.parse(parts[1]);

                  final selectedDate = dates[selectedDateIndex].date;
                  final pickupDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    hh,
                    mm,
                  );

                  DateTime dropoffDateTime;
                  try {
                    dropoffDateTime =
                        computeRentalEndDate(pickupDateTime, durationDays);
                  } on ArgumentError catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message ?? e.toString())),
                    );
                    return;
                  }

                  final total = widget.totalFromBackend == 0
                      ? (widget.car.pricePerDay * durationDays).toDouble()
                      : widget.totalFromBackend;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PriceSummaryScreen(
                        car: widget.car,
                        pickUpLocationId: _pickupLocation!.id,
                        dropOffLocationId: _dropoffLocation!.id,
                        pickupLocationLabel: _pickupLocation!.titleLine,
                        dropoffLocationLabel: _dropoffLocation!.titleLine,
                        pickupDateTime: pickupDateTime,
                        dropoffDateTime: dropoffDateTime,
                        days: durationDays,
                        totalFromBackend: total,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.location,
    required this.selected,
    required this.onSelect,
    required this.onOpenMap,
  });

  final Location location;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onOpenMap;

  static const Color gold = Color(0xFFD6A34A);
  static const Color card = Color(0xFF111317);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selected ? gold : Colors.white38,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location.address,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.map_outlined, color: gold),
                  onPressed: onOpenMap,
                  tooltip: 'Open in maps',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateItem {
  final DateTime date;
  final String weekday;
  final String dayOfMonth;
  final String month;

  const _DateItem({
    required this.date,
    required this.weekday,
    required this.dayOfMonth,
    required this.month,
  });

  factory _DateItem.fromDate(DateTime d) {
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return _DateItem(
      date: d,
      weekday: weekdays[d.weekday - 1],
      dayOfMonth: d.day.toString(),
      month: months[d.month - 1],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  static const Color gold = Color(0xFFD6A34A);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: gold, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.weekday,
    required this.day,
    required this.month,
    required this.isSelected,
    required this.onTap,
  });

  final String weekday;
  final String day;
  final String month;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color gold = Color(0xFFD6A34A);
  static const Color card = Color(0xFF111317);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                day,
                style: TextStyle(
                  color: isSelected ? gold : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                month,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color gold = Color(0xFFD6A34A);
  static const Color card = Color(0xFF111317);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? gold.withOpacity(0.22) : card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? gold : Colors.white.withOpacity(0.06),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
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

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: iconColor, size: 22),
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
