import 'package:geolocator/geolocator.dart';

/// Résultat d'une demande de position.
enum LocationIssue { serviceDisabled, denied, deniedForever, unavailable }

class LocationResult {
  const LocationResult.ok(this.latitude, this.longitude) : issue = null;
  const LocationResult.failed(this.issue)
      : latitude = null,
        longitude = null;
  final double? latitude;
  final double? longitude;
  final LocationIssue? issue;
}

/// Position actuelle de l'appareil (téléphone ou navigateur), après accord
/// de l'utilisateur. Sur le Web, le navigateur affiche sa propre demande.
Future<LocationResult> currentLocation() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return const LocationResult.failed(LocationIssue.serviceDisabled);
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return const LocationResult.failed(LocationIssue.denied);
    if (permission == LocationPermission.deniedForever) return const LocationResult.failed(LocationIssue.deniedForever);
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
    );
    return LocationResult.ok(double.parse(p.latitude.toStringAsFixed(6)), double.parse(p.longitude.toStringAsFixed(6)));
  } catch (_) {
    return const LocationResult.failed(LocationIssue.unavailable);
  }
}
