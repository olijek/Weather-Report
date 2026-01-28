import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _apiKey = 'a9f4757b38b44ebe98b115055262701';
  static const String _cityQuery = 'Karaganda'; //задать город

  late Future<Map<String, dynamic>> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeatherNow();
  }

  Future<Map<String, dynamic>> _fetchWeatherNow() async {
    final url = Uri.parse(
      'https://api.weatherapi.com/v1/current.json?key=$_apiKey&q=$_cityQuery&lang=ru',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('WeatherAPI error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E88A5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _weatherFuture,
            builder: (context, snapshot) {
              //плейсхолдеры
              String cityText = 'KARAGANDA.KZ';
              String tempText = '-8°';

              if (snapshot.hasData) {
                final data = snapshot.data!;
                final city = data['location']['name'];
                final tempC = data['current']['temp_c'];

                cityText = (city.toString().toUpperCase()) + '.KZ';
                tempText = '${(tempC as num).toStringAsFixed(0)}°';
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cityText,
                              style: const TextStyle(
                                color: Colors.white70,
                                letterSpacing: 1.2,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pushNamed(context, '/settings');
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Text(
                          tempText,
                          style: const TextStyle(
                            fontSize: 100,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: const [
                            Icon(Icons.cloudy_snowing, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Snow  -1° / -14°',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _card(
                    title: 'Weather forecast for 3 days',
                    child: Column(
                      children: const [
                        _DayForecast('Monday', Icons.cloudy_snowing, '-14° / -1°'),
                        _DayForecast('Tuesday', Icons.cloud, '-21° / -10°'),
                        _DayForecast('Wednesday', Icons.sunny, '-24° / -16°'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _card(
                    title: 'Forecast for 24 hours',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _Temp('-5°'),
                            _Temp('-6°'),
                            _Temp('-7°'),
                            _Temp('-7°'),
                            _Temp('-7°'),
                            _Temp('-9°'),
                            _Temp('-11°'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _Hour('Now'),
                            _Hour('13:00'),
                            _Hour('14:00'),
                            _Hour('15:00'),
                            _Hour('16:00'),
                            _Hour('17:00'),
                            _Hour('18:00'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget _card({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DayForecast extends StatelessWidget {
  final String day;
  final IconData icon;
  final String temp;

  const _DayForecast(this.day, this.icon, this.temp);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(color: Colors.white)),
          Icon(icon, color: Colors.white),
          Text(temp, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _Hour extends StatelessWidget {
  final String time;

  const _Hour(this.time);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.cloudy_snowing, color: Colors.white),
        const SizedBox(height: 6),
        Text(time,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _Temp extends StatelessWidget {
  final String value;

  const _Temp(this.value);

  @override
  Widget build(BuildContext context) {
    return Text(value, style: const TextStyle(color: Colors.white));
  }
}
