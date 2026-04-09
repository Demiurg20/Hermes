/// Pure calculation: rental ends [durationDays] full calendar days after [startDate]
/// (same clock time as start).
///
/// Throws [ArgumentError] if [durationDays] is not positive.
DateTime computeRentalEndDate(DateTime startDate, int durationDays) {
  if (durationDays <= 0) {
    throw ArgumentError.value(
      durationDays,
      'durationDays',
      'Duration must be at least 1 day',
    );
  }
  return startDate.add(Duration(days: durationDays));
}
