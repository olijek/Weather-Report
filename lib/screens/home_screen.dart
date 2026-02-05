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

  // Города для выбора
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

  String _formatHour(String timeStr) {
    final dt = DateTime.tryParse(timeStr);
    if (dt == null) return '--:--';
    final h = dt.hour.toString().padLeft(2, '0');
    return '$h:00';
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
              // плейсхолдеры
              String tempText = '-8°';
              String conditionText = 'Loading...';
              String conditionIconUrl = '';

              // forecast data
              List<dynamic> forecastDays = [];
              List<dynamic> todayHours = [];
              int startHourIndex = 0;

              if (snapshot.hasData) {
                final data = snapshot.data!;

                // current
                final current = data['current'] as Map<String, dynamic>;
                final tempC = current['temp_c'];

                final condition =
                current['condition'] as Map<String, dynamic>;

                final icon = condition['icon']?.toString() ?? '';
                conditionIconUrl =
                icon.startsWith('http') ? icon : 'https:$icon';

                conditionText = condition['text']?.toString() ?? '---';
                tempText = '${(tempC as num).toStringAsFixed(0)}°';

                // local time -> чтобы 24 часа начинались с текущего времени
                final location = data['location'] as Map<String, dynamic>;
                final localtimeStr = location['localtime']?.toString() ?? '';
                final localtime = DateTime.tryParse(localtimeStr);
                if (localtime != null) {
                  startHourIndex = localtime.hour;
                }

                // forecast
                final forecast = data['forecast'] as Map<String, dynamic>;
                forecastDays = forecast['forecastday'] as List<dynamic>;

                // today hours
                if (forecastDays.isNotEmpty) {
                  todayHours = forecastDays[0]['hour'] as List<dynamic>;
                }
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
                            // ВЫБОР ГОРОДА
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCity,
                                dropdownColor: const Color(0xFF5E88A5),
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white70),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                                items: _cities.map((city) {
                                  return DropdownMenuItem(
                                    value: city,
                                    child: Text(city.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedCity = value;
                                    _weatherFuture = _fetchWeatherForecast();
                                  });
                                },
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
                          children: [
                            // ИКОНКА ИЗ API
                            if (conditionIconUrl.isNotEmpty)
                              Image.network(
                                conditionIconUrl,
                                width: 28,
                                height: 28,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.wb_sunny,
                                      color: Colors.white);
                                },
                              )
                            else
                              const Icon(Icons.cloudy_snowing,
                                  color: Colors.white),

                            const SizedBox(width: 8),

                            // ТЕКУЩАЯ ПОГОДА ИЗ API
                            Text(
                              conditionText,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ 3 DAYS FORECAST ИЗ API
                  _card(
                    title: 'Прогноз погоды на 3 дня',
                    child: (forecastDays.isEmpty)
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Loading...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                        : Column(
                      children: List.generate(
                        forecastDays.length > 3 ? 3 : forecastDays.length,
                            (index) {
                          final day =
                          forecastDays[index] as Map<String, dynamic>;

                          final dateStr = day['date']?.toString() ?? '';
                          final dayName = _formatDayName(dateStr);

                          final dayData =
                          day['day'] as Map<String, dynamic>;

                          final minTemp =
                          (dayData['mintemp_c'] as num)
                              .toStringAsFixed(0);
                          final maxTemp =
                          (dayData['maxtemp_c'] as num)
                              .toStringAsFixed(0);


                          final condition =
                          dayData['condition'] as Map<String, dynamic>;
                          final text =
                              condition['text']?.toString() ?? '';

                          IconData iconData = Icons.cloud;
                          final t = text.toLowerCase();
                          if (t.contains('sun') ||
                              t.contains('ясно') ||
                              t.contains('солнечно')) {
                            iconData = Icons.sunny;
                          } else if (t.contains('snow') ||
                              t.contains('снег')) {
                            iconData = Icons.cloudy_snowing;
                          } else if (t.contains('rain') ||
                              t.contains('дождь')) {
                            iconData = Icons.umbrella;
                          } else if (t.contains('cloud') ||
                              t.contains('облачно')) {
                            iconData = Icons.cloud;
                          }

                          return _DayForecast(
                            dayName,
                            iconData,
                            '$minTemp° / $maxTemp°',
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),


                  _card(
                    title: 'Прогноз на 24 часа',
                    child: (todayHours.isEmpty)
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Loading...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                        : Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: List.generate(() {
                            final available =
                                todayHours.length - startHourIndex;
                            final count = available > 7 ? 7 : available;
                            return count;
                          }(), (index) {
                            final hour = todayHours[startHourIndex + index]
                            as Map<String, dynamic>;
                            final temp = hour['temp_c'] as num;
                            return _Temp('${temp.toStringAsFixed(0)}°');
                          }),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: List.generate(() {
                            final available =
                                todayHours.length - startHourIndex;
                            final count = available > 7 ? 7 : available;
                            return count;
                          }(), (index) {
                            final hour = todayHours[startHourIndex + index]
                            as Map<String, dynamic>;
                            final timeStr = hour['time']?.toString() ?? '';
                            final label =
                            index == 0 ? 'Now' : _formatHour(timeStr);
                            return _Hour(label);
                          }),
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