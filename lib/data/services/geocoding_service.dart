import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final String apiKey =
      'bkoi_220f2cf0bc394fc657f38d0f5e4374b33e3ffcc05d578de88c7062ef9a329e6a'; // Your Barikoi API key

  // Function to get latitude and longitude from an address using Barikoi API
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    print("Getting coordinates for address: $address"); // Log address to verify
    final Uri uri = Uri.https(
      'api.barikoi.com',
      '/geocode/search',
      {
        'q': address,
        'token': apiKey,
      }, // Adjust according to Barikoi API documentation
    );

    try {
      final response = await http.get(uri);
      print(
        'Barikoi Geocoding API Response: ${response.body}',
      ); // Debugging log
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0];
          final lat = location['location']['lat'];
          final lng = location['location']['lng'];
          print(
            'Coordinates for $address: Latitude: $lat, Longitude: $lng',
          ); // Debugging log
          return {'latitude': lat, 'longitude': lng};
        } else {
          print('No results found for the address $address'); // Debugging log
        }
      } else {
        print('Failed to get geocoding data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching coordinates: $e');
    }
    return null;
  }
}
