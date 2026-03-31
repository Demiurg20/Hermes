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

  final List<String> features;

  final int pricePerHour;
  final int pricePerDay;

  final Color accentColor;

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
    required this.features,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.accentColor,
  });

  // Backward-compatible aliases for older UI code
  String get name => '$brand $model';
  String get image => imageUrl;
  int get price => pricePerHour;

  factory Car.fromJson(Map<String, dynamic> json) {
    // Base URL for turning relative image paths like "/static/..." into a full URL.
    const String backendBaseUrl = 'https://ungrudging-carson-nonvituperatively.ngrok-free.dev';

    final rawImage = (json['imageUrl'] ?? json['image'] ?? '').toString();
    final imageUrl = rawImage.isEmpty
        ? ''
        : (rawImage.startsWith('http')
        ? rawImage
        : (rawImage.startsWith('/')
        ? '$backendBaseUrl$rawImage'
        : '$backendBaseUrl/$rawImage'));

    return Car(
      id: json['id']?.toString() ?? '',

      // Backend uses brand/model; keep fallbacks for older test sources.
      brand: (json['brand'] ?? '').toString(),
      model: (json['model'] ?? json['title'] ?? '').toString(),

      // Backend currently does not provide rating.
      rating: (json['rating'] as num?)?.toDouble() ?? 4.7,

      imageUrl: imageUrl,

      // Backend uses `capacity` for seats.
      seats: (json['capacity'] as num?)?.toInt() ?? (json['seats'] as num?)?.toInt() ?? 4,

      // Backend uses `fuelType`.
      fuel: (json['fuelType'] ?? json['fuel'] ?? 'Petrol').toString(),

      // Backend uses `transmission`.
      type: (json['transmission'] ?? json['type'] ?? 'Auto').toString(),

      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,

      features: (json['features'] is List)
          ? (json['features'] as List).map((e) => e.toString()).toList()
          : const <String>[],

      pricePerHour: (json['pricePerHour'] as num?)?.toInt() ?? (json['price'] as num?)?.toInt() ?? 0,
      pricePerDay: (json['pricePerDay'] as num?)?.toInt() ?? (json['price'] as num?)?.toInt() ?? 0,

      accentColor: const Color(0xFFD6A34A),
    );
  }
}