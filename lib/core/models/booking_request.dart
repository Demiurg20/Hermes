/// Payload for `POST /api/bookings` (backend contract).
class BookingRequest {
  const BookingRequest({
    required this.carId,
    required this.pickUpLocationId,
    required this.dropOffLocationId,
    required this.startDate,
    required this.endDate,
  });

  final int carId;
  final int pickUpLocationId;
  final int dropOffLocationId;
  final DateTime startDate;
  final DateTime endDate;

  Map<String, dynamic> toJson() => {
        'carId': carId,
        'pickUpLocationId': pickUpLocationId,
        'dropOffLocationId': dropOffLocationId,
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
      };
}
