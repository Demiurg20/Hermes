/// Pickup / drop-off point from backend.
class Location {
  const Location({
    required this.id,
    required this.city,
    required this.address,
    required this.url,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String city;
  final String address;
  final String url;
  final String latitude;
  final String longitude;

  String get titleLine => '$city · $address';

  factory Location.fromJson(Map<String, dynamic> json) {
    final id = _parseLocationId(json);
    if (id == null || id <= 0) {
      throw FormatException('Location id missing or invalid: $json');
    }

    return Location(
      id: id,
      city: (json['city'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      latitude: (json['latitude'] ?? '').toString(),
      longitude: (json['longitude'] ?? '').toString(),
    );
  }

  static int? _parseLocationId(Map<String, dynamic> json) {
    const keys = ['id', 'locationId', 'pickUpLocationId'];
    for (final key in keys) {
      final v = json[key];
      if (v is int && v > 0) return v;
      if (v is num) {
        final i = v.toInt();
        if (i > 0) return i;
      }
      final s = v?.toString().trim();
      if (s != null && s.isNotEmpty && RegExp(r'^\d+$').hasMatch(s)) {
        final i = int.parse(s);
        if (i > 0) return i;
      }
    }
    return null;
  }
}
