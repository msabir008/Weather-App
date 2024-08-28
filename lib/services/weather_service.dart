import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  static const String FORECAST_URL = 'http://api.openweathermap.org/data/2.5/forecast';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.reasonPhrase}');
    }
  }

  Future<List<Weather>> getWeeklyWeather(String cityName) async {
    final response = await http.get(Uri.parse('$FORECAST_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)['list'];
      return json.map((day) => Weather.fromJson(day)).toList();
    } else {
      throw Exception('Failed to load weekly weather data: ${response.reasonPhrase}');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        throw Exception('Location permission denied');
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        return placemarks[0].locality ?? 'Unknown City';
      } else {
        throw Exception('Failed to get city name from coordinates');
      }
    } catch (e) {
      throw Exception('Failed to get current city: $e');
    }
  }
}
