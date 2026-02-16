import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _apiKey = 'a9f4757b38b44ebe98b115055262701';

  final List<String> _cities = [
    'Karaganda',
    'Astana',
    'Almaty',
    'Shymkent',
    'Aktobe',
  ];

  String _selectedCity = 'Karaganda';

  late Future<Map<String, dynamic>> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeatherForecast();
  }

  Future<Map<String, dynamic>> _fetchWeatherForecast() async {
    final url = Uri.parse(
      'https://api.weatherapi.com/v1/forecast.json?key=$_apiKey&q=$_selectedCity&days=3&aqi=no&alerts=no&lang=ru',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('WeatherAPI error: ${response.statusCode}');
    }
  }

  void _changeCity(String city) async {
    setState(() {
      _selectedCity = city;
      _weatherFuture = _fetchWeatherForecast();
    });

    final data = await _weatherFuture;
    final temp = data['current']['temp_c'];
    final condition = data['current']['condition']['text'];

    NotificationService.showWeatherNotification(
      city,
      '${temp.toStringAsFixed(0)}°C',
      condition,
    );
  }

  String _formatHour(String timeStr) {
    final dt = DateTime.tryParse(timeStr);
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:00';
  }

  String _formatDayName(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;

    const names = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье'
    ];
    return names[dt.weekday - 1];
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
              String tempText = '--°';
              String conditionText = 'Loading...';
              String iconUrl = '';

              List<dynamic> forecastDays = [];
              List<dynamic> todayHours = [];
              int startHour = 0;

              if (snapshot.hasData) {
                final data = snapshot.data!;
                final current = data['current'];
                tempText = '${current['temp_c'].toStringAsFixed(0)}°';
                conditionText = current['condition']['text'];
                iconUrl = 'https:${current['condition']['icon']}';

                final localtime = DateTime.parse(data['location']['localtime']);
                startHour = localtime.hour;

                forecastDays = data['forecast']['forecastday'];
                todayHours = forecastDays[0]['hour'];
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
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCity,
                                dropdownColor: const Color(0xFF5E88A5),
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                style: const TextStyle(color: Colors.white70),
                                items: _cities.map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(c.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) _changeCity(value);
                                },
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              onPressed: () => Navigator.pushNamed(context, '/settings'),
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
                          children: [
                            if (iconUrl.isNotEmpty)
                              Image.network(iconUrl, width: 30, height: 30),
                            const SizedBox(width: 8),
                            Text(conditionText, style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _card(
                    title: 'Прогноз на 3 дня',
                    child: Column(
                      children: List.generate(3, (i) {
                        final day = forecastDays[i];
                        final name = _formatDayName(day['date']);
                        final min = day['day']['mintemp_c'].toStringAsFixed(0);
                        final max = day['day']['maxtemp_c'].toStringAsFixed(0);
                        return _DayForecast(name, Icons.cloud, '$min° / $max°');
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _card(
                    title: 'Прогноз на 24 часа',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (i) {
                            final hour = todayHours[startHour + i];
                            return _Temp('${hour['temp_c'].toStringAsFixed(0)}°');
                          }),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (i) {
                            final hour = todayHours[startHour + i];
                            return _Hour(i == 0 ? 'Now' : _formatHour(hour['time']));
                          }),
                        ),
                      ],
                    ),
                  ),
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
          Text(title, style: const TextStyle(color: Colors.white70)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: const TextStyle(color: Colors.white)),
        Icon(icon, color: Colors.white),
        Text(temp, style: const TextStyle(color: Colors.white)),
      ],
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
        const Icon(Icons.cloud, color: Colors.white),
        Text(time, style: const TextStyle(color: Colors.white70)),
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
