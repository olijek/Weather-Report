import 'dart:convert';
import 'package:http/http.dart' as http;

class Weather {
  final String city;
  final double tempC;
  final String condition;
  final String iconUrl;

  Weather({
    required this.city,
    required this.tempC,
    required this.condition,
    required this.iconUrl,
  });

  factory Weather.fromJson(Map<String, dynamic>json) {
    return Weather(
      city: json['location']['name'],
      tempC: json['current']['temp_c'].toDouble(),
      condition: json['current']['condition']['text'],
      iconUrl: 'https:${json['current']['condition']['icon']}',
    );
  }
}

Future<Weather> fetchWeather(String city) async {
  const apiKey = 'a9f4757b38b44ebe98b115055262701';
  final url = Uri.parse(
    'http://api.weatherapi.com/v1/current.json?key=a9f4757b38b44ebe98b115055262701&q=Karaganda&aqi=yes'
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Weather.fromJson(data);
  } else {
    throw Exception('Failed to download weather');
  }
}