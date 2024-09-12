import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  static const String FORECAST_URL = 'http://api.openweathermap.org/data/2.5/forecast';
  final String apiKey;

  WeatherService(this.apiKey);

  /// Fetches current weather data for a given city
  Future<Weather> getWeather(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load weather data: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  /// Fetches 5-day weather forecast (at noon) for a given city
  Future<List<Weather>> getWeeklyWeather(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$FORECAST_URL?q=$cityName&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        List<dynamic> json = jsonDecode(response.body)['list'];
        return json
            .where((day) => day['dt_txt'].endsWith('12:00:00')) // Daily forecast at noon
            .map((day) => Weather.fromJson(day))
            .toList();
      } else {
        throw Exception('Failed to load weekly weather data: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching weekly weather data: $e');
    }
  }

  /// Fetches hourly weather forecast for the next 24 hours for a given city
  Future<List<Weather>> getHourlyWeather(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$FORECAST_URL?q=$cityName&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        List<dynamic> json = jsonDecode(response.body)['list'];
        return json
            .map((hour) => Weather.fromJson(hour))
            .toList()
            .take(8) // Get 8 data points (3-hour intervals for 24 hours)
            .toList();
      } else {
        throw Exception('Failed to load hourly weather data: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching hourly weather data: $e');
    }
  }

  /// Gets the current city based on the user's geolocation
  Future<String> getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          throw Exception('Location permission denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        return placemarks[0].locality ?? 'Unknown City';
      } else {
        throw Exception('Failed to get city name from coordinates');
      }
    } catch (e) {
      throw Exception('Error getting current city: $e');
    }
  }
}
