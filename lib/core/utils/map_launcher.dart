import 'package:url_launcher/url_launcher.dart';

import 'package:hermes/core/models/location.dart';

/// Opens [location.url] in browser/maps app, or falls back to lat/lng query.
Future<void> openLocationInMaps(Location location) async {
  Uri? uri;

  final rawUrl = location.url.trim();
  if (rawUrl.isNotEmpty) {
    final normalized = rawUrl.startsWith('http://') || rawUrl.startsWith('https://')
        ? rawUrl
        : 'https://$rawUrl';
    uri = Uri.tryParse(normalized);
  }

  if (uri == null || !uri.hasScheme) {
    final lat = double.tryParse(location.latitude);
    final lng = double.tryParse(location.longitude);
    if (lat != null && lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    }
  }

  if (uri == null) return;

  if (!await canLaunchUrl(uri)) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
