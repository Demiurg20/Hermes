import 'package:hermes/core/api/api_service.dart';
import 'package:hermes/core/models/location.dart';

class LocationRepository {
  LocationRepository(this._api);

  final ApiService _api;

  Future<List<Location>> getLocations() async {
    final raw = await _api.getLocationsBackend();

    if (raw is Map && raw['data'] is List) {
      return _parseList(raw['data'] as List);
    }
    if (raw is List) {
      return _parseList(raw);
    }
    return const [];
  }

  List<Location> _parseList(List<dynamic> list) {
    final out = <Location>[];
    for (final e in list) {
      if (e is! Map) continue;
      try {
        out.add(Location.fromJson(Map<String, dynamic>.from(e)));
      } catch (_) {
        continue;
      }
    }
    return out;
  }
}
