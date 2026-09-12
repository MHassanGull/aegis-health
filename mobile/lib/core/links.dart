import 'package:url_launcher/url_launcher.dart';

/// Opens Google Maps searching for doctors/clinics near the user.
/// No API key or billing — uses the universal Maps search URL.
Future<void> openDoctorsNearby() async {
  final uri = Uri.parse('https://www.google.com/maps/search/doctors+clinics+near+me');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
