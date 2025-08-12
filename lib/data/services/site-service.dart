// site-service.dart

import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:dio/dio.dart';

class SiteService {
  final Dio dio;

  SiteService({required this.dio});

  // Fetches sites from the API
  Future<List<Map<String, dynamic>>> fetchSites() async {
    try {
      final response = await dio.get("https://api.shwapno.app/api/sites");

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception("Failed to fetch sites");
      }
    } catch (e) {
      throw Exception("Failed to fetch sites: $e");
    }
  }

  // Get current location of the user
  Future<Position> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      throw Exception("Failed to get current location: $e");
    }
  }

  // Calculate distance using Haversine Formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of Earth in km
    final lat1Rad = _degreesToRadians(lat1);
    final lon1Rad = _degreesToRadians(lon1);
    final lat2Rad = _degreesToRadians(lat2);
    final lon2Rad = _degreesToRadians(lon2);

    final dlat = lat2Rad - lat1Rad;
    final dlon = lon2Rad - lon1Rad;

    final a =
        sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dlon / 2) * sin(dlon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in kilometers
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
