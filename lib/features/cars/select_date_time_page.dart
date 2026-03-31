import 'package:flutter/material.dart';
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

                  final dropoffDateTime = pickupDateTime.add(Duration(days: durationDays));

                  final total = widget.totalFromBackend == 0
                      ? (widget.car.pricePerDay * durationDays + 5).toDouble()
                      : widget.totalFromBackend;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PriceSummaryScreen(
                        car: widget.car,
                        pickupLocation: 'Moscow City Center',
                        pickupDateTime: pickupDateTime,
                        dropoffLocation: 'Moscow City Center',
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
