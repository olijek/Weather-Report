import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/notification_service.dart';


class WeatherService {
  static const String _apiKey = 'a9f4757b38b44ebe98b115055262701';

  static Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final url = Uri.parse(
      'https://api.weatherapi.com/v1/current.json?key=$_apiKey&q=$city&lang=ru',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Weather API error");
    }
  }
}
