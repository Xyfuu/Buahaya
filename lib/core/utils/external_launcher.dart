import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Buka Google Maps (rute) ke koordinat tujuan.
Future<void> openDirections(
  BuildContext context, {
  required double lat,
  required double lng,
  String? label,
}) async {
  final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
  bool ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Could not open Maps.')));
  }
}
