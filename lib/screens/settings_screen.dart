import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Units of measurement',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 8),

            _card(
              children: const [
                _SettingItem('Temperature', '°C'),
                _SettingItem('Wind speed', 'KMH'),
                _SettingItem(
                  'Units of atmospheric pressure measurement',
                  'Mbar',
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'About app',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 8),

            _card(
              children: const [
                _NavItem('Feedback'),
                _NavItem('Privacy policy'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final String value;

  const _SettingItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.white70)),
          const Icon(Icons.expand_more, color: Colors.white70),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;

  const _NavItem(this.title);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {},
    );
  }
}