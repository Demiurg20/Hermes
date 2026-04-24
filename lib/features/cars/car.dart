import 'package:flutter/material.dart';

class Car {
  final String id;
  final String brand;
  final String model;
  final double rating;
  final String imageUrl;

  final int seats;
  final String fuel;
  final String type;
  final int year;
  final String description;
  final int capacity;

  final List<String> features;

  final int pricePerHour;
  final int pricePerDay;

  final Color accentColor;

  /// Numeric id for `POST /bookings` (`carId`). Set from API `carId` / numeric `id`.
  final int? bookingCarId;

  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.rating,
    required this.imageUrl,
    required this.seats,
    required this.fuel,
    required this.type,
    required this.year,
    required this.description,
    required this.capacity,
    required this.features,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.accentColor,
    this.bookingCarId,
  });

  // Backward-compatible aliases for older UI code
  String get name => '$brand $model';
  String get image => imageUrl;
  int get price => pricePerHour;

  factory Car.fromJson(Map<String, dynamic> json) {
    const String backendBaseUrl = 'https://ungrudging-carson-nonvituperatively.ngrok-free.dev';
    final rawImage = (json['imageUrl'] ?? json['image'] ?? '').toString();
    final imageUrl = rawImage.isEmpty
        ? ''
        : (rawImage.startsWith('http')
        ? rawImage
        : (rawImage.startsWith('/')
        ? '$backendBaseUrl$rawImage'
        : '$backendBaseUrl/$rawImage'));

    final rawId = json['id'] ??
        json['_id'] ??
        json['carId'] ??
        json['uuid'] ??
        json['ID'];
    final id = rawId == null ? '' : rawId.toString();

    return Car(
      id: id,
      bookingCarId: _parseBookingCarId(json),

      brand: (json['brand'] ?? '').toString(),
      model: (json['model'] ?? json['title'] ?? '').toString(),

      description: (json['description'] ?? 'No description provided.').toString(),
      capacity: (json['capacity'] as num?)?.toInt() ?? 1,

      rating: (json['rating'] as num?)?.toDouble() ?? 4.7,
      imageUrl: imageUrl,

      seats: (json['seats'] as num?)?.toInt() ?? (json['capacity'] as num?)?.toInt() ?? 4,

      fuel: (json['fuelType'] ?? json['fuel'] ?? 'Petrol').toString(),
      type: (json['transmission'] ?? json['type'] ?? 'Auto').toString(),

      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,

      features: (json['features'] is List)
          ? (json['features'] as List).map((e) => e.toString()).toList()
          : const <String>[],

      pricePerHour: (json['pricePerHour'] as num?)?.toInt() ?? (json['price'] as num?)?.toInt() ?? 0,
      pricePerDay: (json['pricePerDay'] as num?)?.toInt() ?? ((json['pricePerHour'] as num?)?.toInt() ?? 0) * 24,

      accentColor: const Color(0xFFD6A34A),
    );
  }

  static int? _parseBookingCarId(Map<String, dynamic> json) {
    final fromCarId = _parsePositiveInt(json['carId']);
    if (fromCarId != null) return fromCarId;

    final fromId = _parsePositiveInt(json['id']);
    if (fromId != null) return fromId;

    return null;
  }

  static int? _parsePositiveInt(dynamic v) {
    if (v is int) return v > 0 ? v : null;
    if (v is num) {
      final i = v.toInt();
      return i > 0 ? i : null;
    }
    final s = v?.toString().trim();
    if (s == null || s.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(s)) return null;
    final i = int.parse(s);
    return i > 0 ? i : null;
  }
}