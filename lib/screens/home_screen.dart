import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E88A5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'KARAGANDA.KZ',
                          style: TextStyle(
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      '-8°',
                      style: TextStyle(
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